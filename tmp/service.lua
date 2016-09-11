local socket = require("socket")
local q1 ,q2 = {}, {}
local service, control = nil, nil
local host = "127.0.0.1"
local port = 8383
local num = 0
local print = require('colorP').p

local function init()
	service = socket.bind(host, port)	assert(service, "null service")
end


local function accept(accept_map)
	control = service:accept()	assert(control,"null accept")
	local str, status, p = control:receive()
	if not str then
		print("no client connect")
		return
	end
	table.insert(q1, str)
	control:send("get \n")
end

local function send()
end

local function dispatch(msg)
	print(string.rep("-",10))	
	print(msg)	
end

local function msg_deal(dispatch)
	while q1[1] do
	  q1,q2 = q2,q1
	  for i=1,#q2 do
		dispatch(q2[i])
		q2[i] = nil
	  end
	end
end


local function main()
	while true do
		accept()
		msg_deal(dispatch)
		send()
	end
end


local function run()
	init()
	main()
end

run()
