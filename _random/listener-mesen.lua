-- mesen D:\JERE\PROJECTS\nes-experiments\XE\livecoding\roms\smb.nes D:\JERE\PROJECTS\nes-experiments\XE\livecoding\listener-mesen.lua
-- https://web.archive.org/web/20190406112905/http://w3.impa.br/~diego/software/luasocket/
function mysplit (inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end

local socket = require 'socket.core'
server = socket.tcp()
server:bind("127.0.0.1",12345) -- "localhost" literal fails, but in fceux works 
server:listen(1) -- only one client allowed. can be more. but the listen method transform it into a server.

i, p   = server:getsockname()
assert(i, p)
emu.log("Waiting connection on " .. i .. ":" .. p .. "...")

server:settimeout(10)
local client = server:accept()
emu.log("Connected!")
-- client:settimeout(0) -- super tiny timeout. or else the game hangs
-- e = nil
-- l = nil




-- while e ~= 'closed' do

-- 	l, e = client:receive()

-- 	if l then
-- 		emu.log(l)
		

-- 		address, value = unpack(mysplit(l, "="))
-- 		address = tonumber(address)
-- 		value = tonumber(value)
-- 		emu.log(address)
-- 		emu.log(value)

-- 		if address then
-- 			if value then
-- 				emu.log("CHANGE")
-- 				emu.write(tonumber(address), tonumber(value), memType.ppuDebug)
-- 			end
-- 		end
-- 	end

-- 	emu.frameadvance()
-- 	-- emu.log("----------------")
-- end
-- emu.log("END")
-- emu.log(e)

-- emu.displayMessage("yeah", "lol")