--[[
@desc a simple queue
--]]
local MAX_ENABLE = true


local _queue = {
	max = 100,
	count = 0,
}

function _queue:new(max)
	local _q =  {
		first = 0,
		last = -1,
		max = max or self.max
	}

	MAX_ENABLE = (max > 0)

	setmetatable(_q, { __index = _queue }) 
	return _q
end

function _queue:isfull()
	if not MAX_ENABLE then 
		return true	
	end

    return self.count >= self.max 
end

function _queue:isempty()
    return self.count <= 0  
end

function _queue:enqueue(value)
	if self:isfull() then return nil, "full" end

    local first = self.first - 1
    self.first = first
    self[first] = value
	self.count = self.count + 1

	return true
end

function _queue:dequeue()
    if self:isempty() then return nil, "empty" end

    local last = self.last
    local value = self[last]
    self[last] = nil        
   	self.last = last - 1
	self.count = self.count - 1

    return value
end

return _queue
