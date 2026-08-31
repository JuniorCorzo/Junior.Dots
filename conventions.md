# Conventions Guide for Gentleman.Dots

This document defines the architecture principles, code style rules, shell standards, and commit conventions for the **Gentleman.Dots** declarative configuration repository.

---

## 1. Repository Architecture & Design Principles

Gentleman.Dots uses **Nix Flakes** combined with **Home Manager** to manage multi-platform developer environments across macOS (Apple Silicon & Intel) and Linux (Wayland/Hyprland).

### 1.1 Core Architecture Principles

1. **Declarative & Reproducible**: All user configurations, tools, fonts, and dotfiles must be declaratively expressed via Nix Flakes or symlinked/copied via Home Manager.
2. **Multi-Platform Support**:
   - macOS: `aarch64-darwin` (Apple Silicon - default `.#gentleman`), `x86_64-darwin` (Intel - `.#gentleman-macos-intel`).
   - Linux: `x86_64-linux` (Fedora/Arch Wayland environment - `.#gentleman-linux`).
3. **Modularity & Single Responsibility**:
   - Each tool/service configuration resides in its own module: `<tool>.nix` at root (e.g., `hyprland.nix`, `fish.nix`, `nvim.nix`).
   - Application-specific raw configs reside in designated subdirectories (e.g., `nvim/`, `fish/`, `nushell/`, `hyprland/`, `matugen/`, `scripts/`).
4. **Separation of System vs. User Management**:
   - System/GPU-level packages (e.g., system Hyprland, display managers, Homebrew daemons) remain managed by system package managers when necessary.
   - Userland CLI tools, runtimes, editors, and shell environments are managed via Nix/Home Manager.

---

## 2. Nix Code Style Guidelines (`.nix`)

### 2.1 File Naming & Structure
- Use `kebab-case` for all Nix files (e.g., `oil-scripts.nix`, `tmux-agents.nix`, `simple-bar.nix`).
- Standard module signature:
  ```nix
  { pkgs, lib, unstablePkgs, ... }:
  {
    # Configuration attributes
  }
  ```

### 2.2 Formatting & Syntax
- **Indentation**: 2 spaces (no tabs).
- **Line Length**: Soft wrap at 100-120 characters where readable.
- **Attributes**: Group related attributes logically; use semicolon termination for every attribute statement.
- **Paths**: Use relative paths (`./relative/path` or `${toString ./subdir}`) rather than string literals or hardcoded `/home/...` paths.

### 2.3 Conditionals & Platform Checks
- Always guard platform-specific configurations using Nix conditional helpers:
  - Linux checks: `pkgs.stdenv.isLinux`
  - macOS checks: `pkgs.stdenv.isDarwin`
  - Architecture checks: `pkgs.stdenv.hostPlatform.isAarch64`, `pkgs.stdenv.hostPlatform.isx86_64`
- Use `lib.mkIf` or conditional attribute sets:
  ```nix
  wayland.windowManager.hyprland = {
    enable = pkgs.stdenv.isLinux;
    # ...
  };
  ```

### 2.4 Package Management & Overrides
- Pin dependencies using `inputs.nixpkgs.follows` in `flake.nix`.
- Clearly distinguish stable (`pkgs`) vs bleeding-edge (`unstablePkgs`) packages.
- Always handle unfree packages explicitly with `allowUnfree = true`.
- Prefer standalone runtime builds (e.g., `nodeWithoutNpm` custom derivations) when preventing package manager collisions.

---

## 3. Lua Code Style Guidelines (`.lua` / Neovim)

Neovim configurations in `nvim/` follow strict LazyVim / modern Neovim standards.

### 3.1 Formatting & Style Rules (StyLua)
- Follow the project's `nvim/stylua.toml`:
  - `indent_type`: `"Spaces"`
  - `indent_width`: `2`
  - `column_width`: `120`
- **Naming Conventions**:
  - Variables and functions: `snake_case` (e.g., `local file_path = ...`, `function setup_buffer()`).
  - Module/Class names: `PascalCase` or `snake_case` table namespaces.
  - Constants: `UPPER_SNAKE_CASE` (e.g., `MAX_RETRY_COUNT = 3`).

### 3.2 Neovim Lua Best Practices
- **API Usage**:
  - Use `vim.keymap.set({ "n", "v" }, "<leader>f", ...)` instead of `vim.api.nvim_set_keymap()` or `vim.cmd("map ...")`.
  - Use `vim.api.nvim_create_autocmd()` and `vim.api.nvim_create_augroup()` for autocmds.
  - Use `vim.opt` / `vim.g` for editor settings.
  - Avoid raw `vim.cmd()` strings for logic that can be expressed in pure Lua.
