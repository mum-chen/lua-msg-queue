package.path = "..//?.lua;" ..  package.path
local ec = require("model.event_center")
print = require('utils.debug').p


ec.register(function ()
	for i = 1, 9 do
		-- [[
		print({
			tag	= "loop_1",
			i = i
		})
		--]]
		ec.sleep(0.5)
	end
	return "loop1"
end) 

ec.register(function ()
	for i = 1, 20 do
		-- [[
		print({
			tag	= "loop_2",
			i = i
		})
		--]]
		ec.sleep(1)
	end
	return "loop2"
end)

ec.register(function ()
	for i = 1, 11 do
		-- [[
		print({
			tag	= "loop_3",
			i = i
		})
		--]]
		ec.sleep(2)
	end
	return "loop3"
end)

ec.run()
