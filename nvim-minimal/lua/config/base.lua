-- This is the file loaded before everything else. a good place for vim.opt settings

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true

vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.scrolloff = 10

vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.o.signcolumn = "yes"

vim.o.laststatus = os.getenv("TMUX") and 0 or 3
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
