local util = require("common.util")
local M = {
    close_stinger = hash("close_stinger"),
    open_stinger = hash("open_stinger"),
    closed_stinger = hash("closed_stinger"),
    opened_stinger = hash("opened_stinger"),
    shader_animation = function(...) end,
}
-- shader_animation = function(self, message_id, message, sender, done)
--     if message_id == hash("close_stinger") then
--
--         -- stinger.shader_animation
--         gui.play_flipbook(self.stinger, hash("close"), function()
--             msg.post(sender, "closed_stinger")
--         end)
--     elseif message_id == hash("open_stinger") then
--         if self.delay_open then
--             timer.delay(self.delay_open, false, function()
--                 gui.play_flipbook(self.stinger, hash("open"), function()
--                     msg.post(sender, "opened_stinger")
--                 end)
--             end)
--             return
--         end
--         gui.play_flipbook(self.stinger, hash("open"), function()
--             msg.post(sender, "opened_stinger")
--         end)
--     end
-- end,
return M
