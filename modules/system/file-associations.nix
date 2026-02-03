{ config, pkgs, ... }:

{
  # duti für Datei-Assoziationen
  homebrew.brews = [
    "duti"
  ];

  # Aktivierungsskript zum Setzen der Datei-Assoziationen
  system.activationScripts.setFileAssociations.text = ''
    # Setze CotEditor als Standard-App für Markdown-Dateien (als Benutzer ausführen)
    if command -v duti &> /dev/null; then
      echo "Setting file associations..."
      # Führe duti als Benutzer aus (nicht als root)
      sudo -u ${config.system.primaryUser} duti -s com.coteditor.CotEditor .md all 2>/dev/null || \
      echo "Warning: Could not set CotEditor as default for .md files. Make sure CotEditor is installed."

      # .markdown Dateien mit CotEditor öffnen
      sudo -u ${config.system.primaryUser} duti -s com.coteditor.CotEditor .markdown all 2>/dev/null || true
    else
      echo "Note: duti not yet available. File associations will be set after next rebuild."
    fi
  '';
}
