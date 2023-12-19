-- this can and will eventually overflow
local GlobalEventCounter = 0
local util = require("common.util")

---@class Event
---@field listeners EventListener[]
local M = util.NewClass({})
function M.new()
	local self = setmetatable({ listeners = {} }, M)
	return self
end

---@param callback function
function M:subscribe(callback)
	table.insert(
		self.listeners,
		---@class EventListener
		---@field id integer
		---@field callback function
		{
			id = GlobalEventCounter,
			callback = function(...)
				callback(...)
			end,
		}
	)
	GlobalEventCounter = GlobalEventCounter + 1
end

---@param id integer
function M:unsubscribe(id)
	for i, listener in ipairs(self.listeners) do
		if listener.id == id then
			table.remove(self.listeners, i)
			return
		end
	end
end

function M:flush()
	self.listeners = {}
end

function M:invoke(...)
	for _, listener in ipairs(self.listeners) do
		listener.callback(...)
	end
end

local function _moduleAssert()
	local set_test = {}
	local n = 10
	local test = M()
	for i in util.irange(n) do
		test:subscribe(function()
			table.insert(set_test, i)
		end)
	end
	test:invoke()
	assert(#set_test == n)
end
_moduleAssert()

return M
