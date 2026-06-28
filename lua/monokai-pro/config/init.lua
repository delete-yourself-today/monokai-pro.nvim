---@class MonokaiPro.ConfigModule
local M = {}

local defaults = require("monokai-pro.config.defaults")

---@type MonokaiPro.Config
local current_config = vim.deepcopy(defaults)

--- Resolve the filter for the current appearance.
---@return MonokaiPro.Filter
function M.resolve_filter()
  local day_night = current_config.day_night
  if day_night and day_night.enable then
    return vim.o.background == "light" and day_night.day_filter or day_night.night_filter
  end

  if vim.o.background == "light" and current_config.filter ~= "light" then
    return "light"
  end

  return current_config.filter or defaults.filter
end

--- Apply appearance-sensitive filter settings to the current config.
function M.apply_appearance()
  current_config.filter = M.resolve_filter()
end

--- Setup the configuration
---@param user_config? MonokaiPro.Config
function M.setup(user_config)
  current_config = vim.tbl_deep_extend("force", vim.deepcopy(defaults), user_config or {})
  M.apply_appearance()
end

--- Extend the current configuration (used when switching filters)
---@param user_config? MonokaiPro.Config
function M.extend(user_config)
  current_config = vim.tbl_deep_extend("force", current_config, user_config or {})
end

--- Get the current configuration
---@return MonokaiPro.Config
function M.get()
  return current_config
end

--- Check if the current appearance is light.
---@return boolean
function M.is_daytime()
  return vim.o.background == "light"
end

--- Get all available filters
---@return MonokaiPro.Filter[]
function M.get_filters()
  return { "pro", "classic", "octagon", "machine", "ristretto", "spectrum", "light" }
end

--- Check if a filter is valid
---@param filter string
---@return boolean
function M.is_valid_filter(filter)
  return vim.tbl_contains(M.get_filters(), filter)
end

return M
