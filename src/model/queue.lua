--[[
@desc a simple queue
--]]
local queue = {
	max = 100,
	count = 0,
}


function queue:new(max)
	return {
		first = 0,
		last = -1,
		max = max or self.queue
	}
end


function queue:is_full()
    return self.count >= self.max and true or false
end

function queue:is_empty()
    return self.count <= 0  and true or false
end

function queue:enqueue(value)
	if self:is_full() then return nil, "full" end

    local first = self.first - 1
    self.first = first
    self[first] = value
	self.count = self.count + 1

	return true
end

function queue:dequeue()
    if self:is_empty() then return nil, "empty" end

    local last = self.last
    local value = self[last]
    self[last] = nil        
   	self.last = last - 1
	self.count = self.count - 1

    return value
end

return _queue
