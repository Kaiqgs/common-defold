local util = require("common.util")
local M = {}

function M.repeat_list(v, n)
    local list = {}
    for _ in util.irange(n) do
        table.insert(list, v)
    end
    return list
end

function M.flatten2d(list)
    local result = {}
    for i, v in ipairs(list) do
        for _, vv in ipairs(v) do
            table.insert(result, vv)
        end
    end
    return result
end
function M.extend(...)
    local tbl = {}
    for _, v in ipairs({ ... }) do
        for k, nv in pairs(v) do
            tbl[k] = nv
        end
    end
    return tbl
end

function M.find(tbl, value, comparator)
    comparator = comparator or function(a, b)
        return a == b
    end
    for i, v in ipairs(tbl) do
        if comparator(v, value) then
            return i
        end
    end
end

function M.values(tbl)
    local values = {}
    for _, v in pairs(tbl) do
        table.insert(values, v)
    end
    return values
end

function M.keys(tbl)
    local keys = {}
    for k, _ in pairs(tbl) do
        table.insert(keys, k)
    end
    return keys
end

--- @return boolean
function M.any(tbl, predicate)
    predicate = predicate or function(v)
        return v
    end
    for _, v in pairs(tbl) do
        if predicate(v) then
            return true
        end
    end
    return false
end

--- @return boolean
function M.all(tbl, predicate)
    predicate = predicate or function(v)
        return v
    end
    for _, v in pairs(tbl) do
        if not predicate(v) then
            return false
        end
    end
    return true
end

function M.concat(tbla, tblb)
    local tbl = {}
    for _, v in ipairs(tbla) do
        table.insert(tbl, v)
    end
    for _, v in ipairs(tblb) do
        table.insert(tbl, v)
    end
    return tbl
end

function M.cap(tbl, n)
    local cap = {}
    for i = 1, n do
        table.insert(cap, tbl[i])
    end
    return cap
end

function M.shallow_copy(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        copy[k] = v
    end
    return copy
end

return M
