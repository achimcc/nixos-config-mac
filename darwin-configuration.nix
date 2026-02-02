{ config, pkgs, ... }:

{
  # Module imports (will be added incrementally)
  imports = [
    ./modules/system/dock.nix
    ./modules/system/finder.nix
    ./modules/system/trackpad.nix
    ./modules/system/defaults.nix
    ./modules/packages/cli-tools.nix
  ];

  # Basis-System-Einstellungen
  system.stateVersion = 5;

  # Nix-Einstellungen
  nix.settings = {
    experimental-features = "nix-command flakes";
    trusted-users = [ "achim" "@admin" ];
  };

  # User-Konto
  users.users.achim = {
    name = "achim";
    home = "/Users/achim";
  };

  # Services
  services.nix-daemon.enable = true;

  # Automatische System-Updates (manuell kontrolliert)
  system.autoUpgrade.enable = false;

  # Programme die system-weit verfügbar sein sollen
  programs.zsh.enable = true;  # Default shell compatibility
}
