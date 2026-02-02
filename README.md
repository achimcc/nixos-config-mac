# nix-darwin Configuration

Vollständig deklarative macOS-Konfiguration mit nix-darwin, Home Manager und sops-nix.

## Features

- **System-Einstellungen:** Dock, Finder, Trackpad, globale Defaults
- **Paket-Management:** CLI-Tools via Nix, GUI-Apps via Homebrew Casks (deklarativ)
- **Home Manager:** Git, Nushell, Zsh, Dotfiles
- **Secrets:** sops-nix mit Age-Verschlüsselung
- **Reproduzierbar:** Komplettes System aus Config wiederherstellbar
- **Versioniert:** Alle Änderungen in Git

## Quick Start

Siehe [SETUP.md](docs/SETUP.md) für detaillierte Installationsanleitung.

```bash
# Initiale Installation
nix run nix-darwin -- switch --flake .#achims-mac

# Updates
darwin-rebuild switch --flake .#achims-mac

# Rollback
darwin-rebuild switch --rollback
```

## Struktur

```
nix-darwin-config/
├── flake.nix                 # Hauptkonfiguration
├── darwin-configuration.nix  # System-Config
├── home.nix                  # Home Manager
├── modules/
│   ├── system/              # macOS System-Einstellungen
│   ├── packages/            # Programm-Installationen
│   └── secrets/             # Secrets-Management
├── secrets/                 # Verschlüsselte Secrets
└── docs/                    # Dokumentation
```

## Dokumentation

- [Setup Guide](docs/SETUP.md) - Installationsanleitung
- [Design Document](docs/plans/2026-02-02-macos-declarative-config-design.md) - Architektur und Entscheidungen

## Wartung

### Config ändern

1. Datei in `modules/` oder `home.nix` bearbeiten
2. `darwin-rebuild switch --flake .#achims-mac`
3. Bei Erfolg: `git commit`
4. Bei Fehler: `darwin-rebuild switch --rollback`

### Programm hinzufügen

**CLI-Tool (via Nix):**
- In `modules/packages/cli-tools.nix` hinzufügen

**GUI-App (via Homebrew):**
- In entsprechendes Modul unter `modules/packages/` hinzufügen

### System-Einstellung ändern

- Entsprechendes Modul unter `modules/system/` bearbeiten
- Verfügbare Optionen: https://daiderd.com/nix-darwin/manual/index.html
