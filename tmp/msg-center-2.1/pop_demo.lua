local ec = require("src.model.event_center")
local socket = require("socket")

local q1 ,q2 = {}, {}
local service, control = nil, nil
local host = "127.0.0.1"
local port = 8384
local num = 0
local print = require("colorP").p


local function init()
	service = socket.bind(host, port)	assert(service, "null service")
end


local function accept()
	control = service:accept()	assert(control,"null accept")
	local str, status, p = control:receive('*a')
	if not str then
		print({
			str = str,
			status = status,
			p = pm
		})
		return 
	end
	table.insert(q1, str)
	print("in accept")
end

local function dispatch(msg)
	print(string.rep("-",10))	
	print(msg)	
end

local function msg_deal()
	while true do
		print("in msg_deal")
		while q1[1] do
		  q1,q2 = q2,q1
		  for i=1,#q2 do
			dispatch(q2[i])
			q2[i] = nil
		  end
		end
		ec.sleep(1)
	end
end

ec.register(function()
	while true do
		ec.sleep(1)
		accept()
	end
end)
ec.register(msg_deal)

init()
ec.run()
