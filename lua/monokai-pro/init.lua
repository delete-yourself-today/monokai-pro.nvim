---@class MonokaiPro
local M = {}

local config_module = require("monokai-pro.config")
local day_night_augroup = vim.api.nvim_create_augroup("MonokaiProDayNight", { clear = true })

local function setup_day_night_autocmd()
  vim.api.nvim_clear_autocmds({ group = day_night_augroup })

  local config = config_module.get()
  local day_night = config.day_night
  if not (day_night and day_night.enable) then
    return
  end

  vim.api.nvim_create_autocmd("OptionSet", {
    group = day_night_augroup,
    pattern = "background",
    callback = function()
      local previous_filter = config_module.get().filter

      config_module.apply_appearance()

      if vim.g.colors_name == "monokai-pro" and config_module.get().filter ~= previous_filter then
        M.load()
      end
    end,
  })
end

--- Setup the colorscheme with user options
---@param user_config? MonokaiPro.Config
function M.setup(user_config)
  config_module.setup(user_config)
  setup_day_night_autocmd()
end

--- Load the colorscheme
function M.load()
  require("monokai-pro.theme").load()

  -- Defer command creation to avoid loading commands module during startup
  vim.schedule(function()
    local commands = require("monokai-pro.commands")
    commands.create()
  end)

  vim.api.nvim_exec_autocmds("ColorScheme", { pattern = vim.g.colors_name })
end

--- Switch to a specific filter
---@param filter MonokaiPro.Filter
function M.set_filter(filter)
  if not config_module.is_valid_filter(filter) then
    vim.notify(
      -- style: ignore
      string.format(
        "MonokaiPro: Invalid filter '%s'. Valid options: %s",
        filter,
        table.concat(config_module.get_filters(), ", ")
      ),
      vim.log.levels.WARN
    )
    return
  end

  config_module.extend({ filter = filter })
  require("monokai-pro.theme").clear_cache()
  M.load()
end

--- Get the current configuration
---@return MonokaiPro.Config
function M.get_config()
  return config_module.get()
end

--- Get the current scheme
---@return MonokaiPro.Scheme
function M.get_scheme()
  return require("monokai-pro.theme").get_scheme()
end

--- Get color utilities
---@return MonokaiPro.Colors
function M.get_colors()
  return require("monokai-pro.colors")
end

--- Get a palette by filter name
---@param filter? MonokaiPro.Filter
---@return MonokaiPro.Palette
function M.get_palette(filter)
  local palette_module = require("monokai-pro.palette")
  return palette_module.load(filter or config_module.get().filter or "pro")
end

--- Get colors in NvChad's base46 theme format
---@param filter? MonokaiPro.Filter
---@return table NvChad base46 theme table with base_30, base_16, and type
function M.nvchad(filter)
  return require("monokai-pro.nvchad").get(filter)
end

return M
