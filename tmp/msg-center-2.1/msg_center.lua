--[[
--]]
local ec = require("src.model.event_center")
local socket = require("socket")
local q1 ,q2 = {}, {}
local service, in_client, out_client = nil, nil, nil
local host = "127.0.0.1"
local port = 8383
local num = 0
local print = require("colorP").p


local function init()
	service = socket.bind(host, port)	assert(service, "null service")
end

local function accept()
	in_client = service:accept()	assert(in_client,"null accept")
	local str, status, p = in_client:receive('*a')
	if not str then 
		print({
			s  = str,
			st = status,
			p  = p
		})
		return 
	end
	print({
		str = str,
		tag = "enqueue",
	})
	table.insert(q1, str)
end

local function send(msg)
	out_client = socket.connect(host, 8384)	
	if not out_client then
		print("no client")
		return
	end
	print({
		tag = "send",
		msg = msg,
	})
	
	print("msg send")
	out_client:send(msg)
	out_client:close()
end

local function dispatch(msg)
	print({tag = 'dispatch',msg = msg})
	send(msg)
end

local function msg_deal()
	print{
		q1 = q1,
		q2 = q2,
	}
	while q1[1] do
	  print("msg_deal")
	  q1,q2 = q2,q1
	  for i=1,#q2 do
		dispatch(q2[i])
		q2[i] = nil
	  end
	end
end

-- =========== main =======

ec.register(function()
	while true do 
		ec.sleep(1)
		accept()
	end	
end)

ec.register(function()
	while true do
		ec.sleep(1)
		msg_deal()
	end
end)

init()
ec.run()
