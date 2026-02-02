# nix-darwin Configuration

Deklarative macOS-Konfiguration mit nix-darwin, Home Manager und sops-nix.

## Installation

Siehe [Design-Dokument](docs/plans/2026-02-02-macos-declarative-config-design.md) für Details.

## Quick Start

```bash
# Aktivieren
nix run nix-darwin -- switch --flake .#achims-mac

# Updates
darwin-rebuild switch --flake .#achims-mac

# Rollback
darwin-rebuild switch --rollback
```

## Struktur

- `flake.nix` - Hauptkonfiguration
- `darwin-configuration.nix` - System-Config
- `home.nix` - Home Manager User-Config
- `modules/system/` - macOS System-Einstellungen
- `modules/packages/` - Programm-Installationen
- `modules/secrets/` - Secrets-Management
