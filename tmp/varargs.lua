local print = require('colorP').p


print(table.unpack)

table.unpack = table.unpack or function (_table)
	assert(type(_table) == 'table', "except table, got " .. type(_table))
	local function upk(t)
		if #t <= 0 then
			return 
		end

		return table.remove(t), upk(t)
	end	
	return upk(_table)
end


local function pack(tab)
	return table.unpack(tab)
end


local t1 = {"1","2","3"}
print({pack(t1)})


