{ pkgs, ... }:
{
  programs.fish = {
    shellAbbrs = {
      fzfbat = "fzf --preview=\"bat --theme=gruvbox-dark --color=always {}\"";
      fzfnvim = "nvim (fzf --preview=\"bat --theme=gruvbox-dark --color=always {}\")";
      opencode-config = "nvim ~/.opencode.json";
    };

    interactiveShellInit = ''
      if test (uname) = Darwin
        set -l brew_bin /opt/homebrew/bin/brew
        test -x $brew_bin; and eval ($brew_bin shellenv)
      else
        set -l brew_bin /home/linuxbrew/.linuxbrew/bin/brew
        test -x $brew_bin; and eval ($brew_bin shellenv)
      end

      if test (uname) != Darwin
        if test -d /run/user/(id -u)/hypr
          set -l active_sig (basename (ls -d /run/user/(id -u)/hypr/release* 2>/dev/null | tail -n 1))
          test -n "$active_sig"; and set -gx HYPRLAND_INSTANCE_SIGNATURE $active_sig
        end
      end

      # pnpm 11 links global executables into PNPM_HOME/bin and validates that
      # directory is on PATH (pnpm 10 used PNPM_HOME directly).
      if test (uname) = Darwin
        set -gx PNPM_HOME $HOME/Library/pnpm
      else
        set -gx PNPM_HOME $HOME/.local/share/pnpm
      end

      # CodeGraph bundles a Node runtime that may try to read macOS' legacy
      # OpenSSL config path. /dev/null avoids that startup failure.
      if not set -q OPENSSL_CONF
        set -gx OPENSSL_CONF /dev/null
      end

      # All PATH entries - matching zsh config
      # Priority: Pi wrapper > pnpm globals > local bins > nix > cargo > volta > bun > homebrew > system
      set -gx PATH $HOME/.pi/agent/bin $PNPM_HOME/bin $HOME/.local/bin $HOME/.opencode/bin $HOME/.local/state/nix/profiles/home-manager/home-path/bin $HOME/.nix-profile/bin /nix/var/nix/profiles/default/bin $HOME/.cargo/bin $HOME/.volta/bin $HOME/.bun/bin $PATH

      set -gx PKG_CONFIG_PATH $HOME/.nix-profile/lib/pkgconfig $HOME/.local/state/nix/profiles/home-manager/home-path/lib/pkgconfig /usr/lib/pkgconfig /usr/share/pkgconfig $PKG_CONFIG_PATH
      set -gx CGO_ENABLED 1
      set -gx CGO_CFLAGS "-I$HOME/.nix-profile/include -I$HOME/.local/state/nix/profiles/home-manager/home-path/include"
      set -gx CGO_LDFLAGS "-L$HOME/.nix-profile/lib -L$HOME/.local/state/nix/profiles/home-manager/home-path/lib"
      set -gx CGO_CFLAGS_ALLOW "-fno-strict-overflow"

      if status is-interactive
        if type -q tty
          set -l tty_out (tty 2>/dev/null)
          test -n "$tty_out"; and set -gx GPG_TTY $tty_out
        end
      end

      starship init fish | source
      zoxide init fish | source
      atuin init fish | source
      fzf --fish | source
      if type -q direnv
        direnv hook fish | source
      end

      set -gx CARAPACE_BRIDGES 'zsh,fish,bash,inshellisense'
      if type -q carapace
        carapace _carapace | source
      end

      set -g fish_greeting ""

      # Enable vi mode
      fish_vi_key_bindings

      # Set nvim as default editor for opencode and other tools
      set -gx EDITOR nvim
      set -gx VISUAL nvim

      ## yazi

      function ya_zed
        set tmp (mktemp -t "yazi-chooser.XXXXXXXXXX")
        yazi --chooser-file $tmp $argv

        if test -s $tmp
          set opened_file (head -n 1 -- $tmp)
          if test -n "$opened_file"
            if test -d "$opened_file"
              # Es una carpeta, la agregamos al workspace
              zed --add "$opened_file"
            else
              # Es un archivo, lo abrimos normalmente
              zed --add "$opened_file"
            end
          end
        end

        rm -f -- $tmp
      end

      set -l foreground F3F6F9 normal
      set -l selection 263356 normal
      set -l comment 8394A3 brblack
      set -l red CB7C94 red
      set -l orange DEBA87 orange
      set -l yellow FFE066 yellow
      set -l green B7CC85 green
      set -l purple A3B5D6 purple
      set -l cyan 7AA89F cyan
      set -l pink FF8DD7 magenta

      # Syntax Highlighting Colors
      set -g fish_color_normal $foreground
      set -g fish_color_command $cyan
      set -g fish_color_keyword $pink
      set -g fish_color_quote $yellow
      set -g fish_color_redirection $foreground
      set -g fish_color_end $orange
      set -g fish_color_error $red
      set -g fish_color_param $purple
      set -g fish_color_comment $comment
      set -g fish_color_selection --background=$selection
      set -g fish_color_search_match --background=$selection
      set -g fish_color_operator $green
      set -g fish_color_escape $pink
      set -g fish_color_autosuggestion $comment

      # Completion Pager Colors
      set -g fish_pager_color_progress $comment
      set -g fish_pager_color_prefix $cyan
      set -g fish_pager_color_completion $foreground
      set -g fish_pager_color_description $comment

      # tmux-style tab naming for Zellij: name a tab after its directory.
      # Only fires while the tab still has Zellij's default "Tab #N" name, so it
      # never fights the agent-state rollup, which writes "● agent working" into
      # the tab name. Effect: the tab adopts the project dir on open/first cd,
      # then stays put (state dot is appended by zellij-agent-report.sh).
      function __gm_zellij_autoname_tab --on-variable PWD
        set -q ZELLIJ; or return
        set -q ZELLIJ_PANE_ID; or return
        set -l base (basename "$PWD")
        test -n "$base"; or return
        set -l info (zellij action list-panes --json 2>/dev/null)
        test -n "$info"; or return
        set -l tabname (printf '%s' "$info" | jq -r --arg p "$ZELLIJ_PANE_ID" '
          .[] | select((.id|tostring)==$p or ("terminal_"+(.id|tostring))==$p) | .tab_name' 2>/dev/null | head -n1)
        string match -qr '^Tab #[0-9]+$' -- "$tabname"; or return
        zellij action rename-tab "$base" >/dev/null 2>&1
      end

      # Start Herdr automatically for fresh interactive Fish sessions.
      # Guard against nesting when Fish is already running inside Herdr, tmux, or Zellij.
      if status is-interactive; and command -q herdr; and not set -q HERDR_ENV; and not set -q TMUX; and not set -q ZELLIJ
        herdr; or echo "⚠️  Herdr failed to start; continuing in Fish."
      end

      if status is-interactive; and isatty 1
        clear
      end
    '';

    plugins = [
      {
        name = "fisher";
        src = pkgs.fetchFromGitHub {
          owner = "jorgebucaran";
          repo = "fisher";
          rev = "4.4.4";
          sha256 = "sha256-e8gIaVbuUzTwKtuMPNXBT5STeddYqQegduWBtURLT3M=";
        };
      }
      {
        name = "catppuccin";
        src = pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "fish";
          rev = "0ce27b518e8ead555dec34dd8be3df5bd75cff8e";
          sha256 = "sha256-Dc/zdxfzAUM5NX8PxzfljRbYvO9f9syuLO8yBr+R3qg=";
        };
      }
    ];
  };
}
