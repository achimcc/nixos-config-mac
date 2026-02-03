{ config, pkgs, ... }:

{
  # duti für Datei-Assoziationen
  homebrew.brews = [
    "duti"
  ];

  # Aktivierungsskript zum Setzen der Datei-Assoziationen
  system.activationScripts.setFileAssociations.text = ''
    # Setze MarkText als Standard-App für Markdown-Dateien (als Benutzer ausführen)
    if command -v duti &> /dev/null; then
      echo "Setting file associations..."
      # Führe duti als Benutzer aus (nicht als root)
      sudo -u ${config.system.primaryUser} duti -s com.github.marktext.marktext .md all 2>/dev/null || \
      echo "Warning: Could not set MarkText as default for .md files. Make sure MarkText is installed."

      # .markdown Dateien mit MarkText öffnen
      sudo -u ${config.system.primaryUser} duti -s com.github.marktext.marktext .markdown all 2>/dev/null || true
    else
      echo "Note: duti not yet available. File associations will be set after next rebuild."
    fi
  '';
}
