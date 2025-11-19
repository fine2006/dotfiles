return {
  -- add gruvbox
  {
    "tiagovla/tokyodark.nvim",
    opts = {},
  },
  -- { "e-ink-colorscheme/e-ink.nvim" },
  { "rjshkhr/shadow.nvim" },
  { "ray-x/starry.nvim" },
  { "yunlingz/equinusocio-material.vim" },
  { "dasupradyumna/midnight.nvim" },
  { "olimorris/onedarkpro.nvim" },
  { "uhs-robert/oasis.nvim" },

  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyodark",
    },
  },
}
