local cli = require('msgcli')
print = require('src.utils.debug').p


cli.init("9999")
local lock = true
-- [[
cli.send({	
	type = 'pub',
	syn = true,
	msg = {"publish"},
	success = function(msg)
		print(msg.msg) 
		lock = false
	end,
	fail = function(err)
		print {
			tag = "err",
			e = err
		}
		lock = false
		print("fail")
	end,
	timeout = 10,
})
--]]

local event = cli.register(function()
	while lock do
		print("in loop")
		cli.sleep(1)	
	end
	print("loop dead")
	cli.stop()
end)


cli.server()
