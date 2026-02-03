{ pkgs, ... }:

{
  # homebrew.taps = [
  #   "homebrew/cask-fonts"  # Deprecated!
  # ];

  homebrew.casks = [
    # Problematische Casks temporär deaktiviert
    # "google-chrome"
    "zen"
    "basictex"
    "joplin"
    "coteditor"
    "mark-text"  # Deprecated, wird am 2026-09-01 deaktiviert
    # "ledger-live"
    # "gather"
    # "remarkable"
    # "utorrent-web"
    # "font-hack-nerd-font"  # Benötigt homebrew/cask-fonts tap (deprecated)
  ];
}
