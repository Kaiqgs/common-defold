local M = {}

function M.choice(table)
	if #table == 0 then
		return nil
	end
	local index = math.random(1, #table)
	return table[index]
end


function M.random()
	return math.random()
end

function M.centerand()
	return M.random() * 2 - 1
end

function M.bool()
	return M.random() < 0.5
end

function M.randomr(m, n)
	return math.random(m, n)
end

function M.uvec3()
	return vmath.vector3(M.centerand(), M.centerand(), M.centerand())
end
return M
