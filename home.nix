{ config, pkgs, ... }:

{
  home.stateVersion = "24.05";

  # User-spezifische Packages
  home.packages = with pkgs; [
    # Weitere user-spezifische Tools können hier hinzugefügt werden
  ];

  # Git-Konfiguration
  programs.git = {
    enable = true;
    userName = "Achim Schneider";
    userEmail = "your-email@example.com";  # TODO: Echte Email eintragen
    signing = {
      key = "YOUR_GPG_KEY_ID";  # TODO: GPG Key ID eintragen
      signByDefault = true;
    };
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };

  # Nushell-Konfiguration
  programs.nushell = {
    enable = true;
    # Weitere Nushell-Configs können hier hinzugefügt werden
    extraConfig = ''
      $env.config = {
        show_banner: false
      }
    '';
  };

  # Zsh-Konfiguration (als Fallback)
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    history = {
      size = 10000;
      path = "${config.home.homeDirectory}/.zsh_history";
    };
  };

  # FZF-Konfiguration
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # Dotfiles und Symlinks
  home.file = {
    ".gnupg/gpg-agent.conf".text = ''
      pinentry-program ${pkgs.pinentry_mac}/bin/pinentry-mac
    '';
  };
}
