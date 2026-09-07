{ pkgs, ... }:
{
  programs.bash = {
    enable = true;
    initExtra = ''
      # Auto-exec into Fish for interactive login sessions
      if [[ $- == *i* ]] && [[ -z "$BASH_EXECUTION_STRING" ]]; then
        for fish_bin in \
          "$HOME/.local/state/nix/profiles/home-manager/home-path/bin/fish" \
          "$HOME/.nix-profile/bin/fish" \
          /usr/bin/fish; do
          if [[ -x "$fish_bin" ]]; then
            exec "$fish_bin"
          fi
        done
        if command -v fish >/dev/null 2>&1; then
          exec fish
        fi
      fi
    '';
  };
}
