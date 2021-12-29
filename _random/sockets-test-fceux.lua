local socket = require("socket.core")
local tcp = socket.tcp()

tcp:settimeout(2)
local res = tcp:connect("www.google.com", 80)
tcp:send("GET / HTTP/1.1\r\nHost: www.google.com\r\nConnection: close\r\n\r\n")

local text
repeat
   text = tcp:receive()  
   print(text)
until text == nil