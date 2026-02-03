{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Version Control & Git
    git
    gh
    lazygit
    gitmoji-cli

    # Shell & Terminal
    # nushell (manuell installiert wegen Build-Problemen in nixpkgs)
    fzf
    carapace

    # Docker & Container
    docker

    # Cloud & Infrastructure
    awscli

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
