--[[
@date   2016 09 15
@desc   all the config in there
--]]
return {
-- ============ common config ============================
-- waitting time, if the msg is waitting to long, the msg-center will throw
timeout = 30,

-- connect timeout
waiting = 0.3,
-- ============= log config ==============================
-- if set true the log msg will be print
debug = true,

-- if set true case log.error will stop the program
fatal = true,

-- whether generate log-file
log = off,

-- set the defualt log_path
log_path = "/tmp/lua-mq/",

-- if set true, the error msg will be set as number ranther then string
error_code = false,

-- ============= msg-center config ========================
-- if open all the msg will be send to msg-center
-- else the msg-center will directly send to the destination
-- the sub/pub only served in msg-center now
open_center = true,

-- whether open the sub/pub module in the msg-center
order = true,

-- the publish inveral
publish_interval = 0.5,

-- Whether the msg-center auto build. Not support now
auto_build = false,

-- default port of msg-center
server_port = 11185,

-- if set false, when the port conflict the mgs-center will close, Not support now.
gen_port_s = false,

-- set the max number of queue, when max not a positive number, the queue is unlimit
max_output_queue = 0,
max_input_queue = 0,

-- ============= msg-box config ==========================
gen_port_c = false,

}
