{ pkgs, ... }:

{
  # Hammerspoon Installation via Homebrew
  homebrew.casks = [
    "hammerspoon"
  ];

  # Hammerspoon läuft als User-Anwendung, daher keine system.defaults nötig
  # Die Konfiguration wird über home-manager in home.nix verwaltet
}
