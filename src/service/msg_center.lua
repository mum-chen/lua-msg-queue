--[[
@auth	mum-chen
@desc	a msg-center, diliver the msg.
@date	2016 09 16
--]]
--============ include and declare constant ===============
-- load tool
local socket = require("socket")
local config = require("config")
local log    = require("src.utils.log")
local cutils = require("src.utils.common")
-- load model
local _msg = require("src.model.msg")
local _err = require("src.model.err")
local _ec  = require("src.model.event_center")

--====== import function and declare constant ============== 
local gettime = cutils.gettime

--============ declare local variable ======================
-- common 
local service, in_client, out_client = nil, nil, nil
local host, port = "127.0.0.1", config.server_port
local bak_queue ,cur_queue = {}, {}
local PUBLISH_INTERVAL = config.publish_interval

-- ============ necessary module ===========================
local function accept()
	in_client = service:accept()	
	if not in_client then return nil, "null accept"	end
	local str, status, p = in_client:receive('*a')
	if not str then 
		-- TODO add log
		return 
	end
	local msg, err = _msg:tomsg(str)
	-- TODO add log
	table.insert(bak_queue, msg)
end

local function send(msg, str_msg)
	local str_msg = str_msg or msg:tostring()

	out_client = socket.connect(msg.r_ip, msg.r_port)	
	if not out_client then
		log.debug(string.format(
			"can't connect to %s:%s",
			msg.r_ip, msg.r_port
		))
		return nil, _err.REFUSE
	end
	
	out_client:send(str_msg)
	out_client:close()
	return true
end

local function send_back(msg, info)
	out_client = socket.connect(msg.l_ip, msg.l_port)	
	if not out_client then
		log.debug(string.format(
			"can't connect to %s:%s",
			msg.r_ip, msg.r_port
		))
		return 
	end
	local old_msg = msg.msg
	msg.ack, msg.seq = msg.seq, nil
	msg.fail = info and true or nil
	msg.msg = info or _err.SUCCESS 

	local str_msg = msg:tostring() 
	-- recover msg
	msg.seq, msg.ack = msg.ack, nil
	msg.msg = old_msg	
	if not str_msg then
		return 
	end
	
	out_client:send(str_msg)
	out_client:close()
	return true
end

---------- msg.type =  push | req | res --------------------
local function dispatch(msg)
	-- tansfer msg format from string to obj

	if not msg then
		log.err({"msg-center:dispatch", err})
		return nil, "msg format err"
	end

	-- msg timeout
	if gettime() > msg.time then
		return nil, _err.TIMEOUT
	end

	local res, err = send(msg)
	if not res then
		return nil, err
	end
	return true	
end

--============= optional moduel ============================
-- pub/sub module
local pub_queue, _order, publish

if config.order then

pub_queue = require("src.model.queue"):new()

-- two-dimension table
_order = {}

local function combine(ip, port)
	return string.format("%s:%s", ip, port)	
end

function _order.customers(msg)
	local key = combine(msg.l_ip, msg.l_port)
	return _order[key]
end

function _order.sub(msg)
	local key = combine(msg.r_ip,msg.r_port)
	local c_key = combine(msg.l_ip,msg.l_port) 
	-- customer's key
	if not _order[key] then
		_order[key] = {}
	end

	local order = _order[key]	
	
	if order[c_key] then 
		return
	end

	order[c_key] = {
		ip = msg.l_ip,
		port = msg.l_port,
	}
end

function publish()
	msg = pub_queue:dequeue()

	-- null msg then publish finish
	if not msg then return true end
	-- timeout 
	if msg.time < gettime() then
		return false	
	end
	
	local customers = _order.customers(msg)
	if not customers then
		-- nobody subscribe
		return false
	end	 

	for k, customer in pairs(customers) do
		msg.r_ip   = customer.ip
		msg.r_port = customer.port
		local res, err = send(msg)
		if err == _err.REFUSE then
			customers[k] = nil
		end
	end
	-- publish finish
	return true
end

end

---------- msg.type = pub | sub ----------------------------
local function deliver(msg)
	if not config.order then
		return nil, _err.DENY
	end	

	if msg and msg.type == 'sub' then
		_order.sub(msg)	
		return true
	end	


	-- msg.type = 'pub'	
	local res, err = pub_queue:enqueue(msg)
	if not res then 
		return nil, "publish queue is full"
	end

	return true
end

-- ========= msg_deal ======================================
-- pop will not send msg to msg-center this version
local deal_map = {
	res	 = dispatch,
	req  = dispatch,
	push = dispatch,
	sub  = deliver,
	pub  = deliver, 
}

local function msg_deal()
	while bak_queue[1] do
	  bak_queue, cur_queue = cur_queue, bak_queue
	  for i=1,#cur_queue do
		local msg = cur_queue[i]
		local f = deal_map[msg.type] 
		assert(f, string.format(
			"not found function in deal_map,type=%s",
		 	tostring(msg.type)))

		-- deal with msg
		local res, err = f(msg)

		-- case connect refuse try again
		if err == _err.REFUSE then
			table.insert(bak_queue, msg)
		elseif msg.type == 'req' then
			-- do nothing
		else
			send_back(msg, err)
		end
		
		-- remove msg
		cur_queue[i] = nil
	  end
	end
end

-- =========== public function =============================
local function init()
	service = socket.bind(host, port)	
	service:settimeout(1,'t')
	-- assert(service, "null service")
	return service and true or false
end

local function start_server()
	-- register accept server
	_ec.register(function()
		while true do 
			accept()
			_ec.sleep(0.001)
		end	
	end)

	-- register	msg-deal server 
	_ec.register(function()
		while true do
			msg_deal()
			_ec.sleep(0.3)
		end
	end)

	-- optional module pub/sub
	if config.order and publish then 
		
	-- register	subscribe server
	_ec.register(function()
		while true do
			if publish() then
				_ec.sleep(PUBLISH_INTERVAL)	
			end
		end	
	end)

	end

	-- server start
	_ec.run()
end

return {
	init = init, 
	start = start_server,
}
