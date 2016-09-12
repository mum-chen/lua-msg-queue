package.path = "..//?.lua;" ..  package.path
local _msg = require('modele.msg')
local _queue = require('modele.queue')
local _socket = require("socket")

-- debug
local print = require("utils.debug").p


-- local variable
local queue = _queue:new()
local host, port = "127.0.0.1", "61886"
local service, in_client, out_client = nil, nil, nil

local function init()
	-- get host port 

	-- check prot and so on
	service = _socket.bind(host, port)	assert(service, "null service")
end

local function accept(accept_map)
	in_client = service:accept()	assert(in_client,"null accept")
	local str, status, p = in_client:receive()
	if not str then 
		print("null ")
		return 
	end
	queue:enqueue(obj)
end

local function send(msg)
	out_client = _socket.connect(msg.p_ip, msg.p_port)	
	if not out_client then
		print("no client")
		return
	end

	out_client:send(msg)
	out_client:close()
end

local function dispatch(msg)
	-- change msg to obj format

	-- get deal function from map
	send(msg)
end

local function msg_deal(dispatch)
	local msg = queue:dequeue()	
	dispatch(msg)
end


local function main()
	while true do
		accept()
		msg_deal(dispatch)
	end
end


init()
main()
