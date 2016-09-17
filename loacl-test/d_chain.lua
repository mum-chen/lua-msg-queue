local _chain = require('src.model.chain')
print = require('src.utils.debug').p

local function t_next()
	local chain = _chain:new()
	chain:join("aaa") 
	chain:join("bbb")
	chain:join("ccc")
	local count = 0
	while chain.count > 0 and count <= 10 do
		local value = (count % 2 == 0) and chain:remove() or chain:next()
		print({value, chain.count})
		count = count + 1
	end
end

local function t_remove()
	local chain = _chain:new()
	chain:join("aaa") 
	chain:join("bbb")
	chain:join("ccc")

	local p = function(tag)
		local count = 0
		while chain.count > 0 and count <= 3 do
			local value = chain:next()
			print({tag = tag, v = value, c = chain.count})
			count = count + 1
		end
	end

	print(chain:remove())
	-- p("10")
	print(chain:remove())
	-- p("20")
	print(chain:remove())
	p("30")
	print(chain:remove())
	-- p("40")
end


local function t_forloop()
	local chain = _chain:new()
	chain:join("1") 
	chain:join("2")
	chain:join("3")
	chain:join("4")
	chain:join("5")
	max = 5
	local p = function(tag)
		local count = 0
		for value in chain:for_loop() do
			print({
				v = value,
				tag = tag or "d"
			})
			count = count + 1
			if count >= max then break end
		end
	end

	p()
	print(chain:remove())
	p("10")
	print(chain:remove())
	-- p("20")
	print(chain:remove())
	-- p("30")
	print(chain:remove())
	-- p("40")
end

local function t_all()
	local chain = _chain:new()
	chain:join("1") 
	chain:join("2")
	chain:join("3")

	print(chain:all_clasp())

	print(chain:remove())
	print(chain:all_clasp())
	
	print(chain:remove())
	print(chain:all_clasp())
end

local function t_rel_rm()
	local chain = _chain:new()
	chain:join("1") 
	chain:join("2")
	chain:join("3")

	print(chain:all_clasp())

	print(chain:remove(-1))
	print(chain:all_clasp())
	
	print(chain:remove(-1))
	print(chain:all_clasp())

	print(chain:remove())
	print(chain:all_clasp())
end

t_rel_rm()
-- t_all()
