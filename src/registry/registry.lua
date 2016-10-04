--[[
@auth   mum-chen
@desc   a registry, can be transfer to server or client
@date   2016 10 03
--]]
-- ============ include and declare constant ===============

-- ============ declare local variable =====================
-- conn:type src.module.connector
local conn
-- ============= local function ============================
local send = function(msg)
    conn:send()
end
-- ============= public function ===========================
local _registry = {
   operator = nil,
}
-- common
function _registry:new(conn)
    local register = {}
    setmetatable(register, {__index = self})
    return register
end

-- client
function _registry:client()
    self.operator = require('src.registry.client'):new() 
end

function _registry:register()
    return self.operator:register()
end

function _registry:unregister()

end

function _registry:ack(msg)

end

-- server
function _registry:server()
    self.operator = require('src.registry.server'):new() 
end

function _registry:checkin()

end

function _registry:confirm(msg)

end

return _registry
