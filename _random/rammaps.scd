//-----------------------------
//     smb / super mario bros
//-----------------------------
0x00E7 	Level layout address
0x00E9 	Enemy layout address
0x00FB 	Area Music Register
0x00FC 	Event Music Register
0x00FD 	Sound Effect Register 1
0x00FE 	Sound Effect Register 2
0x00FF 	Sound Effect Register 3
0x0704 	Swimming Flag
0x074E  0x00 make appears bubbles
0x0743 	When true, cloud groundtiles
0x0754  0 big 1 small
0x0756  0 small 1 big 2 fiery
0x0770  0 bot 1 player 2 end world 3 crash
0x0772  0 reset
0x0773  palette theme 1 ... 4
0x0778  weird glitch
0x0779  tint?

0x07C7  compas de la cancion
0x07C7  compas de la cancion
//set silence event (but silence channels on 0x4015)
~now.(0x00FC, 2r10000000);


// weird
memory.writebyte(0x0009, 0x00);
memory.writebyte(0x00F7, 0x12);
memory.writebyte(0x00F8, 0x12);
memory.writebyte(0x00F9, 0x11);
//-----------------------------


//-----------------------------
//     TENGEN
//-----------------------------
0x002B 	fast fall
0x002D 	floor line related


//-----------------------------