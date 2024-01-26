return function(typetbl)
    typetbl.__index = typetbl
    setmetatable(typetbl, {
        __call = function(cls, ...)
            return cls.new(...)
        end,
    })
    return typetbl
end
