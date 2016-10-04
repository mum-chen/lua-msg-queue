--[[
@auth   mum-chen
@desc   a msg-server, got msg and deal with then 
@date   2016 10 03
--]]
-- ============ include and declare constant ===============
-- load tool
local config = require("config")
local log    = require("src.utils.log")
local cutils = require("src.utils.common")
-- load model
local _err  = require("src.model.err")
local _conn = require("src.module.connector")
local _mq   = require("src.model.msg_queue")
local _ec   = require("src.model.event_center")

-- ====== import function and declare constant ============= 
local gettime = cutils.gettime

-- ============ declare local variable =====================
-- flag
local PS = false -- pub/sub
local PP = false -- push/pop
local RR = false -- req/res
-- common
local mq = nil
local conn = nil
local host = "127.0.0.1"
-- ============ connect module ==============================
-- get msg
local function accept()
    local cb = function(msg)
        mq:push(msg)
    end 
    return conn:accept(cb) 
end

-- send msg
local function send(msg, str_msg)
    return conn:send(msg, str_msg)
end

-- send msg back
local function send_back(msg, info)
    return conn:send_back(msg, info) 
end

-- ================ deal func ==============================
---------- msg.type =  push | req | res --------------------
local dispatch 

if RR or PP then

dispatch = function(msg)
    -- tansfer msg format from string to obj

    if not msg then
        log.err({"msg-center:dispatch", err})
        return nil, "msg format err"
    end

    -- msg timeout
    if gettime() > msg.time then
        return nil, _err.TIMEOUT
    end

    local res, err = send(msg)
    if not res then
        return nil, err
    end
    return true
end

end

------------------ msg.type = pub | sub --------------------
local publish, delivery
local PUBLISH_INTERVAL

if PS then
    PUBLISH_INTERVAL = config.publish_interval
    local _ps = require('pub_sub')
    _ps.setsend(send)
    publish = _ps.publish
    delivery = _ps.delivery
end

-- ================== msg_deal =============================
-- pop will not send msg to msg-center this version
local deal_map = {
    res  = RR and dispatch,
    req  = RR and dispatch,
    push = PP and dispatch,
    sub  = PS and delivery,
    pub  = PS and delivery,
}

local function msg_deal()
    mq:msg_deal() 
end

-- =================== public function =====================
local function init(port, deal_type)
    RR = deal_type.RR
    PS = deal_type.PS
    PP = deal_type.PP

    assert(RR or PS or PP, 
        "msgsrv init error: type expect RR PP PS")

    local err
    conn, err = _conn:new()
    if not conn then 
        return nil, err 
    end
    
    mq = _mq:new(conn, deal_map)

    return true
end

local function start_server()
    -- register accept server
    _ec.register(function()
        while true do
            accept()
            _ec.sleep(0.001)
        end
    end)

    -- register msg-deal server
    _ec.register(function()
        while true do
            msg_deal()
            _ec.sleep(0.3)
        end
    end)

if RR then -- only open in pub/sub
    assert(publish, "not found publish in server")

    -- register subscribe server
    _ec.register(function()
        while true do
            if publish() then
                _ec.sleep(PUBLISH_INTERVAL)
            end
        end
    end)
end

    -- server start
    _ec.run()
end

return {
    init = init,
    start = start_server,
}
