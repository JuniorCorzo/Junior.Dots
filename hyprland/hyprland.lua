-- Hyprland Lua Configuration (Aylur Architecture)

-- Monitor
hl.exec_cmd("hyprctl keyword monitor ,preferred,auto,1")

-- Autostart (guarded against duplicate instances on reload)
hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP PATH")
hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP PATH")
hl.exec_cmd("pgrep -x waybar >/dev/null || waybar &")
hl.exec_cmd("pgrep -x swaync >/dev/null || swaync &")
hl.exec_cmd("pgrep -x wl-paste >/dev/null || wl-paste --watch cliphist store &")

-- Layout & Decoration
hl.config({
    general = {
        gaps_in = 4,
        gaps_out = 8,
        border_size = 2,
        ["col.active_border"] = "rgba(7c4dffff)",
        ["col.inactive_border"] = "rgba(222222aa)",
        layout = "dwindle",
        resize_on_border = true
    },
    decoration = {
        rounding = 10,
        active_opacity = 1.0,
        inactive_opacity = 0.92,
        blur = {
            enabled = true,
            size = 6,
            passes = 2,
            xray = true
        },
        shadow = {
            enabled = true,
            range = 20,
            render_power = 3
        }
    },
    animations = {
        enabled = true,
        bezier = {
            "easeOutQuint, 0.23, 1, 0.32, 1",
            "easeInOutCubic, 0.65, 0.05, 0.36, 1",
            "overshoot, 0.05, 0.9, 0.1, 1.05"
        },
        animation = {
            "windows, 1, 4, easeOutQuint",
            "windowsOut, 1, 3, easeInOutCubic, popin 80%",
            "windowsMove, 1, 4, easeOutQuint",
            "fade, 1, 3, easeInOutCubic",
            "workspaces, 1, 4, easeOutQuint, slide"
        }
    },
    dwindle = {
        preserve_split = true
    },
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true
    }
})

local mainMod = "SUPER"

-- Keybindings
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd("alacritty"), { description = "Terminal" })
hl.bind(mainMod .. " + SHIFT + RETURN", hl.dsp.exec_cmd("kitty"), { description = "Kitty Terminal" })
hl.bind(mainMod .. " + Q", hl.dsp.window.close(), { description = "Close active window" })
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("nautilus"), { description = "File manager" })
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("rofi -show drun || wofi --show drun"), { description = "Launcher" })
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("wallselect"), { description = "Wallpaper selector" })
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("killall waybar || waybar"), { description = "Toggle Waybar" })
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }), { description = "Fullscreen" })
hl.bind(mainMod .. " + T", hl.dsp.window.float({ action = "toggle" }), { description = "Float window" })

-- Focus
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }), { description = "Focus left" })
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }), { description = "Focus right" })
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }), { description = "Focus up" })
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }), { description = "Focus down" })
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }), { description = "Focus left" })
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }), { description = "Focus right" })
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }), { description = "Focus up" })
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }), { description = "Focus down" })

-- Workspaces
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }), { description = "Focus workspace " .. i })
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }), { description = "Move to workspace " .. i })
end

-- Mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Move window" })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Resize window" })