- **Modularity & Lazy Loading**:
  - Keep plugin specs modular under `nvim/lua/plugins/*.lua`.
  - Use lazy-loading triggers (`event`, `cmd`, `ft`, `keys`) to ensure sub-50ms startup times.
  - Never place global side effects at the top level of plugin files outside the `config` or `opts` functions.

---

## 4. Shell & Scripting Standards

### 4.1 POSIX / Bash Scripts (`scripts/*.sh`, `scripts/*`)
All executable shell scripts must follow defensive programming practices:
- **Shebang**: Use `#!/usr/bin/env bash`.
- **Strict Mode**: Enable `set -euo pipefail` at the start of scripts.
- **Quoting**: Quote all variable expansions (e.g., `"$DIR"`, `"${TARGET_FILE}"`).
- **Input Validation & Defaults**:
  ```bash
  DIR="${1:-.}"
  DIR=$(realpath "$DIR")
  if [[ ! -d "$DIR" ]]; then
    echo "Error: Directory '$DIR' does not exist" >&2
    exit 1
  fi
  ```
- **Error Messages**: Print errors to `stderr` (`>&2`) with descriptive feedback.

### 4.2 Shell Configurations (Fish, Nushell, Zsh)
- **Fish (`fish.nix`, `fish/`)**:
  - Store reusable functions in `fish/functions/` or declare via `programs.fish.functions`.
  - Use abbreviations (`abbr`) for interactive shortcuts instead of aliases where possible.
- **Nushell (`nushell.nix`, `nushell/`)**:
  - Use structured data pipelines and record types.
  - Keep environment variables in `env.nu` and interactive configs in `config.nu`.
- **Zsh (`zsh.nix`)**:
  - Avoid setting `home.sessionVariables` directly if it produces recursive `.zshenv` evaluation issues.
  - Keep interactive completions and themes managed through Home Manager or Starship.

### 4.3 Environment & XDG Standards
- Respect XDG Base Directory specifications:
  - Configuration: `$XDG_CONFIG_HOME` (default: `~/.config`)
  - Data: `$XDG_DATA_HOME` (default: `~/.local/share`)
  - State: `$XDG_STATE_HOME` (default: `~/.local/state`)
  - Cache: `$XDG_CACHE_HOME` (default: `~/.cache`)

---

## 5. Commit Conventions (Conventional Commits)

All commits in this repository must follow the [Conventional Commits v1.0.0](https://www.conventionalcommits.org/) specification.

### 5.1 Format
```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### 5.2 Commit Types
- `feat`: A new tool, configuration module, shell feature, or workflow script.
- `fix`: A bugfix in existing configurations, broken symlinks, or cross-platform issues.
- `refactor`: Restructuring configurations without changing observable behavior.
- `style`: Formatting, whitespace, or comment adjustments (e.g., StyLua, nixfmt).
- `docs`: Documentation updates (e.g., `README.md`, `AGENTS.md`, `conventions.md`).
- `chore`: Maintenance tasks, flake lock updates (`nix flake update`), metadata adjustments.
- `perf`: Optimizations for shell startup time, lazy-loading tweaks, or caching.

### 5.3 Allowed Scopes
- **Core / Nix**: `flake`, `nix`, `home-manager`, `darwin`, `linux`
- **Window Management**: `hyprland`, `waybar`, `rofi`, `yabai`, `skhd`, `sketchybar`, `aerospace`
- **Terminal & Multiplexers**: `tmux`, `zellij`, `ghostty`, `kitty`, `alacritty`, `wezterm`
- **Shells**: `fish`, `nushell`, `zsh`, `bash`, `starship`
- **Editors**: `nvim`, `zed`
- **Agent Workflows & Scripts**: `agents`, `herdr`, `claude`, `opencode`, `engram`, `scripts`, `matugen`

### 5.4 Rules & Examples
- Use imperative, present-tense verbs (e.g., `add`, `fix`, `update`, `remove`).
- Do not capitalize the first letter of the description.
- Do not place a period at the end of the description.

---

## 6. Build, Validation & Operational Workflows

### 6.1 Syntax & Health Validation
Before committing changes, validate Nix syntax and flake outputs:
```bash
nix flake check
```

### 6.2 Applying Configurations
To apply configurations across supported platforms:
```bash
# Default (macOS Apple Silicon)
nix run github:nix-community/home-manager -- switch --flake .#gentleman -b backup

# macOS Intel
nix run github:nix-community/home-manager -- switch --flake .#gentleman-macos-intel -b backup

# Linux (Wayland / Hyprland)
nix run github:nix-community/home-manager -- switch --flake .#gentleman-linux -b backup
```
