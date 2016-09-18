--[[
@auth   mum-chen
@desc   common utils
@date   2016 09 11 
@update 2016 09 16 add random function
--]]
--============ include and declare constant ===============
local json = require('lib.json')
local socket = require('socket')
local gettime = socket.gettime
math.randomseed(gettime())

--======= public function ==================================
local function random(n, m)
    -- TODO check
    return math.random(n, m)
end

local function random_port()
    return random(1000,65535)
end

--[[
@method readonly
@desc   generate a readonly table
@param  t :table
--]]
local function readonly(t)
    local proxy = {}
    local mt = {
        __index = t,
        __newindex = function (t, k, v)
            error("attemp to update a read-only table", 2)
        end
    }
    setmetatable(proxy, mt)
    return proxy
end


local unpack = table.unpack or function (_table)
    assert(type(_table) == 'table', "except table, got " .. type(_table))
    local function upk(t)
        if #t <= 0 then
            return
        end

        return table.remove(t), upk(t)
    end
    return upk(_table)
end


return {
    unpack   = unpack,
    random   = random,
    readonly = readonly,
    gettime = gettime,
    encode   = json.encode,
    decode   = json.decode,
    random_port = random_port,
}

