--[[
@auth   mum-chen
@desc   a registry, can be transfer to server or client
@date   2016 10 03
--]]
-- ============ include and declare constant ===============
-- load tool
-- load model
local _avl = require("src.model.avl")
-- server
-- =========== declare local variable ======================
local seq = 0

-- =========== declare local function ======================
local function getseq()
    local _seq
    _seq, seq = seq, seq + 1
    return _seq
end 

-- ====================== user =============================
local _user = {
    ip = nil,
    port = nil,
    name = nil,
    type = nil, -- s/c
}

local function _user:new(msg)
    local user = {
        ip = msg.ip,
        port = msg.port,
        name = msg.name or getseq()
        type = msg.msg 
    } 
end



local _server = {}


-- [ip:port] = type server  
function _server:new()
    local server = {}
    setmetatable(server, {__index = self})
    return server
end

function _server:checkin()

end

-- call for keep alive of client
function _server:confirm()

end

function _server:info(name)

end

return _server
