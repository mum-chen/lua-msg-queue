print = require('colorP').p
local socket = require('socket')

local function get_running_time(time_f, execute_f) 
	local s = time_f()
	execute_f()
	local e = time_f()
	print({
		s = s,
		e = e,
		d = e -s,	
	})
end

local function loop()
	local k = 0
	for i=1,10 do
		for j=1, 10 do
			k = k + 1	
		end
	end
end

local function loop_2()
	socket.sleep(1.5)
end

print("os.time")
get_running_time(os.time, loop_2)
print("os.clock")
get_running_time(os.clock, loop_2)
print("socket.gettime")
get_running_time(socket.gettime, loop_2)
