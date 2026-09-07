{ pkgs, config, lib, ... }:

{
  # Install Bun for Gemini CLI
  home.packages = [
    pkgs.bun
  ];

  # Auto-install Gemini CLI on home-manager activation
  home.activation.installGeminiCLI = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    echo "🔧 Setting up Gemini CLI..."

    # Install Gemini CLI globally via bun
    echo "📦 Installing Gemini CLI..."
    ${pkgs.bun}/bin/bun install -g "@google/gemini-cli"
    echo "✅ Gemini CLI installed!"
    echo ""
    echo "🎉 Gemini CLI setup complete!"
    echo "Usage: gemini"
  '';

  # ─── AGY (Antigravity) configuration files ───────────────────────────────
  # Managed by home-manager; source of truth lives in gemini/ inside this repo.

  home.file.".gemini/GEMINI.md" = {
    source = ./gemini/GEMINI.md;
  };

  home.file.".gemini/conventions.md" = {
    source = ./gemini/conventions.md;
  };

  home.file.".gemini/settings.json" = {
    source = ./gemini/settings.json;
  };

  # Rules — modular behavior contracts
  home.file.".gemini/rules/persona.md" = {
    source = ./gemini/rules/persona.md;
  };

  home.file.".gemini/rules/engram.md" = {
    source = ./gemini/rules/engram.md;
  };

  home.file.".gemini/rules/rtk.md" = {
    source = ./gemini/rules/rtk.md;
  };

  home.file.".gemini/rules/codegraph.md" = {
    source = ./gemini/rules/codegraph.md;
  };

  home.file.".gemini/rules/strict-tdd.md" = {
    source = ./gemini/rules/strict-tdd.md;
  };

  home.file.".gemini/rules/superpowers.md" = {
    source = ./gemini/rules/superpowers.md;
  };

  home.file.".gemini/rules/agent-routing.md" = {
    source = ./gemini/rules/agent-routing.md;
  };
}
