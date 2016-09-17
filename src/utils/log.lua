--[[
@auth	mum-chen
@date 	2016 09 15 
--]]
--============ include and declare constant ===============
local _config = require('config')

local DEBUG = _config.debug
local FATAL = _config.fatal

if DEBUG then
	print = require("src.utils.debug").p
end

local _log = {}

function _log.debug(obj)
	local _ = DEBUG and print(obj)

end

function _log.err(obj)
	local _ = DEBUG and print(obj)
	local _ = FATAL and os.exit(1)
end

return _log
