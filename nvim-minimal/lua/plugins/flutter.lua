return {
  {
    "nvim-flutter/flutter-tools.nvim",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim", -- optional for vim.ui.select
    },
    config = function()
      require("flutter-tools").setup({
        lsp = {
          color = { -- show the derived colours for dart variables
            enabled = true, -- whether or not to highlight color variables at all, only supported on flutter >= 2.10
            background = false, -- highlight the background
            background_color = nil, -- required, when background is transparent (i.e. background_color = { r = 19, g = 17, b = 24},)
            foreground = false, -- highlight the foreground
            virtual_text = true, -- show the highlight using virtual text
            virtual_text_str = "■", -- the virtual text character to highlight
          },
          on_attach = function(client, bufnr)
            require("notify")("<leader> iH to enable inlay hints :)", "info", { title = "flutter-tools.nvim" })
            vim.keymap.set("n", "<leader>iH", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
              require("notify")(
                string.format("Inlay Hints %s", vim.lsp.inlay_hint.is_enabled() and "Enabled" or "Disabled"),
                "info",
                { title = "flutter-tools.nvim" }
              )
            end, { desc = "Toggle Inlay Hints" })
          end,
          -- capabilities = my_custom_capabilities, -- e.g. lsp_status capabilities
          --- OR you can specify a function to deactivate or change or control how the config is created
          -- capabilities = function(config)
          --   config.specificThingIDontWant = false
          --   return config
          -- end,
          -- see the link below for details on each option:
          -- https://github.com/dart-lang/sdk/blob/master/pkg/analysis_server/tool/lsp_spec/README.md#client-workspace-configuration
          settings = {
            showTodos = true,
            completeFunctionCalls = true,
            renameFilesWithClasses = "prompt", -- "always"
            enableSnippets = true,
            updateImportsOnRename = true, -- Whether to update imports and other directives when files are renamed. Required for `FlutterRename` command.
            inlayHints = {
              parameterNames = { enabled = true },
              parameterTypes = { enabled = true },
              returnTypes = { enabled = true },
              typeArguments = { enabled = true },
              variableTypes = { enabled = true },
            },
          },
        },
      })
    end,
  },
}
