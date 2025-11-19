-- Clipboard
vim.keymap.set("n", "<leader>y", '"+y', { noremap = true, silent = true, desc = "Yank to clipboard" })
vim.keymap.set({ "v", "x" }, "<leader>y", '"+y', { noremap = true, silent = true, desc = "Yank to clipboard" })
vim.keymap.set(
  { "n", "v", "x" },
  "<leader>yy",
  '"+yy',
  { noremap = true, silent = true, desc = "Yank line to clipboard" }
)
vim.keymap.set(
  { "n", "v", "x" },
  "<leader>Y",
  '"+yy',
  { noremap = true, silent = true, desc = "Yank line to clipboard" }
)
vim.keymap.set({ "n" }, "v<C-a>", "gg0vG$", { noremap = true, silent = true, desc = "Select all" })
vim.keymap.set({ "n", "v", "x" }, "<leader>p", '"+p', { noremap = true, silent = true, desc = "Paste from clipboard" })
vim.keymap.set(
  "i",
  "<C-p>",
  "<C-r><C-p>+",
  { noremap = true, silent = true, desc = "Paste from clipboard from within insert mode" }
)

-- Diagnostics

vim.keymap.set("n", "]e", function()
  vim.diagnostic.jump({ severity = { vim.diagnostic.severity.ERROR }, count = vim.v.count1, float = true })
end, { desc = "Next Error", noremap = true, silent = true })
vim.keymap.set("n", "[e", function()
  vim.diagnostic.jump({ severity = { vim.diagnostic.severity.ERROR }, count = -vim.v.count1, float = true })
end, { desc = "Previous Error", noremap = true, silent = true })

vim.keymap.set("n", "<leader>ee", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
  print(string.format("Diagnostics %s", vim.diagnostic.is_enabled() and "ON" or "OFF"))
end, { desc = "Toggle Diagnostics", noremap = true, silent = true })
