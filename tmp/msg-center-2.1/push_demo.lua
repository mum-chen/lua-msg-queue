local socket = require("socket")
local ec = require("src.model.event_center")

local q1 ,q2 = {}, {}
local client = nil
local host = "127.0.0.1"
local port = 8383
local num = 0


local function init()
	client = socket.connect(host, port)	
end


local function send()
	while true do
		client = socket.connect(host,port)
		if not client then
			print("not client")
			return 
		end
		print(num)
		client:send(string.format("%d \n", num))	
		num = num + 1
		client:close()
		ec.sleep(1)
	end
end

ec.register(send)

init()
ec.run()
