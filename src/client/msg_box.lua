--[[
@auth   mum-chen
@desc   a msg-center, diliver the msg.
@date   2016 09 16  create
@update 2015 09 19  rebuild the syn|asyn function generator 
        move the wait_timeout, syn_func, asyn_func inner the generator 
--]] --============ include and declare constant =============== -- load tool
local socket = require("socket")
local config = require('config') local log    = require('src.utils.log')
local cutils = require('src.utils.common')
-- load model
local _msg   = require("src.model.msg")
local _err   = require("src.model.err")
local _queue = require("src.model.queue")
local _ec    = require("src.model.event_center") 
--====== import function and declare constant ==============
local run      = _ec.run
local sleep    = _ec.sleep
local register = _ec.register
local gettime  = cutils.gettime
local random_port = cutils.random_port
local s_ip, s_port = "127.0.0.1", config.server_port 
local TIMEOUT, CONNECT_TIMEOUT = config.timeout, config.waiting
assert(TIMEOUT and CONNECT_TIMEOUT, "not config timeout")
--============ local variable ==============================
local seq = 0
local l_ip, l_port = '127.0.0.1', nil
local service, in_client, out_client = nil, nil, nil
local accept_thread = nil

local rec_cmd = {
    sub  = true,
    res  = true,    
    pop  = true,
}

local send_cmd = {
    pub  = true,
    req  = true,
    push = true,
}

-- TODO will combine all the sub-map into one map, ack is a unique-key
local ack_map = {
    pub  = {}, -- input the publish'ack
    sub  = {}, -- input the subscribe'ack
    res  = {}, -- input the response's ack
    req  = {}, -- input the request's ack
    pop  = nil,-- the pop never get ack
    push = {}, -- input the push's ack
}

local rec_map = {
    pub  = {}, -- input the publish msg, used by subscribe
    req  = {}, -- input the request msg, used by response
    push = {}, -- input the push msg, used by pop
}

--============ local function ==============================
local function gen_key(ip, port, ack)
    if ack then
        return tonumber(ack)
    end

    return string.format("%s:%s", tostring(ip), tostring(port))
end

--[[
@desc   get send destination, 
        if open_center == true, all the msg send to msg-center
        now only support in open-center way
--]]
local function getaddress(msg)
    if config.open_center then 
        return s_ip, s_port
    end
    return msg.r_ip, msg.r_port 
end

--[[
@desc   set default value before send
@return success msg
        fail    nil, err 
--]]
local function default_msg(info)
    local msg = {
        -- basic info
        msg = info.msg,
        type = info.type,
        -- local address
        l_ip = l_ip or '127.0.0.1',
        l_port = l_port,
        -- remote address
        r_ip = info.ip or '127.0.0.1',
        r_port = info.port or (info.type == 'pub' and l_port),
    }


    msg.seq, seq = seq, seq + 1
    return _msg:new(msg) 
end

-- call by accept
local function setmsg(msg)
    local t = msg.type
    local map = msg.ack and ack_map[t] or rec_map[t]
    local key = gen_key(msg.l_ip, msg.l_port, msg.ack)  
    
    assert(map and key)

    if not map[key] then
        map[key] = _queue:new()
    end

    local queue = map[key]

    return queue:enqueue(msg)
end

-- get the receive-msg with ip and port
local function getmsg_r(info)
    -- type tansfer 
    local t = info.type
    if t == 'sub' then
        t = 'pub'
    elseif t == 'res' then
        t = 'req'
    elseif t == 'pop' then
        t = 'push'
    else
        assert(nil, "type expect sub|pub|res got " .. tostring(info.type))
    end

    local map = rec_map[t] 
    local key = gen_key(info.ip, info.port)             
    return map[key] 
end

-- get the ack-msg with seq
local function getmsg_a(msg)
    local map = ack_map[msg.type]
    return map[msg.seq]
end


--[[
@desc   the function return a generator function,
        execute that will genrate a syn|asyn function in local thread
@create 2016 09 19 
--]]
local function generator(deal, info)
    -- return a function enclose with watiting-timeout
    local function wait_timeout(deal, info)
        local timeout = info.timeout or TIMEOUT
        return function(f) 
            local begin = gettime()
            
            -- waiting loop
            while true do
                local now = gettime()
                if now - begin > timeout then
                    -- deal with error-timeout 
                    local _ =  info.fail and info.fail({_err.TIMEOUT,"v"})
                    return nil, _err.TIMEOUT
                end
                local res = deal() 
                if res then return res end
                f() -- if asyn will sleep, else will call the accept-event
            end
        end
    end 

    --[[
    @desc   return a function, execute the return value(func) 
            will get the msg in asynchronous way
    --]]
    local function asyn_func(deal, info)
        local f = function()
            sleep(time or 1) 
        end
        local func = wait_timeout(deal, info)
        return function()
            register(func, f) 
            return true, "register success"
        end
    end

    --[[
    @desc   return a function, execute the return value(func) 
            will get the msg in synchronous way
    --]]
    local function syn_func(deal, info)
        local f = function()
             accept_thread:resume()
        end
        local func = wait_timeout(deal, info)
        return func(f)  
    end

    local _generator = info.syn and syn_func or asyn_func
    return _generator(deal, info)
