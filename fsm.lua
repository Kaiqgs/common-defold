local _stateCounter = 0
local util = require("common.util")
local function emptyFunc(...) end
local function Contains(tbl, value)
	for _, v in pairs(tbl) do
		if v == value then
			return true
		end
	end
	return false
end
local printout = true
local FiniteState = util.NewClass({})
local FiniteStateMachine = util.NewClass({})
function FiniteState.new(o)
	_stateCounter = _stateCounter + 1
	o = o or {}
	---@class FiniteState
	---@field context any
	---@field name string
	---@field done boolean
	---@field enter function
	---@field exit function
	---@field predicate function
	---@field update function
	local new = {
		name = o.name or tostring(_stateCounter),
		context = nil,
		done = o.done or false,
	}
	local unreplaceable = { "name", "context", "enter", "exit", "predicate", "update" }
	for k, v in pairs(o) do
		if not Contains(unreplaceable, k) then
			new[k] = v
		end
	end
	local self = setmetatable(new, FiniteState)
    self.__index = self
	function self:enter(...)
		self.done = o.done or false;
		(o.enter or emptyFunc)(self, ...)
		self.context = ...
	end

	function self:exit(...)
		(o.exit or emptyFunc)(self, ...)
		local ctx = self.context
		self.context = nil
		return ctx
	end

	function self:update(...)
		(o.update or emptyFunc)(self, ...)
	end

	---@return boolean
	function self:predicate(...)
		-- return o.done or not o.predicate or (o.predicate and o.predicate(self, ...))
		return self.done or not not (o.predicate or emptyFunc)(self, ...)
	end

	return self
end

function FiniteStateMachine.new(o)
	o = o or {}
	local states = {}
	for _, v in pairs(o.states or {}) do
		states[v.name] = v
	end

	local self = setmetatable(
	---@class FiniteStateMachine
	---@field states table<string, FiniteState>
	---@field state FiniteState
	---@field transitions table<string, table<string, boolean>>
		{
			states = states,
			state = nil,
			transitions = o.transitions or {},
		},
		FiniteStateMachine
	)
    self.__index = self
	return self
end

---Adds transition
---@param state_a FiniteState
---@param state_b FiniteState
---@return boolean
function FiniteStateMachine:transition(state_a, state_b)
	-- self.transitions =
	self.transitions[state_a.name] = self.transitions[state_a.name] or {}
	self.transitions[state_a.name][state_b.name] = true
	return self
end

---Set initial state
---@param state FiniteState
function FiniteStateMachine:start(state, ...)
	assert(self.state == nil)
	self.state = state
	self.state:enter(... or {})
	return self
end

function FiniteStateMachine:update(...)
	self.state:update(...)
	for name_b, _ in pairs(self.transitions[self.state.name] or {}) do
		local otherstate = self.states[name_b]
		if otherstate then
			if self.state:predicate(otherstate) then
				local laststate = self.state
				local ctx = laststate:exit()
				self.state = otherstate
				self.state:enter(ctx)
				break
			end
		end
	end

	-- if self.state:predicate(value
end

local function _moduleAssert()
	-- Semaphore
	local states = {
		red = FiniteState({ name = "red", done = true }),
		yellow = FiniteState({ name = "yellow", done = true }),
		green = FiniteState({ name = "green", done = true }),
	}
	local fsm = FiniteStateMachine({
		    states = util.GetValues(states),
	    })
	    :transition(states.green, states.yellow)
	    :transition(states.yellow, states.red)
	    :transition(states.red, states.green)
	    :start(states.green, { chickencrossing = true })

	assert(fsm.state.name == states.green.name, "Bad initialization")
	assert(fsm.state.context.chickencrossing, "Invalid context movement")
	fsm:update()
	assert(fsm.state.context.chickencrossing, "Invalid context movement")
	assert(fsm.state.name == states.yellow.name, "Bad transition = " .. fsm.state.name)
	fsm:update()
	assert(fsm.state.context.chickencrossing, "Invalid context movement")
	assert(fsm.state.name == states.red.name, "Bad transition = " .. fsm.state.name)
	fsm:update()
	assert(fsm.state.context.chickencrossing, "Invalid context movement")
	assert(fsm.state.name == states.green.name, "Bad transition = " .. fsm.state.name)
end

_moduleAssert()

return {
	FiniteState = FiniteState,
	FiniteStateMachine = FiniteStateMachine,
	NilName = "__DefinitelyNotAStateName__",
}
