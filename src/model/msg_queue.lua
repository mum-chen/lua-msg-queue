--[[
@auth   mum-chen
@desc   a msg-server, got msg and deal with then 
@date   2016 10 03
--]]
-- ============ include and declare constant ===============
-- load tool
local log    = require("src.utils.log")
-- load model
local _err  = require("src.model.err")
-- ============ decalre the msg-queue =====================
local _mq = {
    bak_queue = nil,
    cur_queue = nil,    
}

--[[
@param  conn    :type src.module.connector
@param  deal_map:[msg.type] = deal_func
--]]
function _mq:new(conn, deal_map)
    assert(conn and deal_map, "the conn and deal_map is necessary")

    local mq = {
        conn = conn,
        bak_queue = {},
        cur_queue = {},
        deal_map = deal_map,    
    }
    setmetatable(mq, { __index = self })
    
    return mq
end

--[[
@desc   push msg to msg-queue waiting to deal
--]]
function _mq:push(msg)
    table.insert(bak_queue, msg)
end

--[[
@desc   deal the msg in the queue according to msg.type
--]]
function _mq:msg_deal()
    while bak_queue[1] do
      bak_queue, cur_queue = cur_queue, bak_queue
      for i=1,#cur_queue do
        local msg = cur_queue[i]
        -- get deal func
        local f = self.deal_map[msg.type]
        assert(f, string.format(
            "not found function in deal_map,type=%s",
            tostring(msg.type)))

        -- deal with msg
        local res, err = f(msg)

        -- case connect refuse try again
        if err == _err.REFUSE then
            table.insert(bak_queue, msg)
        elseif msg.type == 'req' then
            -- do nothing, request don't need send ack immediately
        else
            self.conn:send_back(msg, err)
        end
        
        -- remove msg
        cur_queue[i] = nil
      end
    end
end

return _mq
