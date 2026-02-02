{ config, pkgs, ... }:

{
  # Module imports (will be added incrementally)
  imports = [
    # System settings modules will be added here
    # Package modules will be added here
    # Secrets module will be added here
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
