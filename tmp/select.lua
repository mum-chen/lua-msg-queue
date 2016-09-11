local socket = require("socket")
local q1 ,q2 = {}, {}
local servers, client, controller = {}
local host = "127.0.0.1"
local port = 8383
local num = 0
local print = require('colorP').p


local function get_srv(port)
	-- local master = socket.tcp()
	-- return master:bind(host, port)
	return socket.connect(host,port)
	-- return socket.bind(host,port)
end

local function init()
	local service = get_srv(8383)
	table.insert(servers, service)
end


local function accept(accept_map)
	cli = get_srv(8383)
	print(cli)
	local canread = socket.select( nil, {cli}, 1)
	print(canread)
	for _, client in ipairs(canread) do
		client:send("a \n")
		print("aaa")
	end

end

local function dispatch(msg)
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
	end
end


local function run()
	init()
	main()
end

run()
