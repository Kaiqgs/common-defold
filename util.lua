local log_module = require("common.log")
local M = { NewClass = require("common.new_class").new_class }
local log = log_module.module("util")

M.empty_fn = function(...) end

M.on_message_map = function(message_mapping)
    local function on_message(self, message_id, message, sender)
        local action = message_mapping[message_id]
        if action then
            action(self, message_id, message, sender)
        elseif action ~= false then
            local wrn_msg = string.format(
                "%s have unhandled message of id: %s from %s",
                tostring(msg.url()),
                tostring(message_id),
                tostring(sender)
            )
            log:warn(wrn_msg)
        end
    end
    return on_message
end

M.on_input_map = function(input_mapping)
    local function on_input(self, action_id, action)
        local func = input_mapping[action_id]
        if func then
            func(self, action_id, action)
        elseif action ~= false and sys.get_engine_info().debug then
            local wrn_msg = string.format("%s did not handle input of id: %s", tostring(msg.url()), tostring(action_id))
            log:warn(wrn_msg)
        end
    end
    return on_input
end

function M.assert_contains(object, properties)
    for _, k in ipairs(properties) do
        assert(object[k], string.format("object does not contain property: %s", k))
    end
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
