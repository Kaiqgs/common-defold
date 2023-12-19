local Event = require("common.event")
local pools = {
	play = {},
	stop = {},
}
local queue = {
	play = {},
	stop = {},
}
local M = {
	unregistered = false,
	on_register = Event(),
}

function M.play(audio_pool_name)
	local evt = pools.play[audio_pool_name]

	if evt == nil then
		print(string.format("warning: no audio_pool named %s to play", audio_pool_name))
		pools.play[audio_pool_name] = Event()
	end
	evt = pools.play[audio_pool_name]
	evt:invoke()
end

function M.stop(audio_pool_name)
	local evt = pools.stop[audio_pool_name]

	if evt == nil then
		print(string.format("warning: no audio_pool named %s to stop", audio_pool_name))
		pools.stop[audio_pool_name] = Event()
	end
	evt = pools.stop[audio_pool_name]
	evt:invoke()
end

function M.pool_play(name)
	if pools.play[name] == nil then
		pools.play[name] = Event()
	end
	return pools.play[name]
end

function M.pool_stop(name)
	if pools.stop[name] == nil then
		pools.stop[name] = Event()
	end
	return pools.stop[name]
end

function M.register(outline, gameobject)
	M.on_register:invoke(outline, gameobject)
	M.rgeistered = true
end

return M
