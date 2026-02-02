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
    signing = {
      key = "YOUR_GPG_KEY_ID";  # TODO: GPG Key ID eintragen
      signByDefault = true;
    };
    settings = {
      user = {
        name = "Achim Schneider";
        email = "your-email@example.com";  # TODO: Echte Email eintragen
      };
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };

  # Nushell-Konfiguration (via home.file statt programs.nushell um Build-Probleme zu vermeiden)
  home.file.".config/nushell/config.nu".text = ''
    $env.config = {
      show_banner: false
    }

    # Load cargo environment if it exists
    if ("${config.home.homeDirectory}/.cargo/env.nu" | path exists) {
      source $"($nu.home-dir)/.cargo/env.nu"
    }

    # Custom command: nix rebuild switch
    def nrs [] {
      darwin-rebuild switch --flake /Users/achimschneider/nix-darwin-config#achims-mac
    }

    # AWS Profile Switcher
    def awsp [] {
      let profile = (
        open ~/.aws/config
        | lines
        | where ($it | str contains "[profile ")
        | each { |line| $line | parse "[profile {profile}]" | get profile.0 }
        | str join "\n"
        | fzf --margin=25%,20%,0,20% --layout=reverse --border=rounded
      )

      if ($profile | str length) > 0 {
        load-env { AWS_PROFILE: $profile }

        let caller_check = (do { aws sts get-caller-identity } | complete)

        if $caller_check.exit_code != 0 {
          aws sso login
          bash ~/Hrmony/infrastructure/util/sec-group-update-ingress-ip.sh $profile achim.schneider
        }
      }
    }

    # CDK wrapper with auto-login
    def cdk [...args] {
      let caller_check = (do { aws sts get-caller-identity } | complete)

      if $caller_check.exit_code != 0 {
        print "\u{0007}"  # bell
        awsp
      }

      npx cdk ...$args
    }
  '';

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
