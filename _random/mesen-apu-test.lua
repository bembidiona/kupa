t = 0
function main()
  t = t + 1;
  t = t % 255

  emu.write(0x4000 + (t % 16), t, emu.memType.cpu)
  emu.write(0x4000, 255, emu.memType.cpu)
end

emu.addEventCallback(main, emu.eventType.endFrame)
