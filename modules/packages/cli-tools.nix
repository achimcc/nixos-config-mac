{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Version Control & Git
    git
    gitmoji

    # Shell & Terminal
    nushell
    fzf
    carapace

    # Docker & Container
    docker

    # Cloud & Infrastructure
    awscli

    # File Processing
    jq
    pdfcpu

    # Security & Crypto
    gnupg
    pinentry_mac

    # Node.js Ecosystem
    nodejs

    # Rust
    rustup

    # Compression & Utilities
    brotli
  ];
}
