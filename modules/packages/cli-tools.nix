{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Version Control & Git
    git
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
