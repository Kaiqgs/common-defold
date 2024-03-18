local log_module = require("common.log")
local M = { NewClass = require("common.new_class").new_class }
local log = log_module.module("util")

M.on_message_map = function(message_mapping)
    local on_message = function(self, message_id, message, sender)
        local action = message_mapping[message_id]
        if action ~= nil then
            action(self, message_id, message, sender)
        else
            local wrn_msg = string.format("unhandled message of id: %s from %s", message_id, sender)
            log:warn(wrn_msg)
        end
    end
    return on_message
end

function M.shallow_copy(table)
    local copy = {}
    for k, v in pairs(table) do
        copy[k] = v
    end
    return copy
end

M.ModuloWrap = function(one_indexed, n, delta)
    local zero_indexed = one_indexed - 1
    local modulo_wrap = (zero_indexed + delta) % n
    return modulo_wrap + 1
end
M.GetValues = function(tbl)
    local values = {}
    for _, v in pairs(tbl) do
        table.insert(values, v)
    end
    return values
end

local assertGetValues = M.GetValues({ a = 1, b = 2, c = 3 })
for _, v in ipairs(assertGetValues) do
    assert(v == 1 or v == 2 or v == 3)
end

function M.irange(i)
    local _i = 0
    return function()
        _i = _i + 1
        if _i <= i then
            return _i
        end
    end
end

local ran_names = {}
function M.run_once(name, fn)
   if ran_names[name] == nil then
        ran_names[name] = 1
        fn()
   end
end

return M
