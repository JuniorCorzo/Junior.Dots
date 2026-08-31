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

  wrappedQuickshell = pkgs.symlinkJoin {
    name = "quickshell-wrapped";
    paths = [ pkgs.quickshell ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/qs \
        --prefix QML2_IMPORT_PATH : "${pkgs.qt6.qt5compat}/lib/qt-6/qml:${pkgs.qt6.qtdeclarative}/lib/qt-6/qml:${pkgs.qt6.qtsvg}/lib/qt-6/qml:${pkgs.qt6.qtwayland}/lib/qt-6/qml:${pkgs.qt6.qtmultimedia}/lib/qt-6/qml:${pkgs.qt6.qtpositioning}/lib/qt-6/qml:${pkgs.kdePackages.kirigami}/lib/qt-6/qml:${pkgs.kdePackages.syntax-highlighting}/lib/qt-6/qml" \
        --prefix LD_LIBRARY_PATH : "${pkgs.qt6.qtbase}/lib:${pkgs.qt6.qtdeclarative}/lib:${pkgs.qt6.qtwayland}/lib:${pkgs.qt6.qt5compat}/lib:${pkgs.qt6.qtpositioning}/lib:${pkgs.qt6.qtsvg}/lib:${pkgs.qt6.qtmultimedia}/lib:${pkgs.kdePackages.kirigami}/lib:${pkgs.kdePackages.syntax-highlighting}/lib:${pkgs.libGL}/lib:${pkgs.mesa}/lib:${pkgs.libglvnd}/lib:${pkgs.mesa.drivers}/lib" \
        --prefix LIBGL_DRIVERS_PATH : "/usr/lib64/dri" \
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
    ".config/hypr/hyprlock.conf".source = "${illogicalImpulse}/dots/.config/hypr/hyprlock.conf";
    ".config/hypr/hyprlock".source = "${illogicalImpulse}/dots/.config/hypr/hyprlock";
    ".config/hypr/custom".source = "${illogicalImpulse}/dots/.config/hypr/custom";
    ".config/quickshell/end4-pC".source = end4pC;
    ".config/quickshell/illogical-impulse".source = "${illogicalImpulse}/dots/.config/quickshell";
  };
}
