--[[
@auth	mum-chen
@desc	a simple loop chain
@date 	2016 09 15 
--]]
--============ include and declare constant ===============
local MAX_ENABLE = false

--============ clasp ======================================
local _clasp = {
	value = nil,
	pre = nil,
	next = nil,	
}

function _clasp:new(value, next, pre)
	local clasp = {
		pre = pre,
		next = next,
		value = value,
	}
	setmetatable(clasp, { __index = self })
	return clasp
end

function _clasp:setnext(clasp)
	self.next = clasp
end

function _clasp:setpre(clasp)
	self.pre = clasp
end

--============ chain ======================================

local _chain = {
	max = 0			-- the limit of chain
	count = 0,		-- the total clasp in the chain
	current = nil,	-- index to the current clasp
}

--[[
@parma 	index :the index of clasp, the index is relevant index of 
		current clasp, the negative means before,
		e.g. -1 means the last clasp
--]]
local function relative_clasp(clasp, index)
	local cur_clasp = clasp
	assert(cur_clasp, "clasp must not nil")

	-- empty
	if not cur_clasp then
		return nil
	end

	local next_clasp = nil
	if index == 0 then
		return self.current
	elseif index > 0 then
		next_clasp = function(_clasp)
			return _clasp.next
		end	
	else -- index < 0
		index = -index
		next_clasp = function(_clasp)
			return _clasp.pre
		end
	end
		
	for i=1, index do	
		cur_clasp = next_clasp(cur_clasp)
	end 

	return cur_clasp
end

-------------- public function -----------------------------
function _chain:new(max)
	local chain = { max = tonumber(max) or -1 }
	setmetatable(chain, {__index = self} )	
	return chain
end

function _chain:current_value()
	return self.current.value
end

function _chain:join(value)
	assert(value, "chain.join:the clasp in chain must not be nil")

	if MAX_ENABLE and self.count >= self.max then
		return nil, "error the chain is already full"
	end

	local clasp = nil
	-- the first clasp 
	local cur_clasp = self.current
	if not cur_clasp then
		-- this chain has the only clasp
		clasp = _clasp:new(value)	
		clasp:setnext(clasp)
		clasp:setpre(clasp)
	else 
		clasp = _clasp:new(value, cur_clasp.next, cur_clasp)	
		cur_clasp:setnext(clasp)
		clasp.next.pre = clasp	
	end

	self.current = clasp
	self.count = self.count + 1

	return true
end

--[[
@desc	remove the current clasp and return the value
		the current clasp wiil index to the last one
@parma 	remove the index of clasp, the index is relevant
		index of current clasp, the negative means before,
		e.g -1 means the last clasp
--]]
function _chain:remove(index)
	local index = tonumber(index or 0)
	assert(index, "index expect number, got " .. type(index)) 

	local cur_clasp = self.current
	-- empty
	if not cur_clasp then
		return nil, "chain is empty"
	end

	-- remove the last clasp
	if cur_clasp.next == cur_clasp then
		self.current = nil		
		self.count = 0
		return cur_clasp.value
	end

	cur_clasp = (index == 0) and cur_clasp or relative_clasp(cur_clasp, index)

	self.current = cur_clasp.pre
	cur_clasp.next:setpre(cur_clasp.pre)
	cur_clasp.pre:setnext(cur_clasp.next)
	self.count = self.count - 1	

	return cur_clasp.value
end

--[[
@desc	the pointer index to the next, then return the value
@retuen retuen the value of next clasp and index the pointer to next
--]]
function _chain:next()
	local cur_clasp = self.current

	if not cur_clasp then 
		return nil, "null clasp in chain" 
	end
	
	self.current = cur_clasp.next
	return self.current.value
end

--[[
@usage	e.g. for value in chain:for_loop() do ... end
--]]
function _chain:for_loop()
	return function()
		while self.count > 0 do
			return self:next() 
		end
		return nil	
	end
end

--[[
@desc	return all the value in chain
--]]
function _chain:all_clasp()
	local clasp_arr = {}
	
	local begin = self.current
	if not begin then
		return clasp_arr
	end

	table.insert(clasp_arr, begin.value)
	
	local cur =	relative_clasp(begin,1)
	while cur ~= begin do
		table.insert(clasp_arr, cur.value)
		cur = relative_clasp(cur,1)
	end

	return clasp_arr
end

return _chain
