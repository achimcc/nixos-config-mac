{ pkgs, ... }:

{
  homebrew.casks = [
    # Problematische Casks temporär deaktiviert
    # "1password"
    # "slack"
    # "signal"
    # "logseq"
    # "trilium-notes"
    "maccy"
    "raycast"
    # "microsoft-to-do"
  ];
}
