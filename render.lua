local M = {}
function M.line(from, to)
	msg.post("@render:", "draw_line", { start_point = from, end_point = to, color = vmath.vector4(1, 0, 0, 1) })
end

function M.debug_text(text, position, color)
	msg.post("@render:", "draw_text", {
		text = text,
		position = position,
		color = color or vmath.vector4(1, 0, 0, 1),
	})
end

return M
