{ config, pkgs, ... }:

{
  home.stateVersion = "24.05";

  # User-spezifische Packages
  home.packages = with pkgs; [
    awscli2  # AWS CLI v2 mit SSO login support
    direnv   # Automatisches Laden von Umgebungsvariablen pro Verzeichnis

    # Neovim und Development Tools
    neovim

    # LSP Servers
    nodePackages.typescript-language-server
    nodePackages.vscode-langservers-extracted  # HTML, CSS, JSON, ESLint
    nodePackages.typescript
    vtsls
    lua-language-server
    nil  # Nix LSP
    marksman  # Markdown LSP

    # Formatters & Linters
    nodePackages.prettier
    prettierd
    nodePackages.eslint_d

    # Debugging
    vscode-js-debug

    # Database Tools (für dadbod)
    postgresql
    mysql80
    sqlite

    # Additional Dev Tools
    ripgrep  # Für Telescope search
    fd  # Für Telescope file finder
    nodejs_20  # Node.js runtime

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

    # Setup PATH first, before any commands that need it

    # Add Home Manager profile bin BEFORE system paths (to prefer user-installed packages)
    $env.PATH = ($env.PATH | split row (char esep) | prepend "${config.home.homeDirectory}/.nix-profile/bin")

    # Add nix-darwin system paths
    $env.PATH = ($env.PATH | split row (char esep) | prepend "/run/current-system/sw/bin" | prepend "/nix/var/nix/profiles/default/bin")

    # Add npm global bin to PATH if npm is available
    if (which npm | is-not-empty) {
      let npm_prefix = (npm prefix -g | str trim)
      let npm_bin = ($npm_prefix | path join "bin")
      if ($npm_bin | path exists) {
        $env.PATH = ($env.PATH | split row (char esep) | prepend $npm_bin)
      }
    }

    # Load cargo environment if it exists
    if ("${config.home.homeDirectory}/.cargo/env.nu" | path exists) {
      source $"($nu.home-dir)/.cargo/env.nu"
    }

    # Custom command: nix rebuild switch
    def nrs [] {
      sudo darwin-rebuild switch --flake /Users/achimschneider/nix-darwin-config#achims-mac
    }

    # AWS Profile Switcher
    def --env awsp [] {
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

    # Starship prompt
    use std "path add"
    $env.STARSHIP_SHELL = "nu"
    def create_left_prompt [] {
      starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)'
    }
    $env.PROMPT_COMMAND = { || create_left_prompt }
    $env.PROMPT_COMMAND_RIGHT = ""

    # Carapace completions
    $env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
    mkdir ~/.cache/carapace
    carapace _carapace nushell | save --force ~/.cache/carapace/init.nu
    source ~/.cache/carapace/init.nu
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

  # Environment Variables
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # Dotfiles und Symlinks
  home.file = {
    ".gnupg/gpg-agent.conf".text = ''
      pinentry-program ${pkgs.pinentry_mac}/bin/pinentry-mac
    '';

    # Neovim Configuration
    ".config/nvim/init.lua".text = ''
      -- Bootstrap lazy.nvim
      local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
      if not vim.loop.fs_stat(lazypath) then
        vim.fn.system({
          "git",
          "clone",
          "--filter=blob:none",
          "https://github.com/folke/lazy.nvim.git",
          "--branch=stable",
          lazypath,
        })
      end
      vim.opt.rtp:prepend(lazypath)

      -- Load LazyVim
      require("config.lazy")
    '';

    ".config/nvim/lua/config/lazy.lua".text = ''
      require("lazy").setup({
        spec = {
          -- LazyVim
          { "LazyVim/LazyVim", import = "lazyvim.plugins" },

          -- LazyVim Extras
          { import = "lazyvim.plugins.extras.lang.typescript" },
          { import = "lazyvim.plugins.extras.lang.json" },
          { import = "lazyvim.plugins.extras.dap.core" },
          { import = "lazyvim.plugins.extras.test.core" },
          { import = "lazyvim.plugins.extras.coding.copilot" },
          { import = "lazyvim.plugins.extras.editor.mini-files" },

          -- Custom plugins
          { import = "plugins" },
        },
        defaults = {
          lazy = false,
          version = false,
        },
        install = { colorscheme = { "tokyonight" } },
        checker = { enabled = true },
        performance = {
          rtp = {
            disabled_plugins = {
              "gzip",
              "tarPlugin",
              "tohtml",
              "tutor",
              "zipPlugin",
            },
          },
        },
      })

      -- Load additional configs
      require("config.options")
      require("config.keymaps")
    '';

    ".config/nvim/lua/config/options.lua".text = ''
      -- Leader key
      vim.g.mapleader = " "
      vim.g.maplocalleader = "\\"

      -- Basic settings
      local opt = vim.opt

      opt.number = true
      opt.relativenumber = true
      opt.expandtab = true
      opt.shiftwidth = 2
      opt.tabstop = 2
      opt.smartindent = true
      opt.wrap = false
      opt.swapfile = false
      opt.backup = false
      opt.undofile = true
      opt.hlsearch = false
      opt.incsearch = true
      opt.termguicolors = true
      opt.scrolloff = 8
      opt.signcolumn = "yes"
      opt.updatetime = 50
      opt.clipboard = "unnamedplus"

      -- TypeScript/JavaScript specific
      vim.g.autoformat = true

      -- Direnv integration
      vim.api.nvim_create_autocmd("DirChanged", {
        callback = function()
          vim.fn.system("direnv allow")
        end,
      })
    '';

    ".config/nvim/lua/config/keymaps.lua".text = ''
      local keymap = vim.keymap.set

      -- Debugging
      keymap("n", "<leader>db", "<cmd>DapToggleBreakpoint<cr>", { desc = "Toggle Breakpoint" })
      keymap("n", "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, { desc = "Conditional Breakpoint" })
      keymap("n", "<F5>", "<cmd>DapContinue<cr>", { desc = "Start/Continue" })
      keymap("n", "<F10>", "<cmd>DapStepOver<cr>", { desc = "Step Over" })
      keymap("n", "<F11>", "<cmd>DapStepInto<cr>", { desc = "Step Into" })
      keymap("n", "<F12>", "<cmd>DapStepOut<cr>", { desc = "Step Out" })
      keymap("n", "<leader>dr", "<cmd>DapToggleRepl<cr>", { desc = "Toggle REPL" })

      -- Testing
      keymap("n", "<leader>tt", function() require("neotest").run.run() end, { desc = "Run Nearest Test" })
      keymap("n", "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, { desc = "Run Test File" })
      keymap("n", "<leader>ts", function() require("neotest").summary.toggle() end, { desc = "Toggle Test Summary" })
      keymap("n", "<leader>to", function() require("neotest").output.open({ enter = true }) end, { desc = "Show Test Output" })

      -- Database
      keymap("n", "<leader>Du", "<cmd>DBUIToggle<cr>", { desc = "Toggle Database UI" })
      keymap("n", "<leader>Df", "<cmd>DBUIFindBuffer<cr>", { desc = "Find Database Buffer" })

      -- Git
      keymap("n", "<leader>gg", "<cmd>Neogit<cr>", { desc = "Neogit" })
      keymap("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "Diffview" })
      keymap("n", "<leader>gh", "<cmd>DiffviewFileHistory<cr>", { desc = "File History" })
      keymap("n", "<leader>gc", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" })
    '';

    ".config/nvim/lua/plugins/theme.lua".text = ''
      return {
        {
          "folke/tokyonight.nvim",
          lazy = false,
          priority = 1000,
          opts = {
            style = "night",
            transparent = false,
            terminal_colors = true,
            styles = {
              comments = { italic = true },
              keywords = { italic = true },
              functions = {},
              variables = {},
            },
          },
          config = function(_, opts)
            require("tokyonight").setup(opts)
            vim.cmd([[colorscheme tokyonight]])
          end,
        },
      }
    '';

    ".config/nvim/lua/plugins/copilot.lua".text = ''
      return {
        {
          "zbirenbaum/copilot.lua",
          cmd = "Copilot",
          event = "InsertEnter",
          opts = {
            suggestion = {
              enabled = true,
              auto_trigger = true,
              keymap = {
                accept = "<M-l>",
                next = "<M-]>",
                prev = "<M-[>",
                dismiss = "<C-]>",
              },
            },
            panel = { enabled = false },
            filetypes = {
              yaml = true,
              markdown = true,
              help = false,
              gitcommit = true,
              gitrebase = false,
              ["."] = false,
            },
          },
        },
      }
    '';

    ".config/nvim/lua/plugins/typescript.lua".text = ''
      return {
        {
          "neovim/nvim-lspconfig",
          opts = {
            servers = {
              tsserver = {
                enabled = false,
              },
              vtsls = {
                settings = {
                  typescript = {
                    preferences = {
                      importModuleSpecifier = "relative",
                    },
                    inlayHints = {
                      parameterNames = { enabled = "all" },
                      parameterTypes = { enabled = true },
                      variableTypes = { enabled = true },
                      propertyDeclarationTypes = { enabled = true },
                      functionLikeReturnTypes = { enabled = true },
                      enumMemberValues = { enabled = true },
                    },
                  },
                },
              },
            },
            setup = {
              vtsls = function(_, opts)
                -- Auto import on completion
                opts.handlers = {
                  ["textDocument/publishDiagnostics"] = function(...)
                    require("vim.lsp.diagnostic").on_publish_diagnostics(...)
                  end,
                }
              end,
            },
          },
        },
      }
    '';

    ".config/nvim/lua/plugins/debugging.lua".text = ''
      return {
        {
          "mfussenegger/nvim-dap",
          dependencies = {
            "rcarriga/nvim-dap-ui",
            "theHamsta/nvim-dap-virtual-text",
            "nvim-neotest/nvim-nio",
          },
          config = function()
            local dap = require("dap")
            local dapui = require("dapui")

            -- Setup DAP UI
            dapui.setup()

            -- Virtual text
            require("nvim-dap-virtual-text").setup()

            -- Auto open/close UI
            dap.listeners.after.event_initialized["dapui_config"] = function()
              dapui.open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
              dapui.close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
              dapui.close()
            end

            -- Node.js adapter
            dap.adapters.node2 = {
              type = "executable",
              command = "node",
              args = { "${pkgs.vscode-js-debug}/bin/js-debug" },
            }

            -- Configurations
            dap.configurations.typescript = {
              {
                type = "node2",
                request = "launch",
                name = "Launch Program",
                program = "''${file}",
                cwd = vim.fn.getcwd(),
                sourceMaps = true,
                protocol = "inspector",
                console = "integratedTerminal",
              },
              {
                type = "node2",
                request = "attach",
                name = "Attach to Process",
                processId = require("dap.utils").pick_process,
                cwd = vim.fn.getcwd(),
              },
            }
            dap.configurations.javascript = dap.configurations.typescript
          end,
        },
      }
    '';

    ".config/nvim/lua/plugins/testing.lua".text = ''
      return {
        {
          "nvim-neotest/neotest",
          dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "nvim-neotest/neotest-jest",
            "marilari88/neotest-vitest",
          },
          opts = {
            adapters = {
              ["neotest-jest"] = {
                jestCommand = "npm test --",
                jestConfigFile = "jest.config.js",
                env = { CI = true },
                cwd = function()
                  return vim.fn.getcwd()
                end,
              },
              ["neotest-vitest"] = {},
            },
            status = { virtual_text = true },
            output = { open_on_run = true },
          },
        },
      }
    '';

    ".config/nvim/lua/plugins/database.lua".text = ''
      return {
        {
          "tpope/vim-dadbod",
          dependencies = {
            "kristijanhusak/vim-dadbod-ui",
            "kristijanhusak/vim-dadbod-completion",
          },
          config = function()
            -- Auto-completion for SQL
            vim.api.nvim_create_autocmd("FileType", {
              pattern = { "sql", "mysql", "plsql" },
              callback = function()
                require("cmp").setup.buffer({
                  sources = {
                    { name = "vim-dadbod-completion" },
                    { name = "buffer" },
                  },
                })
              end,
            })

            -- DB UI settings
            vim.g.db_ui_use_nerd_fonts = 1
            vim.g.db_ui_show_database_icon = 1
          end,
        },
      }
    '';

    ".config/nvim/lua/plugins/git.lua".text = ''
      return {
        {
          "NeogitOrg/neogit",
          dependencies = {
            "nvim-lua/plenary.nvim",
            "sindrets/diffview.nvim",
            "nvim-telescope/telescope.nvim",
          },
          opts = {
            integrations = {
              diffview = true,
            },
          },
        },
        {
          "sindrets/diffview.nvim",
          opts = {},
        },
        {
          "lewis6991/gitsigns.nvim",
          opts = {
            current_line_blame = true,
            current_line_blame_opts = {
              delay = 300,
            },
          },
        },
      }
    '';

    ".config/nvim/lua/plugins/direnv.lua".text = ''
      return {
        {
          "direnv/direnv.vim",
          lazy = false,
        },
      }
    '';
  };
}
