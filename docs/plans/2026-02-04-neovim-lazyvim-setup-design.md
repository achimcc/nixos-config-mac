# Neovim LazyVim Setup Design

**Datum:** 2026-02-04
**Ziel:** Vollständiges Neovim-Setup für TypeScript/Node.js-Entwicklung via nix-darwin

## Überblick

Vollständig deklarative Neovim-Konfiguration mit LazyVim als Distribution, integriert in das bestehende nix-darwin-Setup. Alle Features werden via Nix verwaltet für maximale Reproduzierbarkeit.

## Entscheidungen

- **Distribution:** LazyVim (modern, schnell, exzellente TypeScript-Unterstützung)
- **Theme:** Tokyo Night
- **Verwaltung:** Vollständig via Nix/home-manager (deklarativ)
- **Features:** Alle (AI, Debugging, Testing, Database, erweiterte Git-Integration)

## Architektur

### 1. Nix-Paket-Installation (home.nix)

**Core:**
- neovim
- Node.js-basierte LSP-Server und Tools
- DAP-Server für Debugging
- Database-Clients

**LSP-Server & Tools:**
- typescript-language-server
- vtsls
- eslint_d
- prettier / prettierd
- vscode-js-debug (DAP)
- nil (Nix LSP)
- lua-language-server
- marksman (Markdown)
- vscode-langservers-extracted (HTML/CSS/JSON)

### 2. LazyVim-Konfiguration (via home.file)

**Dateistruktur:**
```
~/.config/nvim/
├── init.lua                    # LazyVim Bootstrap
├── lua/
│   ├── config/
│   │   ├── lazy.lua           # Plugin-Manager Config
│   │   ├── options.lua        # Vim-Optionen
│   │   └── keymaps.lua        # Custom Keybindings
│   └── plugins/
│       ├── copilot.lua        # GitHub Copilot
│       ├── typescript.lua     # TS-spezifische Settings
│       ├── debugging.lua      # DAP Configuration
│       ├── testing.lua        # Neotest Setup
│       ├── database.lua       # Dadbod UI
│       └── theme.lua          # Tokyo Night
```

### 3. Plugin-Stack

**LazyVim Extras (aktiviert):**
- lang.typescript
- lang.json
- dap.core
- test.core
- editor.mini-files
- coding.copilot

**Zusätzliche Plugins:**
- GitHub Copilot (AI-Unterstützung)
- nvim-dap + nvim-dap-ui (Debugging)
- neotest + neotest-jest/vitest (Testing)
- vim-dadbod + vim-dadbod-ui (Datenbanken)
- gitsigns, diffview, neogit (Git)
- direnv.nvim (Direnv-Integration)

## Feature-Workflows

### Debugging
- `<leader>db` - Toggle Breakpoint
- `<leader>dB` - Conditional Breakpoint
- `F5` - Start/Continue
- `F10/F11/F12` - Step Over/Into/Out
- DAP-UI: Variables, Call Stack, Breakpoints, Console
- Launch-Configs: Node.js-Apps, Jest-Tests, Attach-to-Process

### Testing
- `<leader>tt` - Run nearest test
- `<leader>tf` - Run test file
- `<leader>ts` - Test summary
- Inline Pass/Fail-Indicators
- Auto-Detect: Jest, Vitest, Mocha
- Watch-Mode Support

### Git
- Gitsigns: Inline Blame, Hunk-Preview, Stage/Unstage
- `<leader>gg` - Neogit
- `<leader>gd` - Diffview
- `<leader>gh` - Diffview History

### Database
- `<leader>db` - Dadbod UI
- Connections via .env/direnv
- SQL-Execution, Result-Buffer
- PostgreSQL, MySQL, SQLite, MongoDB

### Direnv
- Auto-Load .envrc bei Verzeichniswechsel
- Environment-Variables für LSP, Tests, Debugging

## Implementierung

### home.nix Änderungen

1. **Packages hinzufügen:**
   - neovim-unwrapped
   - Alle LSP-Server und Tools

2. **Konfigurationsdateien:**
   - Jede Config-Datei als `home.file` Text-Block
   - Deklarative Definition aller Lua-Dateien

3. **Environment-Variables:**
   - `EDITOR=nvim`
   - `VISUAL=nvim`

### Erster Start

Nach `nrs`:
1. LazyVim installiert Plugins automatisch
2. LSP-Server bereits verfügbar (via Nix)
3. Beim Öffnen von `.ts`: LSP + Copilot aktiviert
4. `<leader>l` - LazyVim-Dashboard

### Wartung

- **Plugin-Updates:** `:Lazy update` in Neovim
- **LSP-Updates:** `nrs` nach Nix-Package-Updates
- **Config-Änderungen:** `home.nix` editieren → `nrs`

## Vorteile

- **Reproduzierbar:** Komplettes Setup via `nrs`
- **Deklarativ:** Keine manuellen Plugin-Installationen
- **Integriert:** Nutzt bestehendes nix-darwin-Setup
- **Wartbar:** Updates via Nix, nicht manuelle Plugin-Manager
- **Vollständig:** Alle gewünschten Features out-of-the-box

## Nächste Schritte

1. home.nix erweitern mit Packages
2. Konfigurationsdateien deklarativ definieren
3. `nrs` ausführen
4. Neovim starten, Plugins installieren lassen
5. Testen mit TypeScript-Projekt
