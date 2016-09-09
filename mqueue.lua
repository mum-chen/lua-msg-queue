local __default_config = require() --TODO







local function request()

end

local function response()

end

local function pop()

end

local function push()

end

local function publish()

end

local function subscribe()

end



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
