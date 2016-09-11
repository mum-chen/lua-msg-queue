package.path = "..//?.lua;" ..  package.path

local util = require('utils.common')

local function check_msg(tab)
	
	assert(type(tab) == 'table', "expect tab, got " .. type(tab))
	
	local permission = {
		msg = true,
		type = true,
		l_ip = true,
		r_ip = true,
		l_port = true,
		r_port = true,
		timeout = true,
	}
	
	local count = 0
	for k, v in pairs(tab)	do
		if not permission then 
			return false, 'permission deny'
		end
		count = count + 1
	end
	
	if count < 7 then
		return false, "table's miss necessary key"
	end
	return true
end 


local _msg = {
	timeout = 3, -- second
}


function _msg.new(self, table)
	if not table then return nil	end
	local mt = {
		__index = self
	}
	setmetatable(table, mt)	

	local res, err = check_msg(table) 
	if not res then return nil, err end

	return 	table
end

function _msg.tostring(msg)
	return utils.encode(msg)
end

function _msg.tomsg(str)
	local tab = util.decode(msg)
	return self:new(tab)
end

return _msg
