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
    # "ledger-live"
    # "gather"
    # "remarkable"
    # "utorrent-web"
    # "font-hack-nerd-font"  # Benötigt homebrew/cask-fonts tap (deprecated)
  ];
}
