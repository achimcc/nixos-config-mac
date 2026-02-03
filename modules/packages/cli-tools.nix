{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Version Control & Git
    git
    gh
    lazygit
    gitmoji-cli

    # Shell & Terminal
    (pkgs.nushell.overrideAttrs (old: {
      doCheck = false;  # Skip tests that fail on macOS with "Operation not permitted"
    }))
    fzf
    carapace

    # Docker & Container
    docker

    # Cloud & Infrastructure
    # awscli moved to home.nix as awscli2 for SSO support

    # File Processing
    jq
    jless
    yq-go
    pdfcpu
    pandoc

    # Security & Crypto
    gnupg
    pinentry_mac

    # Node.js Ecosystem
    nodejs

    # Rust
    rustup

    # Development Tools
    watchexec
    hyperfine
    tokei

    # Compression & Utilities
    brotli
  ];
}
