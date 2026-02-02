{ pkgs, ... }:

{
  homebrew = {
    enable = true;
    casks = [
      "cursor"
      "visual-studio-code"
      "dbeaver-community"
      "warp"
    ];
  };
}
