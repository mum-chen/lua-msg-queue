-- client
local _client = {}

function _client:new()
    local client = {}
    setmetatable(client, {__index = self})
    return client
end

function _client:register()

end

function _client:unregister()

end

function _client:ack()

end


return _client
