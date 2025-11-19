return {

  {
    "rebelot/heirline.nvim",
    -- You can optionally lazy-load heirline on UiEnter
    -- to make sure all required plugins and colorschemes are loaded before setup
    -- event = "UiEnter",
    dependencies = {
      { "folke/noice.nvim" },
      {
        "Zeioth/heirline-components.nvim",
        dependencies = {
          "lewis6991/gitsigns.nvim",
          "nvim-telescope/telescope.nvim",
          "nvim-mini/mini.bufremove",
        },
      },
    },
    opts = {},
    config = function(_, opts)
      local heirline = require("heirline")
      local utils = require("heirline.utils")
      local conditions = require("heirline.conditions")
      local heirline_components = require("heirline-components.all")
      local hl = require("heirline-components.core.hl")
      local condition = require("heirline-components.core.condition")
      local function setup_colors()
        return {
          bright_bg = utils.get_highlight("Folded").bg,
          bright_fg = utils.get_highlight("Folded").fg,
          red = utils.get_highlight("DiagnosticError").fg,
          dark_red = utils.get_highlight("DiffDelete").bg,
          green = utils.get_highlight("String").fg,
          blue = utils.get_highlight("Function").fg,
          gray = utils.get_highlight("NonText").fg,
          orange = utils.get_highlight("Constant").fg,
          purple = utils.get_highlight("Statement").fg,
          cyan = utils.get_highlight("Special").fg,
          diag_WARN = utils.get_highlight("DiagnosticWarn").fg,
          diag_ERROR = utils.get_highlight("DiagnosticError").fg,
          diag_HINT = utils.get_highlight("DiagnosticHint").fg,
          diag_INFO = utils.get_highlight("DiagnosticInfo").fg,
          git_del = utils.get_highlight("diffDeleted").fg,
          git_add = utils.get_highlight("diffAdded").fg,
          git_change = utils.get_highlight("diffChanged").fg,
        }
      end

      -- require("heirline").load_colors(setup_colors)
      -- or pass it to config.opts.colors

      vim.api.nvim_create_augroup("Heirline", { clear = true })
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          utils.on_colorscheme(setup_colors)
        end,
        group = "Heirline",
      })
      local Navic = {
        condition = function()
          return require("nvim-navic").is_available()
        end,
        provider = function()
          return require("nvim-navic").get_location()
        end,
        update = "CursorMoved",
        hl = hl.get_attributes("git_diff"),
      }
      local ShowCmd = {
        condition = function()
          return require("noice").api.status.command.has()
        end,
        provider = require("noice").api.status.command.get,
      }

      local FileNameBlock = {
        -- let's first set up some attributes needed by this component and its children
        init = function(self)
          self.filename = vim.api.nvim_buf_get_name(0)
        end,
      }
      -- We can now define some children separately and add them later

      local FileIcon = {
        init = function(self)
          local filename = self.filename
          local extension = vim.fn.fnamemodify(filename, ":e")
          self.icon, self.icon_color =
            require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })
        end,
        provider = function(self)
          return self.icon and (self.icon .. " ")
        end,
        hl = function(self)
          return { fg = self.icon_color }
        end,
      }

      local FileName = {
        provider = function(self)
          -- first, trim the pattern relative to the current directory. For other
          -- options, see :h filename-modifers
          local filename = vim.fn.fnamemodify(self.filename, ":.")
          if filename == "" then
            return "[No Name]"
          end
          -- now, if the filename would occupy more than 1/4th of the available
          -- space, we trim the file path to its initials
          -- See Flexible Components section below for dynamic truncation
          if not conditions.width_percent_below(#filename, 0.25) then
            filename = vim.fn.pathshorten(filename)
          end
          return filename
        end,
        hl = { fg = utils.get_highlight("Directory").fg },
      }

      local FileFlags = {
        {
          condition = function()
            return vim.bo.modified
          end,
          provider = "[+]",
          hl = { fg = "green" },
        },
        {
          condition = function()
            return not vim.bo.modifiable or vim.bo.readonly
          end,
          provider = "",
          hl = { fg = "orange" },
        },
      }

      -- Now, let's say that we want the filename color to change if the buffer is
      -- modified. Of course, we could do that directly using the FileName.hl field,
      -- but we'll see how easy it is to alter existing components using a "modifier"
      -- component

      local FileNameModifer = {
        hl = function()
          if vim.bo.modified then
            -- use `force` because we need to override the child's hl foreground
            return { fg = "cyan", bold = true, force = true }
          end
        end,
      }

      -- let's add the children to our FileNameBlock component
      FileNameBlock = utils.insert(
        FileNameBlock,
        FileIcon,
        utils.insert(FileNameModifer, FileName), -- a new table where FileName is a child of FileNameModifier
        FileFlags,
        { provider = "%<" } -- this means that the statusline is cut here when there's not enough space
      )
      local TablineBufnr = {
        provider = function(self)
          return tostring(self.bufnr) .. ". "
        end,
        hl = "Comment",
      }

      -- we redefine the filename component, as we probably only want the tail and not the relative path
      local TablineFileName = {
        provider = function(self)
          -- self.filename will be defined later, just keep looking at the example!
          local filename = self.filename
          filename = filename == "" and "[No Name]" or vim.fn.fnamemodify(filename, ":t")
          return filename
        end,
        hl = function(self)
          return { bold = self.is_active or self.is_visible, italic = true }
        end,
      }

      -- this looks exactly like the FileFlags component that we saw in
      -- #crash-course-part-ii-filename-and-friends, but we are indexing the bufnr explicitly
      -- also, we are adding a nice icon for terminal buffers.
      local TablineFileFlags = {
        {
          condition = function(self)
            return vim.api.nvim_get_option_value("modified", { buf = self.bufnr })
          end,
          provider = "[+]",
          hl = { fg = "green" },
        },
        {
          condition = function(self)
            return not vim.api.nvim_get_option_value("modifiable", { buf = self.bufnr })
              or vim.api.nvim_get_option_value("readonly", { buf = self.bufnr })
          end,
          provider = function(self)
            if vim.api.nvim_get_option_value("buftype", { buf = self.bufnr }) == "terminal" then
              return "  "
            else
              return ""
            end
          end,
          hl = { fg = "orange" },
        },
      }

      -- Here the filename block finally comes together
      local TablineFileNameBlock = {
        init = function(self)
          self.filename = vim.api.nvim_buf_get_name(self.bufnr)
        end,
        hl = function(self)
          if self.is_active then
            return "TabLineSel"
          -- why not?
          -- elseif not vim.api.nvim_buf_is_loaded(self.bufnr) then
          --     return { fg = "gray" }
          else
            return "TabLine"
          end
        end,
        on_click = {
          callback = function(_, minwid, _, button)
            if button == "m" then -- close on mouse middle click
              vim.schedule(function()
                vim.api.nvim_buf_delete(minwid, { force = false })
              end)
            else
              vim.api.nvim_win_set_buf(0, minwid)
            end
          end,
          minwid = function(self)
            return self.bufnr
          end,
          name = "heirline_tabline_buffer_callback",
        },
        TablineBufnr,
        FileIcon, -- turns out the version defined in #crash-course-part-ii-filename-and-friends can be reutilized as is here!
        TablineFileName,
        TablineFileFlags,
      }

      -- a nice "x" button to close the buffer
      local TablineCloseButton = {
        condition = function(self)
          return not vim.api.nvim_get_option_value("modified", { buf = self.bufnr })
        end,
        { provider = " " },
        {
          provider = "",
          hl = { fg = "gray" },
          on_click = {
            callback = function(_, minwid)
              vim.schedule(function()
                vim.api.nvim_buf_delete(minwid, { force = false })
                vim.cmd.redrawtabline()
              end)
            end,
            minwid = function(self)
              return self.bufnr
            end,
            name = "heirline_tabline_close_buffer_callback",
          },
        },
      }

      -- The final touch!
      local TablineBufferBlock = utils.surround({ "", "" }, function(self)
        if self.is_active then
          return utils.get_highlight("TabLineSel").bg
        else
          return utils.get_highlight("TabLine").bg
        end
      end, { TablineFileNameBlock, TablineCloseButton })

      -- and here we go
      local BufferLine = utils.make_buflist(
        TablineBufferBlock,
        { provider = "", hl = { fg = "gray" } }, -- left truncation, optional (defaults to "<")
        { provider = "", hl = { fg = "gray" } } -- right trunctation, also optional (defaults to ...... yep, ">")
        -- by the way, open a lot of buffers and try clicking them ;)
      )
      local icons = require("config.icons")

      -- Setup
      heirline_components.init.subscribe_to_events()
      heirline.load_colors(heirline_components.hl.get_colors())
      heirline.setup(opts)

      heirline.setup({
        -- tabline = {
        --   BufferLine,
        -- },
        winbar = {
          { provider = "%=" },
          { Navic },
          { provider = "%=" },
          { FileNameBlock },
          { provider = "%=" },
          {
            heirline_components.component.diagnostics({
              surround = {
                separator = "left", -- where to add the separator.
                color = "diagnostics_bg", -- you can set a custom background color, for example "#444444".
                condition = require("heirline-components.all").condition.is_file, -- a function that determines when to display the component.
              },
            }),
          },
          { provider = "%=" },
        },
        statusline = {
          { heirline_components.component.mode({ mode_text = {} }) },
          {
            {
              flexible = 1,
              heirline_components.component.git_branch({
                git_branch = { icon = { kind = "GitBranch", padding = { right = 1 } } },
                surround = {
                  separator = "right", -- where to add the separator.
                  color = "git_branch_bg", -- you can set a custom background color, for example "#444444".
                  condition = require("heirline-components.all").condition.is_git_repo, -- a function that determines when to display the component.
                },
                hl = hl.get_attributes("git_branch"), -- you can specify your own highlight group here.
                on_click = { name = "<your_event_name", callback = function() end }, -- what happens when you click the component.
                update = { "User", pattern = "GitSignsUpdate" }, -- events that make the component refresh.
                init = require("heirline-components.all").init.update_events({ "BufEnter" }), -- what happens when the component starts.
              }),
            },
            {
              flexible = 4,
              heirline_components.component.diagnostics({
                surround = {
                  separator = "left", -- where to add the separator.
                  color = "diagnostics_bg", -- you can set a custom background color, for example "#444444".
                  condition = require("heirline-components.all").condition.is_file, -- a function that determines when to display the component.
                },
              }),
            },
          },
          {
            heirline_components.component.file_info({
              file_icon = { -- if set, displays a icon depending the current filetype.
                hl = hl.file_icon("statusline"),
                padding = { left = 1, right = 1 },
                condition = condition.is_file,
              },
              filename = {}, -- if set, displays the filename.
              filetype = false, -- if set, displays the filetype.
              file_modified = false, -- if set, displays a white dot if the file has been modified.
              file_read_only = { -- if set, displays a lock icon if the file is read only.
                padding = { left = 1, right = 1 },
                condition = condition.is_file,
              },
              surround = {
                separator = "right",
                color = "file_info_bg",
                condition = condition.has_filetype,
              },
              hl = hl.get_attributes("file_info"),
            }),
          },

          {
            heirline_components.component.cmd_info({
              showcmd = {
                padding = { left = 1 },
                condition = condition.is_statusline_showcmd,
              },
            }),
          },
          -- { Navic },
          { heirline_components.component.fill() },
          { ShowCmd },
          { heirline_components.component.git_diff() },
          { heirline_components.component.nav() },
        },
      })
    end,
  },
}
