path_roms = "C:/JERE/PROJECTS/nes-experiments/XE/livecoding/roms/"



print("-------------------------------")
print("-------------------------------")
print("-------------------------------")



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

-- https://stackoverflow.com/questions/41954718/how-to-get-ppu-memory-from-fceux-in-lua
function memory.writebyteppu(a,v)
    memory.writebyte(0x2001,0x00) -- Turn off rendering
    memory.readbyte(0x2002) -- PPUSTATUS (reset address latch)
    memory.writebyte(0x2006,math.floor(a/0x100)) -- PPUADDR high byte
    memory.writebyte(0x2006,a % 0x100) -- PPUADDR low byte
    memory.writebyte(0x2007,v) -- PPUDATA
    memory.writebyte(0x2001,0x1e) -- Turn on rendering
end

function memory.writebytesppu(a,str)
    memory.writebyte(0x2001,0x00) -- Turn off rendering

    local i
    for i = 0, #str-1 do
        memory.readbyte(0x2002) -- PPUSTATUS (reset address latch)
        memory.writebyte(0x2006,math.floor((a+i)/0x100)) -- PPUADDR high byte
        memory.writebyte(0x2006,(a+i) % 0x100) -- PPUADDR low byte
        memory.writebyte(0x2007,string.byte(str,i+1)) -- PPUDATA
    end

    memory.writebyte(0x2001,0x1e) -- Turn on rendering
end




local socket = require 'socket.core'
server = socket.tcp()
server:bind('localhost',12345)
server:listen(1) -- only one client allowed. can be more. but the listen method transform it into a server.

i, p   = server:getsockname()
assert(i, p)
print("Waiting connection on " .. i .. ":" .. p .. "...")

local client = server:accept()
print("--- CONNECTED ---")
client:settimeout(0) -- super tiny timeout. or else the game hangs
e = nil
l = nil

while e ~= 'closed' do

	l, e = client:receive()


	if l then
		-- print(l)
		
		commands = mysplit(l, "|")
		-- print(commands)
		for i, command in ipairs(commands) do
			-- print(command)
			address, value, type = unpack(mysplit(command, ">"))
			address = tonumber(address)
			
			if type == "game" then				
				emu.loadrom(path_roms .. value .. ".nes")
			elseif type == "savestate" then
				my_savestate = savestate.object(tonumber(value))
				savestate.save(my_savestate)
			elseif type == "loadstate" then
				savestate.load(my_savestate)
			elseif address then

				-- print("---------")
				-- print(address)
				-- print(value)
				-- print(type)

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

					memory.writebytesppu(address, stringofbytes)
				else 
					value = tonumber(value)					
					if value then		
						if type == 'ram' then
							-- print('RAM')
							memory.writebyte(address, tonumber(value))
						elseif type == 'ppu' then
							-- print('PPU')
							memory.writebyteppu(address, tonumber(value))
						elseif type == 'rom' then
							-- print('ROM')
							rom.writebyte(address, tonumber(value))
						end
					end
				end
			end
		end
	end


	-- reset shortcut from the joypad 1
	joypad1 = joypad.getdown(1);
	if joypad1["select"] and joypad1["start"] then
		if joypad1["A"] then
			emu.poweron()
		else
			emu.softreset()
		end
	end


	emu.frameadvance()
end
print("END")
print(e)
