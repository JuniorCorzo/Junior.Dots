{ pkgs, spicetify, ... }:
let
  spicePkgs = spicetify.legacyPackages.${pkgs.system};
in
{
  programs.spicetify = {
    enable = true;

    theme = spicePkgs.themes.catppuccin;
    colorScheme = "mocha";

    enabledExtensions = with spicePkgs.extensions; [
      adblock
      shuffle
    ];
  };
}
