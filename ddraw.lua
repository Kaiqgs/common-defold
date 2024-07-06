local camera = require("orthographic.camera")
local M = {}
function M.line(from, to, color)
    msg.post("@render:", "draw_line", { start_point = from, end_point = to, color = color or vmath.vector4(1, 0, 0, 1) })
end

function M.debug_text(text, position, color)
    msg.post("@render:", "draw_debug_text", {
        text = text,
        position = position,
        color = color or vmath.vector4(1, 0, 0, 1),
    })
end
function M.debug_text_world(text, position, color, camera_id)
    local screen_position = camera.world_to_screen(camera_id, position)
    M.debug_text(text, screen_position, color)
end

return M
