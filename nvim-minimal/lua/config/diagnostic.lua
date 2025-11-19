-- vim.diagnostic.enable = true
local icons = require("config.icons")
vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = icons.diagnostics.Error,
      [vim.diagnostic.severity.WARN] = icons.diagnostics.Warn,
      [vim.diagnostic.severity.INFO] = icons.diagnostics.Info,
      [vim.diagnostic.severity.HINT] = icons.diagnostics.Hint,
    },
  },
  underline = false,
  virtual_lines = {
    current_line = true,
    format = function(diagnostic)
      if diagnostic.severity == vim.diagnostic.severity.ERROR then
        return string.format("%s %s", icons.diagnostics.Error, diagnostic.message)
      elseif diagnostic.severity == vim.diagnostic.severity.WARN then
        return string.format("%s %s", icons.diagnostics.Warn, diagnostic.message)
      elseif diagnostic.severity == vim.diagnostic.severity.HINT then
        return string.format("%s %s", icons.diagnostics.Hint, diagnostic.message)
      else
        return string.format("%s %s", icons.diagnostics.Info, diagnostic.message)
      end
    end,
  },
})
