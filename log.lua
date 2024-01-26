local NewClass = require("common.new_class")
local matching = nil

local Logger = NewClass({})
function Logger.new(namespace)
  --- @class Logger
  --- @field namespace string
  --- @field info fun(...)
  --- @field warn fun(...)
  --- @field error fun(...)
  local self = setmetatable({ namespace = namespace }, Logger)
  self.__index = self
  return self
end

function Logger:_meta(metaname)
  self[metaname] = function(_, ...)
    if matching == nil then
      local namespace = self.namespace and self.namespace .. "| " or ""
      print(string.format("%s%s: ", namespace, metaname), ...)
    elseif matching ~= nil then
      --TODO: add string matching and level filter
      assert(false, "not implemented")
    end
  end
end

Logger:_meta("info")
Logger:_meta("warn")
Logger:_meta("error")

---@type Logger
local M = Logger()

---Creates a logger at module level
---@param name string
---@return Logger
function M.module(name)
  return Logger(name)
end

return M
