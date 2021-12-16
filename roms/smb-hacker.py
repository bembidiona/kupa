ROM_NAME = "smb2p"

#----------- read original --------------------------------
with open(f'{ROM_NAME}.nes', 'rb') as f:
    content = f.read().hex()
#----------- replace all writes to the apu NOPs -----------
replace =  "eaeaea" #3 NOP (No OPeration)
for op in ["8d", "8e", "8c", "99", "9d"]:
    for i in range(0, 20): # looping all 5 channels

        if(i == 0 and op == "8d"): 
            # skip this convination. and change it by hand after the loop with a bigger payttern match
            # the game glitch way to hard otherwise. probably something gets changed that parse as other op
            continue

        find = op + hex(i)[2:].zfill(2) + "40"
        content = content.replace(find, replace)

    content = content.replace(op + "1540", replace) # changing the apu state register. maybe try with 4017 too and see what happen?
# this was the pesky one.
#  01:F76B: A9 90     LDA #$90
# >01:F76D: 8D 00 40  STA SQ1_VOL = #$24
#  01:F770: ea ea ea  
content = content.replace(f"a9908d0040{replace}", f"a990{replace}{replace}")

#----------- save hacked version --------------------------
with open(f'{ROM_NAME}-hack.nes', 'wb') as f:
    f.write(bytes.fromhex(content))
