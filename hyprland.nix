{ pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = pkgs.stdenv.isLinux;
    package = null;
    systemd.enable = false;
    configType = "lua";
    plugins = [];
    settings = {};
    extraConfig = "";
  };

  xdg.portal = {
    enable = pkgs.stdenv.isLinux;
    config = {
      common.default = "*";
      hyprland.default = [ "hyprland" "gtk" ];
    };
  };

  home.packages = [
    pkgs.grim
    pkgs.slurp
    pkgs.wl-clipboard
    pkgs.jq
    pkgs.brightnessctl
    pkgs.playerctl
  ];
}
