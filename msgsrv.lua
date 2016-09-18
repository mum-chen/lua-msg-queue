local srv = require('src.service.msg_center')

local function start()
    srv.init()
    srv.start()
end


return{ start = start }

