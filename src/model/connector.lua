--[[
@auth   mum-chen
@desc   connector
@date   2016 10 03
--]]
--============ include and declare constant ===============
-- load tool
local socket = require("socket")
local log    = require("src.utils.log")

-- load model
local _msg  = require("src.model.msg")
local _err  = require("src.model.err")

-- ============ socket module ==============================
local _connector = {
    service = nil,
}

function _connector:new(port)
    local connector = {}
    setmetatable(connector, { __index = self })

    local service = socket.bind(host, port)
    service:settimeout(1,'t')

    if not service then 
        return nil, "null server"
    end
   
    connector.service = service
    return connector
end

function _connector:accept(callback)
    local in_client = self.service:accept()
    if not in_client then 
        return nil, "null accept" 
    end

    local str, status, p = in_client:receive('*a')
    if not str then
        -- TODO add log
        return
    end

    local msg, err = _msg:tomsg(str)
    -- TODO add log
    callback()
end

--[[
@param  msg:type src.model.msg
--]]
function _connector:send(msg, str_msg)
    local str_msg = str_msg or msg:tostring()

    out_client = socket.connector(msg.r_ip, msg.r_port)
    if not out_client then
        log.debug(string.format(
            "can't connector to %s:%s",
            msg.r_ip, msg.r_port
        ))
        return nil, _err.REFUSE
    end
    
    out_client:send(str_msg)
    out_client:close()
    return true
end

--[[
@param  msg:type src.model.msg
--]]
function _connector:send_back(msg, info)
    out_client = socket.connector(msg.l_ip, msg.l_port)
    if not out_client then
        log.debug(string.format(
            "can't connector to %s:%s",
            msg.r_ip, msg.r_port
        ))
        return
    end
    local old_msg = msg.msg
    msg.ack, msg.seq = msg.seq, nil
    msg.fail = info and true or nil
    msg.msg = info or _err.SUCCESS

    local str_msg = msg:tostring()
    -- recover msg
    msg.seq, msg.ack = msg.ack, nil
    msg.msg = old_msg
    if not str_msg then
        return
    end
    
    out_client:send(str_msg)
    out_client:close()
    return true
end

return _connector
