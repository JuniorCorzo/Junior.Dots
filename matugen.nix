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

    # 1. Generate colors with Matugen non-interactively
    echo "🎨 Generating Material You palette with Matugen..."
    matugen image --source-color-index 0 "$WALLPAPER"

    # 2. Update wallpaper with swaybg
    mkdir -p "$HOME/.config/hypr"
    echo "$WALLPAPER" > "$HOME/.config/hypr/current_wallpaper"

    pkill -x swaybg 2>/dev/null || true
    swaybg -i "$WALLPAPER" -m fill &

    echo "✨ Theme and wallpaper updated successfully!"
  '';

  wallselect = pkgs.writeShellScriptBin "wallselect" ''
    #!/usr/bin/env bash
    set -euo pipefail

    WALL_DIRS=(
      "$HOME/wallpapers"
      "$HOME/Imágenes/wallpapers"
      "$HOME/Pictures/wallpapers"
    )

    IMAGES=()
    for dir in "''${WALL_DIRS[@]}"; do
      if [ -d "$dir" ]; then
        while IFS= read -r -d $'\0' file; do
          IMAGES+=("$file")
        done < <(find "$dir" -maxdepth 2 -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" -o -name "*.webp" \) -print0 2>/dev/null)
      fi
    done

    if [ ''${#IMAGES[@]} -eq 0 ]; then
      notify-send "Wallpapers" "No se encontraron fondos en ~/wallpapers" 2>/dev/null || true
      exit 0
    fi

    ROFI_INPUT=""
    for img in "''${IMAGES[@]}"; do
      filename=$(basename "$img")
      ROFI_INPUT+="''${filename}\0icon\x1f''${img}\n"
    done

    SELECTED=$(echo -en "$ROFI_INPUT" | rofi -dmenu -i -p "󰸉 Fondo" -show-icons 2>/dev/null || true)

    if [ -n "$SELECTED" ]; then
      for img in "''${IMAGES[@]}"; do
        if [ "$(basename "$img")" = "$SELECTED" ]; then
          wallchange "$img"
          break
        fi
      done
    fi
  '';
in
{
  home.packages = [
    pkgs.matugen
    pkgs.swaybg
    wallchange
    wallselect
  ];

  home.file = {
    ".config/matugen/config.toml".source = ./matugen/config.toml;
    ".config/matugen/templates/hyprland-colors.conf".source = ./matugen/templates/hyprland-colors.conf;
    ".config/matugen/templates/hyprland-colors.lua".source = ./matugen/templates/hyprland-colors.lua;
    ".config/matugen/templates/rofi-colors.rasi".source = ./matugen/templates/rofi-colors.rasi;
    ".config/matugen/templates/alacritty-colors.toml".source = ./matugen/templates/alacritty-colors.toml;
    ".config/matugen/templates/kitty-colors.conf".source = ./matugen/templates/kitty-colors.conf;
  };
}
