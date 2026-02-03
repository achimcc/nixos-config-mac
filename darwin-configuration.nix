{ config, pkgs, ... }:

{
  # Module imports (will be added incrementally)
  imports = [
    ./modules/system/dock.nix
    ./modules/system/finder.nix
    ./modules/system/trackpad.nix
    ./modules/system/defaults.nix
    ./modules/system/file-associations.nix
    ./modules/packages/cli-tools.nix
    ./modules/packages/development.nix
    ./modules/packages/productivity.nix
    ./modules/packages/gui-apps.nix
    ./modules/secrets/sops.nix
  ];

  # Basis-System-Einstellungen
  system.stateVersion = 5;

  # Primary User für system defaults und homebrew
  system.primaryUser = "achimschneider";

  # Nix-Einstellungen
  # Determinate Nix verwaltet die Nix-Installation selbst
  nix.enable = false;
  nix.settings = {
    experimental-features = "nix-command flakes";
    trusted-users = [ "achimschneider" "@admin" ];
  };

  # User-Konto
  users.users.achimschneider = {
    name = "achimschneider";
    home = "/Users/achimschneider";
  };

  # Programme die system-weit verfügbar sein sollen
  programs.zsh.enable = true;  # Default shell compatibility
}
