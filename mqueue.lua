--[[
@create 2016 09 11

--]]

--==================== require ============================
-- load configuration 
local __config = require('config') 

-- 
local _queue = require("src.queue")

local __handle = require("src.handle")

--=================== declare local variable =============
local __in_buf  = _queue:new()
local __out_buf = _queue:new()

local get_cmd = {
	pop = pop,
	res = response,
	sub = subscribe,
}


local put_cmd = {
	push = push,
	req  = request,
	pub  = publish,		
}



-- declare message-queue 
local _m_queue = {}

local function _m_queue.new(cfg_tab)

end

local function _m_queue.setdefault()

end

local function _m_queue.get(config_table)

end

local function _m_queue.put(config_table)

end

local function _m_queue.sub(config_table)

end

local function _m_queue.pub(config_table)

end

return _m_queue 
