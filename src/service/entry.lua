--[[
@auth   mum-chen
@desc   a msg-center entry, diliver the msg to server.
@date   2016 09 16
--]]
-- =========== include and declare constant ===============
-- load tool
local config = require("config")
local log    = require("src.utils.log")
local cutils = require("src.utils.common")
-- load model
local _err  = require("src.model.err")
local _conn = require("src.module.connect")
local _ec   = require("src.model.event_center")
-- ===== import function and declare constant ============== 
local gettime = cutils.gettime

-- =========== declare local variable ======================
local host, port = "127.0.0.1", config.server_port

-- =========== deal routine ================================


-- accept msg

-- deal register

-- deal alive

-- dispatch msg

return {
    init = init,
    start = start_server,
}

