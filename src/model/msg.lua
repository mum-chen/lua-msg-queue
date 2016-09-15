--[[
@auth	mum-chen
@desc	model of message
@date 	2016 09 11 
--]]
--============ include and declare constant ===============
package.path = "..//?.lua;" ..  package.path
local utils = require('utils.common')
--============ message ====================================
local _msg = {
	msg = nil,
	type = nil,
	l_ip = nil,
	r_ip = nil,
	l_port = nil,
	r_port = nil,
	timeout = nil, -- second
}

_msg.code = utils.readonly {
	-- sub/pub
	sub = true,		-- get
	pub = true,		-- send
	-- res/rep
	res = true,		-- get
	rep = true,		-- sned
	-- pop/push
	pop = true,		-- get
	push = true,	-- send
}

local function check_msg(_msg)
	if type(_msg) ~= 'table' then
		return  "expect tab, got " .. type(_msg)
	end

	local msg, type = _msg.msg, _msg.type

	if not _msg.code[type] then
		return nil, string.format(
			"invalid type, got %s, expect{sub|pub|res|rep|pop|push}",
			 tostring(type))
	end

	if not msg then return nil,"invalid msg" end

	local l_ip, l_port = _msg.l_ip, _msg.l_port
	
	if not (l_ip and l_port) then 
		return nil, string.format("invalid local address,%s:%s",
			 tostring(l_ip), tostring(l_port))
	end

	local r_ip, r_port = _msg.r_ip, _msg.r_port

	if not (r_ip and r_port) then 
		return nil, string.format("invalid remote address,%s:%s",
			 tostring(r_ip), tostring(r_port))
	end
	
	-- set default timeout
	_msg.timeout = _msg.timeout or 30
	return true
end 

-------------- public function -----------------------------
function _msg:new(msg)
	local res, err = check_msg(table) 
	if not res then return nil, err end

	setmetatable(msg, {__index = self})	

	return msg
end

function _msg:tostring()
	return utils.encode(self)
end

function _msg:tomsg(str)
	local msg = utils.decode(str)
	return _msg:new(msg)
end

return _msg
