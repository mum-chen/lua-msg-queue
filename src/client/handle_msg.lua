
--=========================================================
local _msg = {
	ip = nil,
	port = nil,
	data = nil, -- msg 
	type = nil, -- handle type
	fail = nil, -- fail callback
	success = nil, -- success callback
	timeout = nil, -- timeout limit 
}

function _msg.format(_table)
	if type(_table) ~= 'table' then

	end	

end 



--=========================================================
local handle = {}

function handle.request()

end

function handle.response()

end

function handle.pop(queue,)

end

function handle.push(queue,)

end

function handle.publish()

end

function handle.subscribe()

end


return handle
