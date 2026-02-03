{ config, pkgs, ... }:

{
  home.stateVersion = "24.05";

  # User-spezifische Packages
  home.packages = with pkgs; [
    awscli2  # AWS CLI v2 mit SSO login support
    direnv   # Automatisches Laden von Umgebungsvariablen pro Verzeichnis
    # Weitere user-spezifische Tools können hier hinzugefügt werden
  ];

  # Git-Konfiguration
  programs.git = {
    enable = true;
    signing = {
      key = "05B0CBFAF4B16C56";
      signByDefault = true;
    };
    settings = {
      user = {
        name = "Achim Schneider";
        email = "achim.schneider@posteo.de";
      };
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };

  # Nushell-Konfiguration (via home.file statt programs.nushell um Build-Probleme zu vermeiden)
  # macOS nushell verwendet ~/Library/Application Support/nushell/ statt ~/.config/nushell/
  home.file."Library/Application Support/nushell/config.nu".text = ''
    $env.config = {
      show_banner: false
      hooks: {
        env_change: {
          PWD: [
            {|before, after|
              if (which direnv | is-empty) {
                return
              }
              direnv export json | from json | default {} | load-env
            }
          ]
        }
      }
    }

    # In config.nu ganz oben oder bei den Pfad-Definitionen:

    # 1. Ermittle dynamisch, wo npm globale Pakete speichert
    let npm_prefix = (npm prefix -g | str trim)
    let npm_bin = ($npm_prefix | path join "bin")

    # 2. Füge diesen Pfad zu deinem PATH hinzu, falls er existiert
    if ($npm_bin | path exists) {
        $env.PATH = ($env.PATH | split row (char esep) | prepend $npm_bin)
    }

    # Add Home Manager profile bin BEFORE system paths (to prefer user-installed packages)
    $env.PATH = ($env.PATH | split row (char esep) | prepend "${config.home.homeDirectory}/.nix-profile/bin")

    # Add nix-darwin system paths
    $env.PATH = ($env.PATH | split row (char esep) | prepend "/run/current-system/sw/bin" | prepend "/nix/var/nix/profiles/default/bin")

    # Load cargo environment if it exists
    if ("${config.home.homeDirectory}/.cargo/env.nu" | path exists) {
      source $"($nu.home-dir)/.cargo/env.nu"
    }

    # Custom command: nix rebuild switch
    def nrs [] {
      sudo darwin-rebuild switch --flake /Users/achimschneider/nix-darwin-config#achims-mac
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
