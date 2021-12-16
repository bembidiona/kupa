//-------- STEP 1 ----------
//run emu + lua script
"fceux -lua C:/JERE/PROJECTS/nes-experiments/XE/livecoding/listener-fceux.lua C:/JERE/PROJECTS/nes-experiments/XE/livecoding/roms/smb.nes".runInTerminal;
//-------- STEP 2 ----------
// evaluate this:
(
("setup.scd").loadRelative;
("apu-gui.scd").loadRelative;
)
//-------- STEP 3 ----------
//connect supercollider to the emulator
~emu.connect;
//-------- STEP 4 ----------



// save/load states
~emu.save
~emu.load
// change game
~emu.game("64!")
~emu.game("smb")
~emu.game("smb2!")
~emu.game("tetris!")
// combo for changing between muted and unmuted roms.
// also, you can load ram snapshots to other games and see whats happen.
(
~emu.save;
~emu.game("64"); //~emu.game("64!");
~emu.load;
)


~pat.fill({0}, 16);
~pat.fill({b + f}, 64);
~pat.fill({255-b / 4 + f}, 32);
~pat.fill({rand(2)}, 64);
~pat.fill({rand(256)}, 16);
~pat.fill({0}, 8);
~pat.fill({2**(f)});
~pat.fill({2**(7-f)});
~pat.fill({1000 + (f/4) + 0}, 8); //n@@@ise


~pat.clip();
~pat.crop(8);

~pat.jump()


//silence all channels and stop the loop
~hush.()
//try to revive a crashed session
~revive.()



~speed = 4;

// change the state of the APU
// use end:true, so the emu parse this new data even if the loop is on pause
// use bake:true, to actually write this data to the current cajon
(0 .. 15).f({255}, end:true);
[1, 5].f({2r11110111}, end:true);
(0 .. 15).f({0}, end:true);
(0 .. 15).f({rand(256)}, end:true);
(0 .. 15).f({|v| v >> 1}, end:true);
(0 .. 15).f({|v| v << 1}, end:true);


(
~updatebar = {
	//----------------
	// this will evaluate only at the beginning of pattern
	~speed = 2.rrand(10); //change speed
	~pat.jump(rand(8));
	//------------------
	~update = {
		// this will evaluate every beat



		(0 .. 15).f(
			{|v|
				v
				// + [-8, 0].p(~pat.s)
				// & (~b)
				| [2r01000000, 0].p(~pat.s*2)
				// | [2r10000000, 0].p(~pat.s*4)
				// & (~frameCounter)
				// & ~b
				// | [2r0000001, 0].p(~pat.s*0.5)
				// | [2r0010000, 0].p(8)
				// | (2r0001000)
				// | (2r0000001)
				// | 2r11111100 //extra crusty
				// | 251
				// | 2r11100000
			}
			, false
		);

		//virtual random
		if(0.4.coin){
			1.do{[rand(16)].f({rand(255)}, false)};
		};

		//or bake some random
		if(0.2.coin){
			1.do{[rand(16)].f({rand(255)}, true)};
		};


		~apu.mixLoop = 2r11111111
		& [2r00001111, 2r00000111].p(4)
		;

		// ---- WAIT TO NEXT BEAT ---
		1
		// * ([1, 1.8]).p
		// * ([1, 1, 1, 0.5, 0.5]).p(~pat.s)
		;
	};
};
)






(
~forko.stop();
~forko = {
	var lel = 0;
	loop {
		lel = lel + 1;



		// ~send.ram(0x0754,lel&1); //mario size
		// 0x0756  0 small 1 big 2 fiery

		// ~send.ram(0x0704, 1); //UNDERWATERBOI
		// 0x00FB 	Area Music Register
		// 0x00FC 	Event Music Register
		// 0x00FD 	Sound Effect Register 1
		// 0x00FE 	Sound Effect Register 2
		// 0x00FF 	Sound Effect Register 3

		// ~send.ram(0x00FF, 1 << (lel%3));
		// ~send.ram(0x00FB, lel+3%8); //compas de la cancion ?
		// ~send.ram(0x074E, 0); // bubs

		if(0.5.coin){
			1.do {~send.ppu((0x2000+rand(2000)), rand(255))};
		};
		// 1.do{~send.txt((0x2000+rand(2000)),"hola")};
		// palettes
		// 32.do{|i| ~send.ppu((0x3F00+i), ~frameCounter+i)};

		if(0.5.coin){
			32.do{|i| ~send.ppu((0x3F00+i), rand(10)+10)};
			// 1.do {~send.ppu((0x2000+rand(2000)), rand(255))};
		};




		5.do{[rand(16)].f({rand(255)}, false)};



		// ~emu.load;

		~send.end();

		// (1/(rand(5)+1)).wait;
		(1/(~speed.abs)+0.0001).wait;
	}
}.fork
);

~emu.save

~emu.load


(
~console.stop();
~console = {
	var tick = 0;
	var text;
	text = "Thank You Mario, But Our Princess is in Another Castle";
	text = text.split($ );
	loop {
		(sin(tick*0.25)*0.5+0.5*16).do{" ".post};
		text[tick%text.size].postln;
		tick = tick + 1;
		0.1.wait;
	}
}.fork
);