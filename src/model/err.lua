--[[
@auth	mum-chen
@desc	model of error msg
@date 	2016 09 16
--]]
--============ include and declare constant ===============
local config = require('config')
local readonly = require('src.utils.common').readonly

local TIMEOUT, REFUSE, NOT_SERVER
if config.error_code then
	SUCCESS, TIMEOUT, REFUSE, NOT_SERVER, DENY = 0, 1, 2, 3, 4
else
	DENY = 'deny'
	REFUSE = 'refuse'
	TIMEOUT = 'timeout'
	SUCCESS = 'success'
	NOT_SERVER = 'not_server'
end


return readonly{
	DENY = DENY,
	REFUSE = REFUSE,	
	SUCCESS = SUCCESS,
	TIMEOUT = TIMEOUT,
	NOT_SERVER = NOT_SERVER,
}
