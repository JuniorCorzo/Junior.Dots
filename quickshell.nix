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
in
lib.mkIf pkgs.stdenv.isLinux {
  home.packages = with pkgs; [
    quickshell
    qt6.qtbase
    qt6.qtdeclarative
    socat
    playerctl
    libnotify
    brightnessctl
    wireplumber
    libqalculate
  ];

  home.file = {
    ".config/quickshell/end4-pC".source = end4pC;
    ".config/quickshell/illogical-impulse".source = "${illogicalImpulse}/dots/.config/quickshell";
  };
}
