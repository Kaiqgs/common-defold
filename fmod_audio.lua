local log_module = require("common.log")
local log = log_module.module("cmod")
local play_state = {
    playing = fmod.STUDIO_PLAYBACK_PLAYING,
    sustaining = fmod.STUDIO_PLAYBACK_SUSTAINING,
    stopped = fmod.STUDIO_PLAYBACK_STOPPED,
    startting = fmod.STUDIO_PLAYBACK_STARTING,
    stopping = fmod.STUDIO_PLAYBACK_STOPPING,
}
local M = {
    event_format = "event:/%s",
    data = {},
    play_state = play_state,
    started_once = {},
}
local default_instance = "default"

local function get_alias(event, instance_name)
    local alias = string.format("%s@%s", event, instance_name)
    return alias
end

local function get_instance(event, instance_name, create)
    assert(type(event) == "string", ("got event with format (%s)"):format(tostring(type(event))))
    instance_name = instance_name or default_instance
    local alias = get_alias(event, instance_name)
    local data = M.data[event]
    -- local has_been_played = (data ~= nil and not data.is_played or false)
    if data == nil then
        log:warn(string.format("event %s, does not exist", alias))
        return nil
    end

    local instance = data.instances[instance_name]
    if instance == nil and create then
        instance = data.description:create_instance()
        data.instances[instance_name] = instance
    elseif instance == nil then
        log:warn(string.format("instance %s, does not exist", alias))
    end

    return instance
end
function M.get_event_call_name(event)
    return string.format(M.event_format, event)
end
local function print_debug_info_fmod()
    --- What is below, helps debug fmod;
    -- https://github.com/dapetcu21/defold-fmod/blob/0ba3b3c9e3a465838f78b686cea0e491349b33e6/bridge/include/fmod_studio_common.h#L170
    print(type(fmod.studio), "Debugging fmod.studio")
    for k, v in pairs(fmod.studio) do
        print(k, v, "type", type(v))
    end
    print(type(fmod), "Debugging fmod")
    for k, v in pairs(fmod) do
        print(k, v, "type", type(v))
    end
end
function M.set_outline(outline)
    -- print_debug_info_fmod()
    for event, _ in pairs(outline) do
        log:info(("- event: `%s`"):format(event))
        local event_description = fmod.studio.system:get_event(M.get_event_call_name(event))
        local data = {
            description = event_description,
            instances = {},
            is_played = false,
        }
        data.instances[default_instance] = event_description:create_instance()
        M.started_once[event] = false
        M.data[event] = data
    end
end

---@param event string
function M.start(event, instance_name)
    local alias = get_alias(event, instance_name)

    local instance = get_instance(event, instance_name, true)
    if instance == nil then
        log:trace(string.format("attempting to start %s, but it does not exist", alias))
        return false
    end
    M.started_once[event] = true

    -- print("debug fmodaudio")
    -- pprint(M.data[event].instances)
    if instance:get_playback_state() ~= play_state.stopped then
        log:trace(
            string.format(
                "attempting to start %s, but it is already playing: %s",
                alias,
                tostring(instance:get_playback_state())
            )
        )
        return false
    end
    log:info(string.format("starting - %s", alias))
    instance:start()
    return instance
end

function M.get_playback_state(event, instance_name)
    local instance = get_instance(event, instance_name)
    if instance == nil then
        return nil
    end
    return instance:get_playback_state()
end

function M.stop(event, instance_name, stop_type)
    instance_name = instance_name or default_instance
    stop_type = stop_type or fmod.STUDIO_STOP_IMMEDIATE
    local alias = get_alias(event, instance_name)
    local instance = get_instance(event, instance_name)

    if instance == nil then
        log:warn(string.format("attempting to stop instance %s, does not exist", alias))
        return false
    end
    ---@cast instance table

    if instance:get_playback_state() ~= play_state.playing then
        log:warn(string.format("attempting to stop %s, but it is not playing", alias))
        return false
    end

    log:info(string.format("stopping %s", alias))
    instance:stop(stop_type)
    return true
end

function M.set_3d_attributes(event, instance_name, attributes)
    local alias = get_alias(event, instance_name)
    local instance = get_instance(event, instance_name, true)
    if instance == nil then
        log:trace(string.format("attempting to set 3D attributes on %s, does not exist", alias))
        return false
    end
    ---@cast instance table

    local attr = instance:get_3d_attributes()
    attr.position = attributes.position or attr.position
    attr.velocity = attributes.velocity or vmath.vector3()
    attr.forward = attributes.forward or vmath.vector3(1, 0, 0)
    attr.up = attributes.up or vmath.vector3(0, 1, 0)
    -- print("instance 3d attr")
    -- pprint(attributes)
    instance:set_3d_attributes(attr)
    -- print("instance after", event, instance_name)
    -- local attributes = instance:get_3d_attributes()
    -- pprint("position", attributes.position)
    -- pprint("forward", attributes.forward)
    -- pprint("up", attributes.up)
end

function M.set_listener_attributes(attributes, listener_idx)
    listener_idx = listener_idx or 0
    local attr = fmod.studio.system:get_listener_attributes(listener_idx)
    attr.position = attributes.position
    attr.velocity = attributes.velocity
    attr.forward = attributes.forward
    attr.up = attributes.up
    -- print("listener 3d attr")
    -- pprint(attributes)
    fmod.studio.system:set_listener_attributes(0, attr)
    -- print("listener 3d attr after")
    local attributes = fmod.studio.system:get_listener_attributes(listener_idx)
    -- pprint("position", attributes.position)
    -- pprint("forward", attributes.forward)
    -- pprint("up", attributes.up)
end

function M.xy_to_xz(vector)
    return vmath.vector3(vector.x, vector.z, vector.y)
end

function M.final()
    log:warn("Unplayed events include:")
    for event, was_played in pairs(M.started_once) do
        if not was_played then
            log:warn(("\t- %s"):format(event))
        end
    end
end

function M.start_at(position, event, instance_name)
    M.set_3d_attributes(event, instance_name, {
        position = M.xy_to_xz(position),
    })
    M.start(event, instance_name)
end

function M.release(event, instance_name)
    local instance = get_instance(event, instance_name)
    if instance == nil then
        return
    end
    M.stop(event, instance_name)
    M.data[event][instance_name] = nil
end

function M.set_parameter_by_name(event, instance_name, param, value, ignoreseek)
    local instance = get_instance(event, instance_name)
    if instance == nil then
        return
    end
    instance:set_parameter_by_name(param, value, ignoreseek or false)
end

return M
