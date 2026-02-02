# Setup Guide

## Voraussetzungen

- Apple Silicon Mac
- macOS 14 oder neuer

## Initiale Installation

### 1. Nix installieren

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Nach der Installation Terminal neu starten.

### 2. Repository klonen

```bash
git clone <repo-url> ~/nix-darwin-config
cd ~/nix-darwin-config
```

### 3. Age-Key für sops generieren

```bash
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
```

Der Public Key wird angezeigt. Diesen in `.sops.yaml` eintragen.

### 4. Git-Konfiguration anpassen

In `home.nix` die TODOs ausfüllen:
- Email-Adresse eintragen
- GPG Key ID eintragen (optional)

### 5. nix-darwin aktivieren

```bash
nix run nix-darwin -- switch --flake .#achims-mac
```

Beim ersten Mal kann das einige Minuten dauern.

### 6. Nushell als Standard-Shell setzen (optional)

```bash
sudo sh -c 'echo /run/current-system/sw/bin/nu >> /etc/shells'
chsh -s /run/current-system/sw/bin/nu
```

Terminal neu starten.

## Tägliche Nutzung

### Config-Änderungen anwenden

```bash
cd ~/nix-darwin-config
darwin-rebuild switch --flake .#achims-mac
```

### Bei Problemen: Rollback

```bash
darwin-rebuild switch --rollback
```

### Secrets verwalten

```bash
# Secrets bearbeiten
sops secrets/secrets.yaml

# Neue Secrets hinzufügen
# 1. In modules/secrets/sops.nix definieren
# 2. In secrets/secrets.yaml verschlüsseln
# 3. darwin-rebuild switch
```

## Troubleshooting

### "command not found: darwin-rebuild"

Lösung: nix-darwin noch nicht aktiviert. Verwende:
```bash
nix run nix-darwin -- switch --flake .#achims-mac
```

### Homebrew-Casks werden nicht installiert

Homebrew muss initial manuell installiert werden:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Danach `darwin-rebuild switch` erneut ausführen.
