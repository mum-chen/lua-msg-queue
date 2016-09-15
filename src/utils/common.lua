local json = require('json')
local socket = require('socket')
-- TODO
local function get_random_port()

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

local get_time = socket.gettime


return {
	unpack   = unpack,
	readonly = readonly,
	get_time = get_time,
	encode   = json.encode,
	decode   = json.decode,
	get_random_port = get_random_port
}

