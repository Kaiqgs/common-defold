--- @class ExtraNode
--- @field pressed boolean
--- @field hovered boolean
--- @field node any
--- @field shadow any
--- @field parent any
--- @field on_hover Event
--- @field on_unhover Event
--- @field on_press Event
--- @field on_release Event
--- @field set_text fun(self, text)
--- @field set_enabled fun(self, value)
--- @field set_alpha fun(self, value)
--- @field is_enabled fun(self) :boolean
--- @field on_button_press fun(self, action)
--- @field animate_text fun(self, value, delay, base_str) : number
--- @field apply fun(self, modifier)
--- @field play_flipbook fun(self, animation, complete_function, play_properties)
ExtraNode = {}

---@class CommonGui
---@field default_shadow_offset vector3
---@field default_shadow_color vector3
---@field default_click_offset vector3
---@field extrafy fun(nodes)
---@field on_input_touch fun(nodes_list) : fun(_, _, action)
CommonGui = {}

return M
