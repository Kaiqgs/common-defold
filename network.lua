local M = {
    messages = {}
}
function M.register_message(key, payload)
  M.messages[key] = payload
end

function M.on_tick()
  M.messages = {}
end


return M
