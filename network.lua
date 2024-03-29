local Event = require("common.event")
local Deque = require("common.deque")
local nc = require("common.new_class")
local util = require("common.util")
local log = require("common.log")
log = log.module("commonet")

---@class Input
---@field value table
---@field name string
---@field tick_reference number
---@field apply function
local Input = nc.new_class({})
Input.new = nc.new_init_fn(Input, {
    tick_reference = 0,
    value = {},
    name = "",
    apply = function(...) end,
})

---@class CommonNetwork
---@field messages table
---@field ticked Event
local M = {
    messages = {},
    ticked = Event(), -- was: on_tick
    connected = Event(), -- was: on_connect
    -- Client needs to be manually invoked
    client_ticked = Event(),
    input_queue = Deque(),
    tick = 0,
    Input = Input,
    tick_rate_s = 20 / 1000,
    -- list of messages
    sanitization_messages = {},
    tick_dif = 0,
}
function M.set_tick_rate(tick_rate)
    M.tick_rate_s = tick_rate
end

function M.set_sanitization_messages(sm)
    M.sanitization_messages = sm
end
function M.register_message(key, payload)
    M.messages[key] = payload or {}
end

function M.clear_messages()
    M.messages = {}
end

function M.on_connect(room)
    M.connected:invoke(room)
end

function M.clear_outsynced_inputs(server_tick)
    local start = M.input_queue:size()
    while M.input_queue:size() > 0 and M.input_queue:peek().tick_reference < (server_tick or 0) do
        M.input_queue:pop()
        if M.input_queue:size() == 0 then
            break
        end
    end
    local input_count = start - M.input_queue:size()
    if input_count > 0 then
        log:info(string.format("removed %d inputs", input_count))
    end
end

function M.on_tick(room)
    M.ticked:invoke(room)
end

function M.on_client_ticked(room)
    M.clear_outsynced_inputs(room.state.tick)
    M.client_ticked:invoke(room, M.tick, room.state.tick or 0)
    M.tick = M.tick + 1
    M.tick_dif = (room.state.tick or 0) - M.tick
    log:info(string.format(
        "client_t=%d, server_tick=%d    | delta=%d",
        M.tick or -999,
        room.state.tick or -999,
        -- agentobj.tickReference or -999,
        M.tick_dif or 999
    ))
end

---Represents
---@param input any
---@param name string
---@param apply fun(agentobj)
function M.on_input(input, name, apply)
    M.input_queue:push(Input({
        tick_reference = M.tick or 0,
        value = input,
        name = name,
        apply = apply,
    }))
    M.register_message(name, input)
end

local function test_network()
    print("hey")
    -- debug.debug()
    -- local function test_input_gets_cleaned()
    --     M.on_input({x=1, y=1}, "move")
    --     local mockRoom = {
    --         state = {
    --             tick = 1,
    --             agents = {{
    --
    --             }}
    --         }
    --     }
    --     M.on_client_ticked(mockRoom)
    --     assert(#M.input_queue.list)
    --
    -- end
end

util.run_once("network_test", test_network)

return M
