local json = require('json')

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


return {
	readonly = readonly,
	encode   = json.encode,
	decode   = json.decode,
	get_random_port = get_random_port
}

