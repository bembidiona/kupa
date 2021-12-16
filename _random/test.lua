value = "hola"
stringofbytes = ""
for i = 1, #value do
    local c = value:sub(i,i)
    c = string.byte(c)
    c = c - 87 --smb
    c = math.abs(c) % 256
    c = string.char(c)
    stringofbytes = stringofbytes .. c
    print(c)
end
print(stringofbytes)
print(#stringofbytes)
-- tilebytes = ""

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
-- 		path_roms = "D:/JERE/PROJECTS/nes-experiments/XE/livecoding/roms/"
-- 		emu.loadrom(path_roms .. "64" .. ".nes")
-- 		savestate.load(my_savestate)
-- 	end

-- 	emu.frameadvance()
-- 	-- socket.sleep(0.05)
-- 	-- print("----------------")
-- end
