# Design Spec: end4-pC Integration, Wallpaper Sync & Notification Layout Fix

**Date**: 2026-09-07  
**Status**: Approved / Ready for Plan  
**Scope**: Hyprland & QuickShell (`quickshell.nix`, `hyprland.nix`, `matugen.nix`, `patchedEnd4pC`)

---

## 1. Context & Motivation

Gentleman.Dots uses QuickShell (`qs`) with the `end4-pC` panel family (fork of `end-4/dots-hyprland`) on Linux/Hyprland. Two major visual and functional regressions are present:
1. **Wallpaper Desynchronization**: Changing wallpapers inside QuickShell updates only QuickShell's internal QML background layer. Hyprland (and `swaybg`) is unaware of the change, does not update `~/.config/hypr/current_wallpaper`, and does not regenerate dynamic Material You colors with `matugen`.
2. **Notification Layout Collision**: In the right sidebar (`SidebarRight`), the notification container (`CenterWidgetGroup`) lacks boundary clipping and minimum height constraints in the vertical `ColumnLayout`. When multiple notifications arrive or when bottom widgets (`BottomWidgetGroup`) expand, notifications overflow and collide with other sidebar widgets.
3. **Missing `end4-pC` Runtime Tooling**: Several shell scripts in `end4-pC` require CLI utilities (`bc`, `imagemagick`, `ffmpeg`, `mpvpaper`) that are absent from Nix home packages.

---

## 2. Architecture & Detailed Changes

### 2.1 Wallpaper Synchronization (`Wallpapers.qml` & `hyprland.nix`)

#### Components & Data Flow:
```
QuickShell UI (WallpaperSelector)
     │
     ▼
services/Wallpapers.qml :: apply(path)
     │
     ├──► Quickshell.execDetached(["wallchange", path])
     │         │
     │         ├──► matugen image "$WALLPAPER" (generates hyprland-colors, alacritty, kitty)
     │         ├──► echo "$WALLPAPER" > ~/.config/hypr/current_wallpaper
     │         └──► swaybg -i "$WALLPAPER" -m fill &
     │
     └──► Quickshell.execDetached([switchwall.sh, "--mode", mode, "--image", path])
```

#### Modifications:
1. **`quickshell.nix` (`patchedEnd4pC`)**:
   Add substitution in `services/Wallpapers.qml`:
   Inside `function apply(path, darkMode = Appearance.m3colors.darkmode)`:
   Trigger `Quickshell.execDetached(["wallchange", path]);` alongside `wallpaperSwitchScriptPath`.
2. **`hyprland.nix` (`exec-once`)**:
   Ensure `swaybg` restores the active wallpaper on Hyprland startup:
   `"bash -c '[ -f ~/.config/hypr/current_wallpaper ] && swaybg -i \"$(cat ~/.config/hypr/current_wallpaper)\" -m fill'"`

---

### 2.2 Notification Overflow & Layout Fix (`SidebarRightContent.qml`, `CenterWidgetGroup.qml`)

#### Root Cause:
`SidebarRightContent.qml` uses a `ColumnLayout` containing:
- Banner / System Buttons (~180px / 40px)
- Quick Toggles (~140px)
- Sliders (~80px)
- Media Player (~160px)
- `CenterWidgetGroup` (`Layout.fillHeight: true`, no `minimumHeight`)
- `BottomWidgetGroup` (350px when expanded)

Total fixed height exceeds available display height. When `BottomWidgetGroup` expands:
1. `CenterWidgetGroup` is crushed to less than 50px.
2. `CenterWidgetGroup.qml` has `clip: false` by default, so delegates spill outside.
3. `NotificationListView` delegates render on top of `BottomWidgetGroup` and sliders.

#### Modifications:
1. **`CenterWidgetGroup.qml`**:
   - Enable `clip: true` on root `Rectangle`.
   - Set `Layout.minimumHeight: 120`.
2. **`SidebarRightContent.qml`**:
   - Ensure `CenterWidgetGroup` has `Layout.fillHeight: true` and `Layout.minimumHeight: 120`.
   - When height is constrained, `NotificationListView` must scroll cleanly within its boundaries instead of bursting out.

---

### 2.3 `end4-pC` Parity & Runtime Dependencies

#### Modifications in `quickshell.nix`:
Add required tools to `home.packages`:
- `pkgs.bc`: Used by `switchwall.sh` for screen coordinate math.
- `pkgs.imagemagick`: Provides `identify` for resolution checks and magick thumbnailing.
- `pkgs.ffmpeg`: Video wallpaper frame extraction.
- `pkgs.mpvpaper`: Video wallpaper playback engine on Wayland.

---

## 3. Verification & Validation Plan

1. **Nix Flake Check**: Run `nix flake check` to verify syntax and flake integrity.
2. **QuickShell Build Check**: Validate `patchedEnd4pC` derivation build via Nix.
3. **Wallpaper Sync Test**:
   - Trigger `qs -c end4-pC ipc call wallpapers apply "<path-to-image>"`.
   - Verify `swaybg` process is updated and `~/.config/hypr/current_wallpaper` contains the target image path.
4. **Notification Layout Test**:
   - Emit test notifications via `notify-send "Test" "Message body"`.
   - Open right sidebar (`SUPER+N`), expand bottom widget group, and verify notifications remain clipped and scrollable without overlapping other widgets.
