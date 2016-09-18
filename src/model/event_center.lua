--[[
@auth   mum-chen
@date   2016 09 15 
--]] --============ include and declare constant =============== -- load modle
local _chain = require('src.model.chain')
-- load utils
local log    = require('src.utils.log')
local cutils = require('src.utils.common')
local unpack = cutils.unpack
local gettime = cutils.gettime


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
    self.time = gettime() + time
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
    local now = gettime()
    if event.time > now then
        return true, SLEEP -- dispatch next
    end
    local status =  coroutine.status(event.thread)

    if status == 'dead' then
        event_chain:remove()
        return true, DEAD
    end
    
    local result = {event:resume()}
    local _ = not result[1] and log.err(result)

    return true, CONTINUE
end

local function current_event()
    return event_chain:current_value()
end

--------- public function ---------------------------------
function _event_center.register(func, ... )
    assert(func, 'function is necessary in event.register')
    local thread = coroutine.create(func)
    local event = _event:new(thread, arg)
    event_chain:join(event)
    return event 
end

function _event_center.sleep(time)
    local event = current_event()
    event:sleep(time)
end

function _event_center.run()
    for event in event_chain:for_loop() do
        local res, info = dispatch(event)
    end
    return true
end


return _event_center
