local M = {}
local util = require("common.util")
local Event = require("common.event")
local audio = require("common.audio")

local function simpleShadow(node, parent, color, offset, layer)
	local shadoweePos = gui.get_position(node)
	local shadow = gui.clone(node)
	gui.set_inherit_alpha(shadow, false)
	gui.set_parent(shadow, parent)
	gui.move_below(shadow, node)
	gui.set_layer(shadow, layer)
	gui.set_color(shadow, color)
	gui.set_position(shadow, shadoweePos + offset)
	return shadow
end

--- @class ExtraNode
--- @field node any
--- @field shadow any
--- @field parent any
--- @field on_press Event
--- @field on_release Event
--- @field on_button_press function
--- @field set_text function
local ExtraNode = util.NewClass({})

function ExtraNode.new(node_id, layer, shadowColor)
	assert(node_id, "node_id is nil")

	-- shadow related
	local textColor = vmath.vector4(1, 1, 1, 1)
	shadowColor = shadowColor or vmath.vector4(0, 0, 0, 1)
	local offset = vmath.vector3(1, -1, 0)

	local node = gui.get_node(node_id)
	local parent = gui.get_parent(node)

	local new = {
		node = node,
		parent = parent,
		shadow = simpleShadow(node, parent, shadowColor, offset, layer),
		on_press = Event(),
		on_release = Event(),
	}
	local self = setmetatable(new, ExtraNode)
	return self
end

function ExtraNode:on_button_press(action)
	local touching = gui.pick_node(self.node, action.x, action.y)
	if not touching then
		return
	end
	if action.pressed and not self.pressed then
		audio.play("blip")

		self.pressed = true
		gui.set_position(self.node, gui.get_position(self.node) + vmath.vector3(1, -1, 0))
		self.on_press:invoke(action)
	end
	if action.released and self.pressed then
		self.pressed = false
		gui.set_position(self.node, gui.get_position(self.node) + vmath.vector3(-1, 1, 0))
		self.on_release:invoke(action)
	end
	-- print(string.format("pressed %s, released %s, repeated %s", action.pressed, action.released, action.repeated))
end

function ExtraNode:set_text(value)
	gui.set_text(self.node, value)
	gui.set_text(self.shadow, value)
end

function ExtraNode:animate_text(value, delay, base_str)
	delay = delay or 0.1
	base_str = base_str or ""
	for i = 1, #value do
		timer.delay(delay * i, false, function()
			base_str = base_str .. value:sub(i, i)
			self:set_text(base_str)
			audio.play("type")
		end)
	end
	return delay * #value
end

function ExtraNode:set_alpha(value)
	gui.set_alpha(self.node, value)
	gui.set_alpha(self.shadow, value)
end

function ExtraNode:set_enabled(value)
	gui.set_enabled(self.node, value)
	gui.set_enabled(self.shadow, value)
end

M.addShadow = simpleShadow
M.ExtraNode = ExtraNode

---comment
---@param node_ids any
---@param layer string
---@param shadowColor any
---@return table<string, ExtraNode>
function M.extrafy(node_ids, layer, shadowColor)
	for node_id, _ in pairs(node_ids) do
		node_ids[node_id] = ExtraNode.new(node_id, layer, shadowColor)
	end
	return node_ids
end

return M
