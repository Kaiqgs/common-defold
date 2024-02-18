local Event = require("common.event")
local M = {
    messages = {},
    on_tick = Event(),
    on_connect = Event(),
    tick = 0,
}
function M.register_message(key, payload)
    M.messages[key] = payload
end

function M.clear_messages()
    M.messages = {}
end

function M.connect(room)
    M.on_connect:invoke(room)
end
function M.tick(room)
    M.on_tick:invoke(room)
end

return M