end

-------------- deal with interaction -----------------------
local function accept()
    in_client = service:accept()
    if not in_client 
        then return 
    end
    
    local str, status, p = in_client:receive('*a')
    if not str then 
        -- TODO add log
        return 
    end
    local msg, err = _msg:tomsg(str)    
    if not msg then 
        -- log.(msg, err)
        return false, err
    end
    -- dispatch
    return setmsg(msg)
end

local function post(msg)
    local str_msg = msg:tostring()
    local ip, port = getaddress(msg)
    out_client = socket.connect(ip, port)   
    if not out_client then
        log.debug(string.format(
            "can't connect to %s:%s",
            ip, port
        ))
        return nil, _err.REFUSE
    end
    
    out_client:send(str_msg)
    out_client:close()
    return true
end

-- TODO to add confirm ack
local function _subcribe(info)
    -- set default
    info.ip = info.ip or "127.0.0.1"
    info.msg = "subscribe"

    local msg, err = default_msg(info)
    assert(msg, err)
    local res, err = post(msg)
    if res then return res  end
    local _ = info.fail and info.fail(err)
    return nil,err
end

-- return a function, execute the return value(func) will get msg
local function _receive(info)
    local func = function()
        local res = getmsg_r(info)
        local msg = res and res:dequeue()
        if not msg then
            -- not result try again
            return nil, "empty result"  
        end
        
        local result = info.success and info.success(msg)
        
        -- case response then return the msg back
        if info.type == 'res' then
            assert(result, 'respone needed a msg to return')
            msg.msg = result
            msg.ack, msg.seq = msg.seq, nil
            msg.l_ip, msg.r_ip = msg.r_ip, msg.l_ip
            msg.l_port, msg.r_port = msg.r_port, msg.l_port
            local res, err = post(msg)
            if not res then
                local _ = info.fail and info.fail(err)
            end
        end
        return res 
    end

    return generator(func, info)
end  

local function _send(info, msg)
    -- post msg before register event
    local res, err = post(msg)
    if not res then
        return function() 
            local _ = info.fail and info.fail(err)
            return res, err 
        end
    end
    -- wating ack
    local func = function()
        local msg = getmsg_a(msg)
        if not msg then
            -- not result try again
            return nil, "empty result"  
        end
        
        local msg = msg:dequeue()
        local msg = info.success and info.success(msg)
        
        return res 
    end

    return generator(func, info)
end


--============= public function ============================
local function init(port, waitting) 
    -- if gen_port_c == true then port have the default value
    l_port = port
    assert(l_port, "invalid port")
        
    service = socket.bind(l_ip, l_port) 
    if not service then return false    end
    service:settimeout(watiting or CONNECT_TIMEOUT,"t")
    if not service then
        -- port conflict
        return nil, "conflict" 
    end

    -- register accept server
    accept_thread = register(function()
        while true do 
            accept(); sleep(0.01)
        end 
    end)

    return true
end

--[[
@param  ip      :remote ip
@param  port    :remote ip
@param  type    :push|pub|req
@param  msg     :string format
@param  timeout :default 30s
@param  syn     :true or false, not support this version TODO
@param  loop    :expect a number, not support this version
@param  success :success callback
@param  fail    :fail callback
--]]
local function send(info)
    assert(send_cmd[info.type], 
        "error receive type " .. tostring(info.type))

    -- set default
    info.ip = info.ip or "127.0.0.1"

    local msg, err = default_msg(info)
    assert(msg, err)
        
    -- get event for getting msg
    local event = _send(info, msg)

    -- TODO a know bug the _receive will be return value twice
    -- temporary fix the bug in a brute way
    if type(event) ~= 'function' then
        return event, err
    end

    local res, err = event()
    return res, err
end

--[[
@param  ip      :remote ip
@param  port    :remote ip
@param  type    :pop|sub|res
@param  msg     :string format
@param  timeout :default 30s
@param  syn     :true or false, not support this version
@param  loop    :expect a number, not support this version
@param  success :success callback
@param  fail    :fail callback
@bug    the _receive will return value twice, also have the bug in send
--]]
local function receive(info)
    assert(rec_cmd[info.type], 
        "error receive type " .. tostring(info.type))
    -- set default
    info.syn = (info.syn == nil) or info.syn
    info.ip = info.ip or "127.0.0.1"

    -- subscribe need order first
    if info.type == 'sub' then
        local res, err = _subcribe(info)        
        if not res then return nil, err end
        -- else subscribe success
    end

    -- generator event
    local event, err = _receive(info)

    -- TODO a know bug the _receive will be return value twice
    -- temporary fix the bug in a brute way
    if type(event) ~= 'function' then
        return event, err
    end

    -- exeute event
    local res, err = event()
    return true, "finish"
end


local function server()
    run()
end
local function stop()
    os.exit(0)
end

return {
    init   = init,
    stop   = stop,
    server = server,
    -- interaction
    send    = send,
    receive = receive,
    -- event 
    sleep = sleep,
    register = register,
}
