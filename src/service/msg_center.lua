package.path = "..//?.lua;" ..  package.path
local _socket = require("socket")
local _msg = require()


-- debug
local print = require("utils.debug").p

local service, in_client, out_client = nil, nil, nil
local host, port = "127.0.0.1", "61886"




local _queue = {}

local 


local function init()
	service = _socket.bind(host, port)	assert(service, "null service")
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
	out_client = _socket.connect(host, 8384)	
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
