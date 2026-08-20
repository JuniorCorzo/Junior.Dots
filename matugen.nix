{ pkgs, lib, ... }:

let
  wallchange = pkgs.writeShellScriptBin "wallchange" ''
    #!/usr/bin/env bash
    set -euo pipefail

    if [ -z "''${1:-}" ]; then
      echo "Usage: wallchange <path-to-image>"
      exit 1
    fi

    WALLPAPER="$1"

    if [ ! -f "$WALLPAPER" ]; then
      echo "Error: File '$WALLPAPER' does not exist."
      exit 1
    fi

    # 1. Generate colors with Matugen
    echo "🎨 Generating Material You palette with Matugen..."
    matugen image "$WALLPAPER"

    # 2. Update wallpaper with hyprpaper or swww if available
    if command -v swww &>/dev/null; then
      swww img "$WALLPAPER" --transition-type grow --transition-pos 0.5,0.5 --transition-fps 60
    elif command -v hyprctl &>/dev/null; then
      hyprctl hyprpaper preload "$WALLPAPER" 2>/dev/null || true
      hyprctl hyprpaper wallpaper ",$WALLPAPER" 2>/dev/null || true
    fi

    echo "✨ Theme updated successfully!"
  '';
in
{
  home.packages = [
    pkgs.matugen
    wallchange
  ];

  home.file = {
    ".config/matugen/config.toml".source = ./matugen/config.toml;
    ".config/matugen/templates/hyprland-colors.conf".source = ./matugen/templates/hyprland-colors.conf;
    ".config/matugen/templates/waybar-colors.css".source = ./matugen/templates/waybar-colors.css;
    ".config/matugen/templates/alacritty-colors.toml".source = ./matugen/templates/alacritty-colors.toml;
    ".config/matugen/templates/kitty-colors.conf".source = ./matugen/templates/kitty-colors.conf;
  };
}
