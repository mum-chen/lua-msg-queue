--[[
@auth   mum-chen
@desc   a msg-center, diliver the msg. call for pub-sub
@date   2016 10 03
--]]
--============ include and declare constant ===============
-- load tool
local config = require("config")
local log    = require("src.utils.log")
-- load model
local _err = require("src.model.err")

--====== import function and declare constant ============== 
local gettime = require("src.utils.common").gettime

--============ declare local variable ======================
local pub_queue = require("src.model.queue"):new()
local _send = nil
local _order = {} -- two-dimension table

local function combine(ip, port)
    return string.format("%s:%s", ip, port) 
end

function _order.customers(msg)
    local key = combine(msg.l_ip, msg.l_port)
    return _order[key]
end

function _order.sub(msg)
    local key = combine(msg.r_ip,msg.r_port)
    local c_key = combine(msg.l_ip,msg.l_port) 
    -- customer's key
    if not _order[key] then
        _order[key] = {}
    end

    local order = _order[key]

    if order[c_key] then
        return
    end

    order[c_key] = {
        ip = msg.l_ip,
        port = msg.l_port,
    }
end

-- =========== public function =============================
local function setsend(send)
   _send = send 
end
local function publish()
    msg = pub_queue:dequeue()
    -- null msg then publish finish
    if not msg then return true end
    -- timeout
    if msg.time < gettime() then
        return false
    end

    local customers = _order.customers(msg)

    if not customers then
        -- nobody subscribe
        return false
    end

    for k, customer in pairs(customers) do
        msg.r_ip   = customer.ip
        msg.r_port = customer.port
        local res, err = _send(msg)
        if err == _err.REFUSE then
            customers[k] = nil
        end
    end
    -- publish finish
    return true
end

---------- msg.type = pub | sub ----------------------------
local function delivery(msg)
    if not config.order then
        return nil, _err.DENY
    end

    if not msg then
        log.err({"msg-center:dispatch", err})
        return nil, "msg format err"
    end

    if msg.type == 'sub' then
        _order.sub(msg)
        return true
    elseif msg.type = 'pub' then
        local res, err = pub_queue:enqueue(msg)
        if not res then
            return nil, "publish queue is full"
        end
    else
        local err = string.format("error delivery type:%s",
            tostring(msg.type)) 
        log.err(err) 
        return nil, err 
    end

    return true
end

return {
    setsend = setsend,
    publish = publish,
    delivery = delivery,
}
