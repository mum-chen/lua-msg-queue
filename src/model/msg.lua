--[[
@auth	mum-chen
@desc	model of message
@date 	2016 09 11 
--]]
--============ include and declare constant ===============
local config = require("config")
local utils = require('src.utils.common')
local gettime = utils.gettime
--============ message ====================================
local _msg = {
	msg = nil,
	seq = nil,
	ack = nil,
	type = nil,
	time = nil, -- second
	fail = nil,
	l_ip = nil,
	r_ip = nil,
	l_port = nil,
	r_port = nil,
}

_msg.TIMEOUT  = config.timeout

_msg.code = utils.readonly {
	-- sub/pub
	sub = true,		-- revive
	pub = true,		-- send
	-- res/req
	res = true,		-- recive
	req = true,		-- send
	-- pop/push
	pop = true,		-- recive
	push = true,	-- send
}

local function check_msg(msg)
	if type(msg) ~= 'table' then
		return  "expect tab, got " .. type(msg)
	end

	local seq, ack = msg.seq, msg.ack

	if not (type(seq) == 'number' or type(ack) == 'number')	then
		return  nil, string.format("seq and ack expect number, got s:%s, a:%s", type(seq), type(ack))
	end

	local m, type = msg.msg, msg.type

	if not _msg.code[type] then
		return nil, string.format(
			"invalid type, got %s, expect{sub|pub|res|req|pop|push}",
			 tostring(type))
	end

	if not m then return nil,"invalid msg" end

	local l_ip, l_port = msg.l_ip, msg.l_port
	
	if not (l_ip and l_port) then 
		return nil, string.format("invalid local address,%s:%s",
			 tostring(l_ip), tostring(l_port))
	end

	local r_ip, r_port = msg.r_ip, msg.r_port

	if not (r_ip and r_port) then 
		return nil, string.format("invalid remote address,%s:%s",
			 tostring(r_ip), tostring(r_port))
	end
	
	-- set default timeout
	timeout = tonumber(timeout) or _msg.TIMEOUT 
	msg.time = _msg.TIMEOUT + gettime()
	return true
end 

-------------- public function -----------------------------
function _msg:new(msg)
	local res, err = check_msg(msg) 
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
