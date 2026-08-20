{ pkgs, ... }:

{
  programs.waybar = {
    enable = pkgs.stdenv.isLinux;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        margin-top = 8;
        margin-left = 12;
        margin-right = 12;
        margin-bottom = 0;
        spacing = 8;

        modules-left = [
          "hyprland/workspaces"
        ];

        modules-center = [
          "hyprland/window"
        ];

        modules-right = [
          "pulseaudio"
          "network"
          "battery"
          "tray"
          "clock"
        ];

        "hyprland/workspaces" = {
          on-click = "activate";
          format = "{name}";
          active-only = false;
          all-outputs = true;
          persistent-workspaces = {
            "*" = 5;
          };
        };

        "hyprland/window" = {
          max-length = 50;
          separate-outputs = true;
          format = "{}";
          rewrite = {
            "^$" = "󰣛 Desktop";
            "(.*) — Mozilla Firefox" = "󰈹 $1";
            "(.*) - Google Chrome" = " $1";
            "(.*) - Visual Studio Code" = "󰨞 $1";
            "(.*) - Alacritty" = " $1";
            "(.*) - Kitty" = " $1";
          };
        };

        "pulseaudio" = {
          format = "{icon} {volume}%";
          format-muted = "󰝟 Muted";
          format-icons = {
            default = [ "󰕿" "󰖀" "󰕾" ];
          };
          on-click = "pavucontrol || wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        };

        "network" = {
          format-wifi = "󰤨 {essid}";
          format-ethernet = "󰈀 Ethernet";
          format-disconnected = "󰤭 Disconnected";
          tooltip-format = "{ifname}: {ipaddr}";
        };

        "battery" = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-plugged = "󰂄 {capacity}%";
          format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
        };

        "clock" = {
          format = "󰃭 {:%a %d %b  󰥔 %H:%M}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
        };

        "tray" = {
          icon-size = 18;
          spacing = 10;
        };
      };
    };

    style = ''
      @import "colors.css";

      * {
        font-family: "IosevkaTerm Nerd Font", "JetBrainsMono Nerd Font", Roboto, sans-serif;
        font-size: 13px;
        font-weight: bold;
        min-height: 0;
      }

      window#waybar {
        background: transparent;
        color: @on_surface;
      }

      #workspaces {
        background-color: @surface;
        padding: 2px 4px;
        border-radius: 12px;
        border: 1px solid @outline;
      }

      #workspaces button {
        padding: 4px 10px;
        margin: 2px 3px;
        border-radius: 8px;
        color: @on_surface;
        background: transparent;
        border: none;
        transition: all 0.2s ease-in-out;
      }

      #workspaces button.active {
        background-color: @primary;
        color: @on_primary;
        border-radius: 8px;
      }

      #workspaces button:hover {
        background-color: @primary_container;
        color: @on_primary_container;
      }

      #window {
        background-color: @surface;
        color: @primary;
        padding: 4px 16px;
        border-radius: 12px;
        border: 1px solid @outline;
      }

      #pulseaudio,
      #network,
      #battery,
      #tray,
      #clock {
        background-color: @surface;
        color: @on_surface;
        padding: 4px 14px;
        border-radius: 12px;
        border: 1px solid @outline;
        margin-left: 4px;
      }

      #clock {
        color: @primary;
      }

      #battery.charging, #battery.plugged {
        color: @primary;
      }

      #battery.warning:not(.charging) {
        color: @error;
      }

      #battery.critical:not(.charging) {
        background-color: @error;
        color: @surface;
      }
    '';
  };
}
