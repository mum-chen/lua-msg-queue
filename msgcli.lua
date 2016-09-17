--[[
@method init
@desc 	initialize the server
@parma 	port	:the port this program will listen
--]]

--==========================================================
--[[
@method server 
@desc 	start the server
--]]

--==========================================================
--[[
@method receive 
@param	ip	 	:remote ip
@param  port 	:remote ip
@param  type 	:pop|sub|res
@param 	msg  	:string format
@param  timeout	:default 30s
@param  syn	 	:true or false, 
@param 	loop 	:expect a number, not support this version
@param 	success :success callback
@param 	fail 	:fail callback
--]]


--==========================================================
--[[
@method send	
@param	ip	 	:remote ip
@param  port 	:remote ip
@param  type 	:push|pub|req
@param 	msg  	:string format
@param  timeout	:default 30s
@param  syn	 	:true or false, 
@param 	loop 	:expect a number, not support this version
			it means all the interaction is one-time routine
@param 	success :success callback
@param 	fail 	:fail callback
--]]

--==========================================================
--[[
@method register
@desc	register event to the event-center, and waiting to be call
@param	func	:the func will execute in back 

--]]

--==========================================================
--[[
@method sleep
@desc	sleep the current event
@pram 	time	:time in second
--]]
return require('src.client.msg_box')
