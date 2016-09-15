--[[
@auth	mum-chen
@date 	2016 09 15 
--]]
--============ include and declare constant ===============
package.path = "..//?.lua;" ..  package.path
local _chain = require('model.chain')
local _cutils = require('utils.common')
local unpack = _cutils.unpack
local get_time = _cutils.get_time

--============ event ======================================
local _event = {
	thread = nil, 
	values = nil,  
	time = nil,
}
 
function _event:new(thread, values)
	assert(type(thread) == 'thread',
		 "thread:new() #1 except a thread got " .. type(thread))

	local event = {
		time = 0,
		values = values,
		thread = thread,
	}
	setmetatable(event, { __index = self })

	return event
end

function _event:resume()
	return coroutine.resume(self.thread, unpack(self.values))
end

function _event:sleep(time) 
	self.time = get_time() + time
	coroutine.yield()
end


--============ event_center ======================================
local event_chain = _chain:new()
local _event_center = {}
local SLEEP, DEAD, CONTINUE = 'sleep', 'dead', 'continue'

--[[ TODO 
@desc aim to tranfser variable between yield and resume,
	but now not support this temporary
@body
local transfer = function( ... )
	return {select('1', ... )}
end
--]]

local function dispatch(event)
	assert(event, "event is necessay")
	
	-- check event sleep time
	local now = get_time()
	if event.time > now then
		return true, SLEEP -- dispatch next
	end
	local status =  coroutine.status(event.thread) 

	if status == 'dead' then
		event_chain:remove()
		return true, DEAD
	end

	local staus, res = event:resume()

	return true, CONTINUE
end

local function current_event()
	return event_chain:current_value()	
end

--------- public function ---------------------------------
function _event_center.register(func, ... )
	assert(func, 'function is necessary in event.register')
	local event = _event:new(coroutine.create(func),arg)
	event_chain:join(event)
end

function _event_center.sleep(time)
	local event = current_event()
	event:sleep(time)
end

function _event_center.run()
	local count = 0
	for event in event_chain:for_loop() do
		count = count + 1
		local res, info = dispatch(event)
	end
	return true
end

return _event_center
