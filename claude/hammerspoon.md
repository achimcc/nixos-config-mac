# Hammerspoon Konfiguration

Hammerspoon ist ein macOS Automatisierungstool, das Lua-Skripting für System-Interaktionen ermöglicht.

## Installation

Die Installation erfolgt automatisch über nix-darwin:
```bash
sudo darwin-rebuild switch --flake /Users/achimschneider/nix-darwin-config#achims-mac
```

Nach der Installation:
1. Hammerspoon starten (aus /Applications)
2. Accessibility-Berechtigungen gewähren (System Settings > Privacy & Security > Accessibility)
3. Die Konfiguration wird automatisch aus `~/.hammerspoon/init.lua` geladen

## Tastenkombinationen

### Hyper Key
Die meisten Shortcuts verwenden den "Hyper" Key: **Cmd + Alt + Ctrl + Shift**

### Window Management

#### Halbe Bildschirme
- **Hyper + Left**: Fenster links (halber Bildschirm)
- **Hyper + Right**: Fenster rechts (halber Bildschirm)
- **Hyper + Up**: Fenster oben (halber Bildschirm)
- **Hyper + Down**: Fenster unten (halber Bildschirm)

#### Viertel Bildschirme
- **Ctrl + Alt + Cmd + 1**: Fenster oben links (Viertel)
- **Ctrl + Alt + Cmd + 2**: Fenster oben rechts (Viertel)
- **Ctrl + Alt + Cmd + 3**: Fenster unten links (Viertel)
- **Ctrl + Alt + Cmd + 4**: Fenster unten rechts (Viertel)

#### Weitere Funktionen
- **Hyper + F**: Fenster auf Vollbild
- **Hyper + C**: Fenster zentrieren
- **Hyper + N**: Fenster zum nächsten Bildschirm verschieben
- **Hyper + H**: Fenster-Hints anzeigen (alle Fenster mit Buchstaben markieren)

### System

- **Hyper + R**: Hammerspoon-Konfiguration neu laden

### Caffeine

Ein Caffeine-Icon in der Menüleiste zeigt den Schlafmodus-Status:
- **☕**: Computer bleibt wach (Display schläft nicht)
- **💤**: Normaler Schlafmodus aktiv

Durch Klick auf das Icon kann zwischen den Modi gewechselt werden.

## Konfigurationsdateien

- `~/.hammerspoon/init.lua`: Hauptkonfiguration
- `~/.hammerspoon/Spoons/ReloadConfiguration.spoon/`: Auto-Reload Spoon

## Erweitern

Um die Konfiguration zu erweitern:
1. `home.nix` bearbeiten (Abschnitt `.hammerspoon/init.lua`)
2. System neu bauen: `sudo darwin-rebuild switch --flake /Users/achimschneider/nix-darwin-config#achims-mac`
3. Hammerspoon lädt die Konfiguration automatisch neu

Alternativ kann die Konfiguration direkt in `~/.hammerspoon/init.lua` bearbeitet werden (wird bei nächstem rebuild überschrieben).

## Nützliche Ressourcen

- [Hammerspoon Dokumentation](https://www.hammerspoon.org/docs/)
- [Hammerspoon API](https://www.hammerspoon.org/docs/index.html)
- [Spoons Repository](https://www.hammerspoon.org/Spoons/)
