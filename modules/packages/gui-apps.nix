{ pkgs, ... }:

{
  homebrew.taps = [
    "homebrew/cask-fonts"
  ];

  homebrew.casks = [
    "google-chrome"
    "zen"
    "basictex"
    "ledger-live"
    "gather"
    "remarkable"
    "utorrent-web"
    "font-hack-nerd-font"
  ];
}
