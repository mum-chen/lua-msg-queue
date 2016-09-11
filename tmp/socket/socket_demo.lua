-- service.lua

local socket = require("socket")
local host, port = "127.0.0.1", "8383"
local server = assert(socket.bind(host, port))
local ack = 'ack\n'
while true do
	print("server:waiting for client connection...")
	control = assert(server:accept())
	while true do
		command, status = control:receive()
		if status == 'closed' then break 	end
		print(command)
		control:send(ack)
	end
end



