{
  pkgs,
  lib,
  ...
}:

let
  end4pC = pkgs.fetchFromGitHub {
    owner = "pctrade";
    repo = "end4-pC";
    rev = "main";
    sha256 = "05h2ip0lzam27bydayni3w3y8g4kwzzm505si6q2zhf444fwpbpc";
  };

  illogicalImpulse = pkgs.fetchFromGitHub {
    owner = "end-4";
    repo = "dots-hyprland";
    rev = "main";
    sha256 = "16kqyqywcp1mkqgsm9fql0a73f7kihgkw4fzpf9n8rx6rhbpdghv";
  };

  patchedEnd4pC = pkgs.runCommand "end4-pC-patched" {} ''
    cp -r ${end4pC} $out
    chmod -R u+w $out

    # 1. Create missing DirectoryIcon.qml to fix purple/black missing textures on folders
    cat << 'EOF' > $out/modules/common/widgets/DirectoryIcon.qml
    import QtQuick
    import QtQuick.Layouts
    import qs.modules.common
    import qs.modules.common.widgets

    Item {
        id: root
        required property var fileModelData
        property size sourceSize: Qt.size(64, 64)

        Rectangle {
            anchors.fill: parent
            radius: Appearance.rounding.small
            color: Appearance.colors.colSecondaryContainer

            MaterialSymbol {
                anchors.centerIn: parent
                text: "folder"
                iconSize: Math.min(parent.width, parent.height) * 0.5
                color: Appearance.colors.colOnSecondaryContainer
            }
        }
    }
    EOF

    # 2. Add fallback in ThumbnailImage.qml so transparent images render sourcePath directly
    substituteInPlace $out/modules/common/widgets/ThumbnailImage.qml \
      --replace-fail "source: thumbnailPath" "source: thumbnailPath
    onStatusChanged: {
        if (status === Image.Error && source !== sourcePath) {
            source = sourcePath;
        }
    }"

    # 3. Configure PamContext to use 'login' PAM service for password authentication
    substituteInPlace $out/modules/common/panels/lock/LockContext.qml \
      --replace-fail "id: pam" "id: pam
        config: \"login\""

    # 4. Use hyprlock by default
    substituteInPlace $out/modules/common/Config.qml \
      --replace-fail "property bool useHyprlock: false" "property bool useHyprlock: true"
  '';

  wrappedQuickshell = pkgs.symlinkJoin {
    name = "quickshell-wrapped";
    paths = [ pkgs.quickshell ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/qs \
        --run 'if [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]; then for sock in /run/user/$(id -u)/hypr/*/.socket.sock; do if [ -S "$sock" ]; then export HYPRLAND_INSTANCE_SIGNATURE=$(basename $(dirname "$sock")); break; fi; done; fi' \
        --prefix QML2_IMPORT_PATH : "${pkgs.qt6.qt5compat}/lib/qt-6/qml:${pkgs.qt6.qtdeclarative}/lib/qt-6/qml:${pkgs.qt6.qtsvg}/lib/qt-6/qml:${pkgs.qt6.qtwayland}/lib/qt-6/qml:${pkgs.qt6.qtmultimedia}/lib/qt-6/qml:${pkgs.qt6.qtpositioning}/lib/qt-6/qml:${pkgs.kdePackages.kirigami}/lib/qt-6/qml:${pkgs.kdePackages.syntax-highlighting}/lib/qt-6/qml" \
        --prefix LD_LIBRARY_PATH : "${pkgs.qt6.qtbase}/lib:${pkgs.qt6.qtdeclarative}/lib:${pkgs.qt6.qtwayland}/lib:${pkgs.qt6.qt5compat}/lib:${pkgs.qt6.qtpositioning}/lib:${pkgs.qt6.qtsvg}/lib:${pkgs.qt6.qtmultimedia}/lib:${pkgs.kdePackages.kirigami}/lib:${pkgs.kdePackages.syntax-highlighting}/lib:${pkgs.libGL}/lib:${pkgs.mesa}/lib:${pkgs.libglvnd}/lib" \
        --prefix LIBGL_DRIVERS_PATH : "/usr/lib64/dri" \
        --prefix GBM_BACKENDS_PATH : "/usr/lib64/gbm:${pkgs.mesa}/lib/gbm" \
        --prefix __EGL_VENDOR_LIBRARY_DIRS : "/usr/share/glvnd/egl_vendor.d" \
        --prefix QT_PLUGIN_PATH : "${pkgs.qt6.qtbase}/lib/qt-6/plugins:${pkgs.qt6.qtwayland}/lib/qt-6/plugins:${pkgs.qt6.qtsvg}/lib/qt-6/plugins:${pkgs.qt6.qtpositioning}/lib/qt-6/plugins"
    '';
  };
in
lib.mkIf pkgs.stdenv.isLinux {
  home.packages = with pkgs; [
    wrappedQuickshell
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qt5compat
    qt6.qtsvg
    qt6.qtwayland
    qt6.qtmultimedia
    qt6.qtimageformats
    qt6.qtpositioning
    kdePackages.kirigami
    kdePackages.syntax-highlighting
    socat
    playerctl
    libnotify
    brightnessctl
    wireplumber
    libqalculate
    hyprpicker
    wf-recorder
    tesseract
    fuzzel
    ydotool
    material-symbols
    rubik
    hyprshot
    swappy
    upower
    wtype
    songrec
    translate-shell
    wlogout
    hypridle
    hyprsunset
    ddcutil
  ];

  home.sessionVariables = {
    QML2_IMPORT_PATH = "$HOME/.nix-profile/lib/qt-6/qml:$HOME/.local/state/nix/profiles/home-manager/home-path/lib/qt-6/qml";
    QT_PLUGIN_PATH = "$HOME/.nix-profile/lib/qt-6/plugins:$HOME/.local/state/nix/profiles/home-manager/home-path/lib/qt-6/plugins";
    qsConfig = "end4-pC";
  };

  home.file = {
    ".config/hypr/hyprland.lua".source = "${illogicalImpulse}/dots/.config/hypr/hyprland.lua";
    ".config/hypr/hyprland".source = "${illogicalImpulse}/dots/.config/hypr/hyprland";
    ".config/hypr/hypridle.conf".source = "${illogicalImpulse}/dots/.config/hypr/hypridle.conf";
    ".config/hypr/hyprlock.conf".text = ''
      # Material You Glassmorphism Hyprlock
      background {
          monitor =
          path = screenshot
          blur_passes = 3
          blur_size = 7
          noise = 0.0117
          contrast = 0.8916
          brightness = 0.8172
          vibrancy = 0.1696
          vibrancy_darkness = 0.0
      }

      # Input field with Material You pill design
      input-field {
          monitor =
          size = 280, 56
          outline_thickness = 2
          dots_size = 0.25
          dots_spacing = 0.3
          dots_center = true
          dots_rounding = -1
          outer_color = rgba(255, 255, 255, 0.25)
          inner_color = rgba(20, 20, 25, 0.65)
          font_color = rgba(255, 255, 255, 0.95)
          fade_on_empty = false
          placeholder_text = <span foreground="##ffffff88"><i>  Contraseña...</i></span>
          hide_input = false
          rounding = 28
          check_color = rgba(124, 77, 255, 0.8)
          fail_color = rgba(239, 83, 80, 0.8)
          fail_text = <i>$FAIL <b>($ATTEMPTS)</b></i>
          fail_transition = 300
          capslock_color = rgba(255, 179, 0, 0.8)
          numlock_color = -1
          bothlock_color = -1
          invert_numlock = false
          swap_font_color = false

          position = 0, -80
          halign = center
          valign = center
      }

      # Big Material Clock
      label {
          monitor =
          text = $TIME
          color = rgba(255, 255, 255, 0.95)
          font_size = 90
          font_family = Google Sans Flex, Space Grotesk, sans-serif
          shadow_passes = 3
          shadow_size = 4
          shadow_color = rgba(0, 0, 0, 0.4)

          position = 0, 180
          halign = center
          valign = center
      }

      # Date Label
      label {
          monitor =
          text = cmd[update:43200000] date +"%A, %d de %B"
          color = rgba(255, 255, 255, 0.85)
          font_size = 20
          font_family = Google Sans Flex, Space Grotesk, sans-serif
          shadow_passes = 2
          shadow_size = 3
          shadow_color = rgba(0, 0, 0, 0.3)

          position = 0, 100
          halign = center
          valign = center
      }

      # User greeting
      label {
          monitor =
          text = Hola, $USER
          color = rgba(255, 255, 255, 0.9)
          font_size = 18
          font_family = Google Sans Flex, Space Grotesk, sans-serif
          shadow_passes = 2
          shadow_size = 2

          position = 0, 0
          halign = center
          valign = center
      }

      # Keyboard Layout indicator
      label {
          monitor =
          text =   $LAYOUT
          color = rgba(255, 255, 255, 0.6)
          font_size = 13
          font_family = JetBrains Mono NF, monospace

          position = 30, 30
          halign = left
          valign = bottom
      }
    '';
    ".config/hypr/hyprlock".source = "${illogicalImpulse}/dots/.config/hypr/hyprlock";
    ".config/hypr/custom/env.lua".text = ''
      local home_dir = os.getenv("HOME")
      hl.env("PATH", home_dir .. "/.local/state/nix/profiles/home-manager/home-path/bin:" .. home_dir .. "/.nix-profile/bin:/usr/local/bin:/usr/bin:/bin:" .. (os.getenv("PATH") or ""))
      hl.env("qsConfig", "end4-pC")
    '';
    ".config/hypr/custom/variables.lua".text = ''
      hl.env("qsConfig", "end4-pC")
    '';
    ".config/hypr/custom/execs.lua".text = ''
      -- Custom execs
    '';
    ".config/hypr/custom/general.lua".text = ''
      hl.config({
          input = {
              kb_layout = "us",
              kb_variant = "altgr-intl",
              follow_mouse = 1,
              touchpad = {
                  natural_scroll = true,
              },
          },
      })
    '';
    ".config/quickshell/ii".source = patchedEnd4pC;
    ".config/quickshell/end4-pC".source = patchedEnd4pC;
    ".config/quickshell/illogical-impulse".source = patchedEnd4pC;
    ".local/bin/qs".source = "${wrappedQuickshell}/bin/qs";
  };
}
