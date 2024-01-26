local Event = require("common.event")
local M = {
  messages = {},
  tick = Event(),
}
function M.register_message(key, payload)
  M.messages[key] = payload
end

function M.clear_messages()
  M.messages = {}
end

function M.on_tick(room)
  M.tick:invoke(room)
end

return M
