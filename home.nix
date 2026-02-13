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

    # Terminal
    wezterm  # GPU-beschleunigter Terminal Emulator

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

    # Zoxide (smart cd) - nur laden wenn verfügbar
    if (which zoxide | is-not-empty) {
      zoxide init nushell | save -f ~/.zoxide.nu
    }
    # Source zoxide config if it exists
    if ("~/.zoxide.nu" | path exists) {
      source ~/.zoxide.nu
    }

    # Modern CLI tool aliases - nur wenn Tools verfügbar sind
    if (which eza | is-not-empty) {
      alias ls = eza --icons --git
      alias ll = eza -l --icons --git
      alias la = eza -la --icons --git
      alias lt = eza --tree --icons --git
    }
    if (which bat | is-not-empty) {
      alias cat = bat
    }

    # Starship prompt - nur wenn verfügbar
    if (which starship | is-not-empty) {
      use std "path add"
      $env.STARSHIP_SHELL = "nu"
      def create_left_prompt [] {
        starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)'
      }
      $env.PROMPT_COMMAND = { || create_left_prompt }
      $env.PROMPT_COMMAND_RIGHT = ""
    }

    # Carapace completions - nur wenn verfügbar
    if (which carapace | is-not-empty) {
      $env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
      mkdir ~/.cache/carapace
      carapace _carapace nushell | save --force ~/.cache/carapace/init.nu
      source ~/.cache/carapace/init.nu
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

    # Hammerspoon Configuration
    ".hammerspoon/Spoons/ReloadConfiguration.spoon/init.lua".text = ''
      --- === ReloadConfiguration ===
      --- Automatically reload Hammerspoon configuration on file changes

      local obj = {}
      obj.__index = obj

      obj.name = "ReloadConfiguration"
      obj.version = "1.0"
      obj.author = "Hammerspoon"
      obj.license = "MIT"

      function obj:init()
        self.watch = nil
      end

      function obj:start()
        self.watch = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", function(files)
          local doReload = false
          for _, file in pairs(files) do
            if file:sub(-4) == ".lua" then
              doReload = true
            end
          end
          if doReload then
            hs.reload()
          end
        end):start()
        return self
      end

      function obj:stop()
        if self.watch then
          self.watch:stop()
        end
        return self
      end

      return obj
    '';

    ".hammerspoon/init.lua".text = ''
      -- Hammerspoon Configuration
      -- Reload config automatically
      hs.loadSpoon("ReloadConfiguration")
      spoon.ReloadConfiguration:start()

      -- Hyper key definition (Cmd + Alt + Ctrl + Shift)
      local hyper = {"cmd", "alt", "ctrl", "shift"}

      -- Window Management
      -- Half screens
      hs.hotkey.bind(hyper, "Left", function()
        local win = hs.window.focusedWindow()
        local screen = win:screen()
        local frame = screen:frame()
        win:setFrame({
          x = frame.x,
          y = frame.y,
          w = frame.w / 2,
          h = frame.h
        })
      end)

      hs.hotkey.bind(hyper, "Right", function()
        local win = hs.window.focusedWindow()
        local screen = win:screen()
        local frame = screen:frame()
        win:setFrame({
          x = frame.x + frame.w / 2,
          y = frame.y,
          w = frame.w / 2,
          h = frame.h
        })
      end)

      hs.hotkey.bind(hyper, "Up", function()
        local win = hs.window.focusedWindow()
        local screen = win:screen()
        local frame = screen:frame()
        win:setFrame({
          x = frame.x,
          y = frame.y,
          w = frame.w,
          h = frame.h / 2
        })
      end)

      hs.hotkey.bind(hyper, "Down", function()
        local win = hs.window.focusedWindow()
        local screen = win:screen()
        local frame = screen:frame()
        win:setFrame({
          x = frame.x,
          y = frame.y + frame.h / 2,
          w = frame.w,
          h = frame.h / 2
        })
      end)

      -- Fullscreen
      hs.hotkey.bind(hyper, "F", function()
        local win = hs.window.focusedWindow()
        local screen = win:screen()
        win:setFrame(screen:frame())
      end)

      -- Center window
      hs.hotkey.bind(hyper, "C", function()
        local win = hs.window.focusedWindow()
        win:centerOnScreen()
      end)

      -- Quarters
      hs.hotkey.bind({"ctrl", "alt", "cmd"}, "1", function()
        local win = hs.window.focusedWindow()
        local screen = win:screen()
        local frame = screen:frame()
        win:setFrame({
          x = frame.x,
          y = frame.y,
          w = frame.w / 2,
          h = frame.h / 2
        })
      end)

      hs.hotkey.bind({"ctrl", "alt", "cmd"}, "2", function()
        local win = hs.window.focusedWindow()
        local screen = win:screen()
        local frame = screen:frame()
        win:setFrame({
          x = frame.x + frame.w / 2,
          y = frame.y,
          w = frame.w / 2,
          h = frame.h / 2
        })
      end)

      hs.hotkey.bind({"ctrl", "alt", "cmd"}, "3", function()
        local win = hs.window.focusedWindow()
        local screen = win:screen()
        local frame = screen:frame()
        win:setFrame({
          x = frame.x,
          y = frame.y + frame.h / 2,
          w = frame.w / 2,
          h = frame.h / 2
        })
      end)

      hs.hotkey.bind({"ctrl", "alt", "cmd"}, "4", function()
        local win = hs.window.focusedWindow()
        local screen = win:screen()
        local frame = screen:frame()
        win:setFrame({
          x = frame.x + frame.w / 2,
          y = frame.y + frame.h / 2,
          w = frame.w / 2,
          h = frame.h / 2
        })
      end)

      -- Move window between screens
      hs.hotkey.bind(hyper, "N", function()
        local win = hs.window.focusedWindow()
        win:moveToScreen(win:screen():next())
      end)

      -- Caffeine - keep computer awake
      local caffeine = hs.menubar.new()

      local function setCaffeineDisplay(state)
        if state then
          caffeine:setTitle("☕")
        else
          caffeine:setTitle("💤")
        end
      end

      local function caffeineClicked()
        setCaffeineDisplay(hs.caffeinate.toggle("displayIdle"))
      end

      if caffeine then
        caffeine:setClickCallback(caffeineClicked)
        setCaffeineDisplay(hs.caffeinate.get("displayIdle"))
      end

      -- Reload configuration shortcut
      hs.hotkey.bind(hyper, "R", function()
        hs.reload()
      end)

      -- Show notification on successful load
      hs.notify.new({title="Hammerspoon", informativeText="Konfiguration geladen"}):send()

      -- Console styling
      hs.console.darkMode(true)

      -- Hints for all windows
      hs.hotkey.bind(hyper, "H", function()
        hs.hints.windowHints()
      end)

      -- SLACK RED LIGHT INTEGRATION
      -- Reagiert nur auf neue Slack-Nachrichten (nicht auf alle Notifications)

      local isLedOn = false

      -- Hilfsfunktion: LED einschalten
      local function turnLedOn()
        if not isLedOn then
          print("🔴 Neue Slack-Nachricht - LED EIN")
          hs.http.asyncGet("http://localhost:8934/blink1/fadeToRGB?rgb=%23FF0000&time=0.1", nil, function() end)
          isLedOn = true
          hs.notify.new({title="Slack", informativeText="Neue Nachricht!"}):send()
        end
      end

      -- Hilfsfunktion: LED ausschalten
      local function turnLedOff()
        if isLedOn then
          print("⚫ LED AUS")
          hs.http.asyncGet("http://localhost:8934/blink1/off", nil, function() end)
          isLedOn = false
        end
      end

      -- DM-Erkennung: Analysiert Notification-Format
      local function isDM(title, body)
        if not title then return false end

        -- Ausschließen: Channel-Notifications
        if title:match("#") then return false end
        if title:match("in #") then return false end
        if body and body:match("in #") then return false end

        -- Ausschließen: System-Notifications
        if title:match("Slack") then return false end
        if title:match("Reminder") then return false end

        -- Alles andere = vermutlich DM
        return true
      end

      -- App Watcher: LED ausschalten wenn Slack aktiviert wird
      local appWatcher = hs.application.watcher.new(function(appName, eventType, appObject)
        if appName == "Slack" and eventType == hs.application.watcher.activated then
          print("Slack aktiviert - LED AUS")
          turnLedOff()
        end
      end)
      appWatcher:start()

      -- Test-Hotkeys
      hs.hotkey.bind(hyper, "B", function()
        hs.alert.show("Test: blink(1) ROT")
        turnLedOn()
      end)

      hs.hotkey.bind(hyper, "X", function()
        hs.alert.show("blink(1) AUS")
        turnLedOff()
      end)

      hs.hotkey.bind(hyper, "S", function()
        hs.alert.show(string.format("LED Status: %s", isLedOn and "ON" or "OFF"))
      end)
    '';

    # WezTerm Configuration
    ".config/wezterm/wezterm.lua".text = ''
      local wezterm = require("wezterm")
      local config = wezterm.config_builder()

      -- Color scheme
      config.color_scheme = "Tokyo Night"

      -- Font
      config.font = wezterm.font_with_fallback({
        "JetBrains Mono",
        "Menlo",
        "Monaco",
      })
      config.font_size = 14.0

      -- Window
      config.window_decorations = "RESIZE"
      config.window_background_opacity = 1.0
      config.macos_window_background_blur = 10
      config.window_padding = {
        left = 10,
        right = 10,
        top = 10,
        bottom = 10,
      }

      -- Tab bar
      config.enable_tab_bar = true
      config.use_fancy_tab_bar = true
      config.hide_tab_bar_if_only_one_tab = true
      config.tab_bar_at_bottom = false

      -- Shell
      config.default_prog = { "/run/current-system/sw/bin/nu" }

      -- Performance
      config.front_end = "WebGpu"
      config.max_fps = 120
      config.animation_fps = 60

      -- Cursor
      config.default_cursor_style = "SteadyBar"
      config.cursor_blink_rate = 500

      -- Scrollback
      config.scrollback_lines = 10000

      -- Keys
      config.keys = {
        -- Split panes
        {
          key = "d",
          mods = "CMD",
          action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
        },
        {
          key = "D",
          mods = "CMD|SHIFT",
          action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
        },
        -- Navigate panes
        {
          key = "LeftArrow",
          mods = "CMD|OPT",
          action = wezterm.action.ActivatePaneDirection("Left"),
        },
        {
          key = "RightArrow",
          mods = "CMD|OPT",
          action = wezterm.action.ActivatePaneDirection("Right"),
        },
        {
          key = "UpArrow",
          mods = "CMD|OPT",
          action = wezterm.action.ActivatePaneDirection("Up"),
        },
        {
          key = "DownArrow",
          mods = "CMD|OPT",
          action = wezterm.action.ActivatePaneDirection("Down"),
        },
        -- Close pane
        {
          key = "w",
          mods = "CMD",
          action = wezterm.action.CloseCurrentPane({ confirm = true }),
        },
      }

      return config
    '';
  };
}
