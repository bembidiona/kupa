path_roms = "C:/JERE/PROJECTS/kupa/roms/"



emu.log("-------------------------------")
emu.log("-------------------------------")
emu.log("-------------------------------")



-- https://web.archive.org/web/20190406112905/http://w3.impa.br/~diego/software/luasocket/
-- https://gist.github.com/1wErt3r/4048722 smb as6
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

local client = server:accept()
emu.log("--- CONNECTED ---")
client:settimeout(0) -- super tiny timeout. or else the game hangs
e = nil
l = nil


function main()

	l, e = client:receive()

	if e == 'closed' then
		emu.log(e)
		emu.log("END")

	else --

		if l then
		-- emu.log(l)
			
			commands = mysplit(l, "|")
			-- emu.log(commands)
			for i, command in ipairs(commands) do
				emu.log(command)
				-- unpack in mesen is table.unpack
				-- https://stackoverflow.com/questions/25794364/lua-trouble-attempt-to-call-global-unpack-a-nil-value
				address, value, type = table.unpack(mysplit(command, ">"))
				address = tonumber(address)
				
				if type == "game" then				
					-- emu.loadrom(path_roms .. value .. ".nes")
				elseif type == "savestate" then
					-- my_savestate = savestate.object(tonumber(value))
					-- savestate.save(my_savestate)
				elseif type == "loadstate" then
					-- savestate.load(my_savestate)
				elseif address then

					if type == 'txt' then

						local stringofbytes = ""
						for i = 1, #value do
						    local c = value:sub(i,i)
						    c = string.byte(c)
						    c = c - 87 --smb
						    c = math.abs(c) % 256
						    c = string.char(c)
						    stringofbytes = stringofbytes .. c
						end

						-- memory.writebytesppu(address, stringofbytes)
						
					else 
						value = tonumber(value)					
						if value then		
							if type == 'ram' then
								-- emu.log('RAM')
								-- memory.writebyte(address, tonumber(value))
								emu.write(address, tonumber(value), emu.memType.cpu)
							elseif type == 'ppu' then
								-- emu.log('PPU')
								emu.write(address, tonumber(value), emu.memType.ppuDebug)
							elseif type == 'rom' then
								-- emu.log('ROM')
								emu.write(address, tonumber(value), emu.memType.prgRom)
							end
						end
					end
				end
			end
		end


		-- reset shortcut from the joypad 1
		joypad1 = emu.getInput(1);
		if joypad1["select"] and joypad1["start"] then
			if joypad1["A"] then
				emu.rewind(1)
			else
				emu.reset()
			end
		end
	end
end


emu.addEventCallback(main, emu.eventType.endFrame)


