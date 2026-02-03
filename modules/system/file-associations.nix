{ config, pkgs, ... }:

{
  # duti für Datei-Assoziationen
  homebrew.brews = [
    "duti"
  ];

  # Aktivierungsskript zum Setzen der Datei-Assoziationen
  system.activationScripts.setFileAssociations.text = ''
    # Setze Joplin als Standard-App für Markdown-Dateien (als Benutzer ausführen)
    if command -v duti &> /dev/null; then
      echo "Setting file associations..."
      # Führe duti als Benutzer aus (nicht als root)
      sudo -u ${config.system.primaryUser} duti -s net.cozic.joplin-desktop .md all 2>/dev/null || \
      sudo -u ${config.system.primaryUser} duti -s net.cozic.joplin .md all 2>/dev/null || \
      echo "Warning: Could not set Joplin as default for .md files. Make sure Joplin is installed."

      # .markdown Dateien mit Joplin öffnen
      sudo -u ${config.system.primaryUser} duti -s net.cozic.joplin-desktop .markdown all 2>/dev/null || \
      sudo -u ${config.system.primaryUser} duti -s net.cozic.joplin .markdown all 2>/dev/null || true
    else
      echo "Note: duti not yet available. File associations will be set after next rebuild."
    fi
  '';
}
