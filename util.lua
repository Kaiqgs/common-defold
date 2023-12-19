local M = {}

M.ModuloWrap = function(one_indexed, n, delta)
	local zero_indexed = one_indexed - 1
	local modulo_wrap = (zero_indexed + delta) % n
	return modulo_wrap + 1
end
M.GetValues = function(tbl)
	local values = {}
	for _, v in pairs(tbl) do
		table.insert(values, v)
	end
	return values
end

local assertGetValues = M.GetValues({ a = 1, b = 2, c = 3 })
for _, v in ipairs(assertGetValues) do
	assert(v == 1 or v == 2 or v == 3)
end

function M.NewClass(typetbl)
	typetbl.__index = typetbl
	setmetatable(typetbl, {
		__call = function(cls, ...)
			return cls.new(...)
		end,
	})
	return typetbl
end

function M.irange(i)
	local _i = 0
	return function()
		_i = _i + 1
		if _i <= i then
			return _i
		end
	end
end

return M
