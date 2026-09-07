# end4-pC Integration, Wallpaper Sync & Notification Layout Fix Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix wallpaper desynchronization between QuickShell and Hyprland, fix notification layout overflow in the right sidebar menu, and complete runtime CLI dependencies for `end4-pC`.

**Architecture:** QuickShell's `services/Wallpapers.qml` will be patched to trigger `wallchange` concurrently with wallpaper selection, while Hyprland's `exec-once` will restore the saved wallpaper with `swaybg`. The right sidebar's `CenterWidgetGroup` and `SidebarRightContent` will be patched with strict clipping and layout boundaries (`Layout.minimumHeight: 120`). `quickshell.nix` packages will be extended with missing tools (`bc`, `imagemagick`, `ffmpeg`, `mpvpaper`).

**Tech Stack:** Nix, Home Manager, QuickShell (QML / Qt6), Hyprland, Swaybg, Matugen, Bash.

**Spec:** [`docs/superpowers/specs/2026-09-07-end4-pc-integration-fixes-design.md`](file:///home/juniorcorzo/Gentleman.Dots/docs/superpowers/specs/2026-09-07-end4-pc-integration-fixes-design.md)

## Global Constraints

- Must follow Nix code style guidelines in `conventions.md` (2 spaces, kebab-case, platform guards with `pkgs.stdenv.isLinux`).
- All shell commands must be prefixed with `rtk`.
- Every Nix modification must pass `nix flake check`.
- Use Conventional Commits (`fix(quickshell): ...`, `fix(hyprland): ...`).

---

### Task 1: Integrate `wallchange` in QuickShell & Hyprland Wallpaper Autostart

**Files:**
- Modify: `quickshell.nix:68-71`
- Modify: `hyprland.nix:28-35`

**Interfaces:**
- Consumes: `wallchange` binary from `matugen.nix` (`~/.local/state/nix/profiles/home-manager/home-path/bin/wallchange`).
- Produces: Persistent wallpaper synchronization across QuickShell, Hyprland (`swaybg`), and Matugen theme colors.

- [ ] **Step 1: Inspect `services/Wallpapers.qml` in `patchedEnd4pC` to verify replacement target**

Run:
```bash
grep -n "wallpaperSwitchScriptPath" /nix/store/*-end4-pC-patched/services/Wallpapers.qml
```
Expected: Line matching `Quickshell.execDetached([Directories.wallpaperSwitchScriptPath...`

- [ ] **Step 2: Add patch in `quickshell.nix` to invoke `wallchange` inside `apply(path)`**

Add patch #5 inside `patchedEnd4pC` derivation in `quickshell.nix`:
```nix
    # 5. Integrate wallchange in Wallpapers.qml apply function
    substituteInPlace $out/services/Wallpapers.qml \
      --replace-fail 'Quickshell.execDetached([Directories.wallpaperSwitchScriptPath' \
                     'Quickshell.execDetached(["wallchange", path]);
        Quickshell.execDetached([Directories.wallpaperSwitchScriptPath'
```

- [ ] **Step 3: Update `hyprland.nix` `exec-once` to restore wallpaper with `swaybg`**

In `hyprland.nix`, add to `exec-once`:
```nix
        "bash -c '[ -f $HOME/.config/hypr/current_wallpaper ] && swaybg -i \"$(cat $HOME/.config/hypr/current_wallpaper)\" -m fill'"
```

- [ ] **Step 4: Verify Nix flake syntax and evaluate derivation**

Run:
```bash
nix flake check
nix eval .#homeConfigurations.gentleman-linux.config.home.file.\".config/quickshell/end4-pC\".source.outPath
```
Expected: Flake checks pass and derivation evaluates with exit code 0.

- [ ] **Step 5: Commit changes**

```bash
rtk git add quickshell.nix hyprland.nix
rtk git commit -m "fix(quickshell): trigger wallchange on wallpaper selection and restore swaybg on hyprland start"
```

---

### Task 2: Fix Notification Overflow & Clipping in SidebarRight

**Files:**
- Modify: `quickshell.nix:68-71`

**Interfaces:**
- Consumes: QuickShell `ColumnLayout` and `CenterWidgetGroup.qml` / `SidebarRightContent.qml`.
- Produces: Contained, scrollable notification list that never overlaps with adjacent widgets.

- [ ] **Step 1: Verify exact replacement blocks in `CenterWidgetGroup.qml` and `SidebarRightContent.qml`**

Run:
```bash
grep -n "color: Appearance.colors.colLayer1" /nix/store/*-end4-pC-patched/modules/ii/sidebarRight/CenterWidgetGroup.qml
grep -n -A 5 "CenterWidgetGroup {" /nix/store/*-end4-pC-patched/modules/ii/sidebarRight/SidebarRightContent.qml
```
Expected: Pattern exists and matches exactly.

- [ ] **Step 2: Add patches #6 and #7 to `patchedEnd4pC` in `quickshell.nix`**

In `quickshell.nix`, add:
```nix
    # 6. Enable clipping and minimum height on CenterWidgetGroup
    substituteInPlace $out/modules/ii/sidebarRight/CenterWidgetGroup.qml \
      --replace-fail 'color: Appearance.colors.colLayer1' \
                     'color: Appearance.colors.colLayer1
    clip: true
    Layout.minimumHeight: 120'

    # 7. Add minimum height constraint to CenterWidgetGroup in SidebarRightContent
    substituteInPlace $out/modules/ii/sidebarRight/SidebarRightContent.qml \
      --replace-fail 'CenterWidgetGroup {
                Layout.alignment: Qt.AlignHCenter
                Layout.fillHeight: true
                Layout.fillWidth: true
            }' \
                     'CenterWidgetGroup {
                Layout.alignment: Qt.AlignHCenter
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.minimumHeight: 120
            }'
```

- [ ] **Step 3: Validate `patchedEnd4pC` builds cleanly with substitutions applied**

Run:
```bash
nix build .#homeConfigurations.gentleman-linux.config.home.file.\".config/quickshell/end4-pC\".source --no-link
```
Expected: Build succeeds with 0 errors.

- [ ] **Step 4: Commit changes**

```bash
rtk git add quickshell.nix
rtk git commit -m "fix(quickshell): prevent notification overflow in sidebar menu with clipping and minimum height"
```

---

### Task 3: Add Missing `end4-pC` CLI Dependencies

**Files:**
- Modify: `quickshell.nix:89-125`

**Interfaces:**
- Consumes: Nixpkgs `bc`, `imagemagick`, `ffmpeg`, `mpvpaper`.
- Produces: Full feature availability for `end4-pC` scripts (`switchwall.sh`, thumbnail generation, video wallpapers).

- [ ] **Step 1: Check availability of packages in nixpkgs**

Run:
```bash
nix eval --raw nixpkgs#bc.name
nix eval --raw nixpkgs#imagemagick.name
nix eval --raw nixpkgs#ffmpeg.name
nix eval --raw nixpkgs#mpvpaper.name
```
Expected: Each prints package name without error.

- [ ] **Step 2: Add `bc`, `imagemagick`, `ffmpeg`, and `mpvpaper` to `home.packages` in `quickshell.nix`**

In `quickshell.nix`:
```nix
    imagemagick
    bc
    ffmpeg
    mpvpaper
```

- [ ] **Step 3: Verify syntax with `nix flake check`**

Run:
```bash
nix flake check
```
Expected: Checks pass with exit code 0.

- [ ] **Step 4: Commit changes**

```bash
rtk git add quickshell.nix
rtk git commit -m "feat(quickshell): add bc, imagemagick, ffmpeg, and mpvpaper for end4-pC parity"
```

---

### Task 4: Full System Verification & Home Manager Build Check

**Files:**
- Test target: `.#homeConfigurations.gentleman-linux.activationPackage`

- [ ] **Step 1: Build the Linux Home Manager configuration**

Run:
```bash
nix build .#homeConfigurations.gentleman-linux.activationPackage --no-link
```
Expected: Derivation builds successfully.

- [ ] **Step 2: Verify git working tree is clean**

Run:
```bash
rtk git status
```
Expected: Clean working tree, nothing uncommitted.
