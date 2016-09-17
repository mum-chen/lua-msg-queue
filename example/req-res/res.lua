local cli = require('msgcli')
print = require('src.utils.debug').p

local lock = true

cli.init("9996")

-- [[
cli.receive({	
	port = '9997',
	type = 'res',
	syn = true,
	success = function(msg)
		print({"success",msg = msg.msg}) 
		lock = false
		-- the return value is necessary
		return "bbb"
	end,
	fail = function(err)
		print {
			tag = "err",
			e = err
		}
		lock = false
	end,
	timeout = 30,
})
--]]

local event = cli.register(function()
	while lock do
		print("in loop")
		cli.sleep(0.1)	
	end
	cli.sleep(1)
	print("loop dead")
	cli.stop()
end)


cli.server()
