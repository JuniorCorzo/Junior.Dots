{ pkgs, ... }:

{
  programs.rofi = {
    enable = pkgs.stdenv.isLinux;
    package = pkgs.rofi;
    font = "JetBrainsMono Nerd Font 12";
    theme = "${./rofi/theme.rasi}";
    extraConfig = {
      modi = "drun,run,filebrowser,window";
      show-icons = true;
      display-drun = " Apps";
      display-run = " Run";
      display-filebrowser = " Files";
      display-window = " Windows";
      drun-display-format = "{name}";
      hover-select = true;
    };
  };
}
