ROM_NAME = "kirby"

#----------- read original --------------------------------
with open(f'{ROM_NAME}.nes', 'rb') as f:
    content = f.read().hex()
#----------- replace all writes to the apu NOPs -----------
replace =  "eaeaea" # with 3 NOP (No OPeration) 
for op in ["8d", "8e", "8c", "99", "9d"]:
    for i in range(0, 20): # looping all 5 channels
        find = op + hex(i)[2:].zfill(2) + "40"
        content = content.replace(find, replace)
    content = content.replace(op + "1540", replace) # changing the apu state register. maybe try with 4017 too and see what happen?
#----------- save hacked version --------------------------
with open(f'{ROM_NAME}!.nes', 'wb') as f:
    f.write(bytes.fromhex(content))
