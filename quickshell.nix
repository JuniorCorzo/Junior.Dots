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
                icon: "folder"
                pixelSize: Math.min(parent.width, parent.height) * 0.5
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
    ".config/hypr/hyprlock.conf".source = "${illogicalImpulse}/dots/.config/hypr/hyprlock.conf";
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
      hl.on("hyprland.start", function ()
          hl.exec_cmd("hypr-quickshell-start")
      end)
    '';
    ".config/quickshell/ii".source = patchedEnd4pC;
    ".config/quickshell/end4-pC".source = patchedEnd4pC;
    ".config/quickshell/illogical-impulse".source = patchedEnd4pC;
    ".local/bin/qs".source = "${wrappedQuickshell}/bin/qs";
  };
}
