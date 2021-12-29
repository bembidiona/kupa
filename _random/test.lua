local socket = require("socket.core")
local tcp = socket.tcp()

--Set a 2-second timeout for all request, otherwise the process could hang!
tcp:settimeout(2)
local res = tcp:connect("www.google.com", 80)
tcp:send("GET / HTTP/1.1\r\nHost: www.google.com\r\nConnection: close\r\n\r\n")

local text
repeat
   text = tcp:receive()  
   print(text)
until text == nil




-- value = "hola"
-- stringofbytes = ""
-- for i = 1, #value do
--     local c = value:sub(i,i)
--     c = string.byte(c)
--     c = c - 87 --smb
--     c = math.abs(c) % 256
--     c = string.char(c)
--     stringofbytes = stringofbytes .. c
--     print(c)
-- end
-- print(stringofbytes)
-- print(#stringofbytes)


-- for i in 4 do
-- 	current_char = value[i]
-- 	-- current_char = string.byte(current_char)
-- 	print(current_char)
-- end 
-- var char = value[i];
-- char = ((char.asInteger) - 87);
-- char = char.asAscii.asString;
-- temp = temp++char;
-- };



-- path_roms = "D:/JERE/PROJECTS/nes-experiments/XE/livecoding/roms/"
-- while true do
-- 	joypad1 = joypad.getdown(1);
-- 	if joypad1["A"] then
-- 		my_savestate = savestate.object(1)
-- 		savestate.save(my_savestate)
-- 	end

-- 	if joypad1["B"] then
-- 		emu.loadrom(path_roms .. "64" .. ".nes")
-- 		savestate.load(my_savestate)
-- 	end

-- 	emu.frameadvance()
-- 	-- socket.sleep(0.05)
-- 	-- print("----------------")
-- end
