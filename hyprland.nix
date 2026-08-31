{
  pkgs,
  ...
}:

let
  hyprQuickshellStart = pkgs.writeShellScriptBin "hypr-quickshell-start" ''
    #!/usr/bin/env bash
    export PATH="$HOME/.nix-profile/bin:$HOME/.local/state/nix/profiles/home-manager/home-path/bin:/usr/local/bin:/usr/bin:/bin:$PATH"
    export qsConfig="end4-pC"

    # Wait for Hyprland socket to be ready
    for i in {1..50}; do
      for sock in /run/user/$(id -u)/hypr/*/.socket.sock; do
        if [ -S "$sock" ]; then
          export HYPRLAND_INSTANCE_SIGNATURE=$(basename $(dirname "$sock"))
          break 2
        fi
      done
      sleep 0.1
    done

    pkill -9 -f quickshell 2>/dev/null || true
    pkill -9 -f qs 2>/dev/null || true
    sleep 0.2
    exec qs -c end4-pC
  '';
in
{
  wayland.windowManager.hyprland = {
    enable = pkgs.stdenv.isLinux;
    package = null;
    systemd.enable = false;
    configType = "hyprlang";
    plugins = [];
    settings = {
      "$mod" = "SUPER";

      env = [
        "PATH,$HOME/.nix-profile/bin:$HOME/.local/state/nix/profiles/home-manager/home-path/bin:/usr/local/bin:/usr/bin:/bin"
        "qsConfig,end4-pC"
        "QT_QPA_PLATFORM,wayland;xcb"
        "GDK_BACKEND,wayland,x11,*"
        "SDL_VIDEODRIVER,wayland"
        "CLUTTER_BACKEND,wayland"
        "XDG_CURRENT_DESKTOP,Hyprland"
        "XDG_SESSION_TYPE,wayland"
        "XDG_SESSION_DESKTOP,Hyprland"
      ];

      exec-once = [
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP PATH"
        "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP PATH"
        "hypridle"
        "${hyprQuickshellStart}/bin/hypr-quickshell-start"
        "wl-paste --type text --watch bash -c 'cliphist store && qs -c end4-pC ipc call cliphistService update'"
        "wl-paste --type image --watch bash -c 'cliphist store && qs -c end4-pC ipc call cliphistService update'"
      ];

      input = {
        kb_layout = "us";
        kb_variant = "altgr-intl";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = true;
        };
      };

      general = {
        gaps_in = 4;
        gaps_out = 8;
        border_size = 2;
        "col.active_border" = "rgba(7c4dffff) rgba(bb86fcff) 45deg";
        "col.inactive_border" = "rgba(31313600)";
        layout = "dwindle";
        resize_on_border = true;
      };

      decoration = {
        rounding = 12;
        blur = {
          enabled = true;
          xray = true;
          special = false;
          size = 10;
          passes = 3;
          brightness = 1;
          noise = 0.05;
          contrast = 0.89;
          vibrancy = 0.5;
          vibrancy_darkness = 0.5;
        };
        shadow = {
          enabled = true;
          range = 20;
          render_power = 10;
          color = "rgba(00000020)";
        };
        dim_inactive = true;
        dim_strength = 0.05;
        dim_special = 0.2;
      };

      animations = {
        enabled = true;
        bezier = [
          "linear, 0, 0, 1, 1"
          "md3_standard, 0.2, 0, 0, 1"
          "md3_decel, 0.05, 0.7, 0.1, 1"
          "md3_accel, 0.3, 0, 0.8, 0.15"
          "overshot, 0.05, 0.9, 0.1, 1.1"
          "crazyshot, 0.1, 1.5, 0.76, 0.92"
          "hyprnostretch, 0.05, 0.9, 0.1, 1.0"
          "fluent_decel, 0.1, 1, 0, 1"
          "easeInOutCirc, 0.85, 0, 0.15, 1"
          "easeOutCirc, 0, 0.55, 0.45, 1"
          "easeOutExpo, 0.16, 1, 0.3, 1"
          "softAcDecel, 0.16, 1, 0.4, 1"
        ];
        animation = [
          "windows, 1, 3, md3_decel, popin 60%"
          "windowsIn, 1, 3, md3_decel, popin 60%"
          "windowsOut, 1, 3, md3_accel, popin 60%"
          "border, 1, 10, default"
          "fade, 1, 3, md3_decel"
          "layersIn, 1, 3, md3_decel, slide"
          "layersOut, 1, 3, md3_accel, slide"
          "workspaces, 1, 5, md3_decel, slide"
          "specialWorkspace, 1, 3, md3_decel, slidevert"
        ];
      };

      dwindle = {
        preserve_split = true;
        smart_split = false;
        smart_resizing = false;
      };

      bind = [
        # Applications
        "$mod, RETURN, exec, alacritty"
        "$mod SHIFT, RETURN, exec, kitty"
        "$mod, E, exec, nautilus"

        # Window management
        "$mod, Q, killactive"
        "$mod, F, fullscreen, 0"
        "$mod, T, togglefloating"
        "$mod, J, layoutmsg, togglesplit"
        "$mod, P, pin"

        # Navigation / Focus / Swap
        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, K, movefocus, u"
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
        "$mod SHIFT, H, movewindow, l"
        "$mod SHIFT, L, movewindow, r"
        "$mod SHIFT, K, movewindow, u"
        "$mod SHIFT, J, movewindow, d"
        "$mod SHIFT, left, movewindow, l"
        "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up, movewindow, u"
        "$mod SHIFT, down, movewindow, d"

        # Workspaces 1-10
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 10, workspace, 10"

        # Move to workspace 1-10
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 10, movetoworkspace, 10"

        # Special workspace
        "$mod, S, togglespecialworkspace, special"
        "$mod SHIFT, S, movetoworkspace, special:special"

        # Quickshell shortcuts (illogical-impulse / end4-pC)
        "$mod, SUPER_L, global, quickshell:searchToggleRelease"
        "$mod, SUPER_R, global, quickshell:searchToggleRelease"
        ", SUPER_L, global, quickshell:workspaceNumber"
        ", SUPER_R, global, quickshell:workspaceNumber"
        "$mod, TAB, global, quickshell:overviewWorkspacesToggle"
        "$mod, V, global, quickshell:overviewClipboardToggle"
        "$mod, PERIOD, global, quickshell:overviewEmojiToggle"
        "$mod, A, global, quickshell:sidebarLeftToggle"
        "$mod ALT, A, global, quickshell:sidebarLeftToggleDetach"
        "$mod, B, global, quickshell:sidebarLeftToggle"
        "$mod, O, global, quickshell:sidebarLeftToggle"
        "$mod, N, global, quickshell:sidebarRightToggle"
        "$mod, SLASH, global, quickshell:cheatsheetToggle"
        "$mod, K, global, quickshell:oskToggle"
        "$mod, M, global, quickshell:mediaControlsToggle"
        "$mod, G, global, quickshell:overlayToggle"
        "CTRL ALT, DELETE, global, quickshell:sessionToggle"
        "CTRL $mod, T, global, quickshell:wallpaperSelectorToggle"
        "CTRL $mod ALT, T, global, quickshell:wallpaperSelectorRandom"
        "CTRL $mod SHIFT, D, global, quickshell:toggleLightDark"
        "CTRL $mod, P, global, quickshell:panelFamilyCycle"
        "$mod SHIFT, S, global, quickshell:regionScreenshot"
        "$mod SHIFT, A, global, quickshell:regionSearch"
        "$mod SHIFT, X, global, quickshell:regionOcr"
        "$mod SHIFT, T, global, quickshell:screenTranslate"
        "$mod SHIFT, R, global, quickshell:regionRecord"
        "$mod ALT, R, global, quickshell:regionRecord"
        "CTRL $mod, R, exec, killall ydotool qs quickshell; qs -c end4-pC &"
      ];

      bindel = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+ -l 1.5"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"
        ", XF86MonBrightnessUp, exec, brightnessctl s 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl s 5%-"
      ];

      bindl = [
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };
  };

  xdg.portal = {
    enable = pkgs.stdenv.isLinux;
    config = {
      common.default = "*";
      hyprland.default = [
        "hyprland"
        "gtk"
      ];
    };
  };

  home.packages = with pkgs; [
    hyprQuickshellStart
    grim
    slurp
    wl-clipboard
    jq
    brightnessctl
    playerctl
    cliphist
  ];
}
