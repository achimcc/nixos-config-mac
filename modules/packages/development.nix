{ pkgs, ... }:

{
  homebrew = {
    enable = true;
    casks = [
      # Problematische Casks temporär deaktiviert
      # "cursor"
      # "visual-studio-code"
      "dbeaver-community"
      "warp"
    ];
  };
}
