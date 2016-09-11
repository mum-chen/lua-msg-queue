local socket = require("socket")
local q1 ,q2 = {}, {}
local client = nil
local host = "127.0.0.1"
local port = 8383
local num = 0


local function init()
	client = socket.connect(host, port)	
end


local function accept(accept_map)
	socket.sleep(1)
end

local function send()
	client = socket.connect(host,port)
	if not client then
		print("not client")
		return 
	end
	print(num)
	client:send(string.format("%d \n", num))	
	num = num + 1
	client:close()
end

local function dispatch(msg)
	
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
