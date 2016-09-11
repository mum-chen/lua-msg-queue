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


local function accept(accept_map)
	in_client = service:accept()	assert(in_client,"null accept")
	local str, status, p = in_client:receive()
	if not str then 
		print("null ")
		return 
	end
	table.insert(q1, str)
end

local function send(msg)
	out_client = socket.connect(host, 8384)	
	if not out_client then
		print("no client")
		return
	end
	
	out_client:send(msg)
	out_client:close()
end

local function dispatch(msg)
	msg = string.format("%s \n",msg)
	send(msg)
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
	end
end


local function run()
	init()
	main()
end

run()
