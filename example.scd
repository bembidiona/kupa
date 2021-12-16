//--------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------
// - STEP 0 (only once) -
// include the /ext/Kupa.sc file in the interpeter options (Go to Menu Bar -> Edit -> Preferences -> Interpreter -> Include)
// and then recompile the library (Ctrl+Shift+L)

// - STEP 1 -
// evaluate these two lines
(
("setup.scd").loadRelative; //load main functions and pseudo-objects
("gui.scd").loadRelative; //load main gui
)

// - STEP 2 -
// now run fceux with a rom and the listener script
"fceux -lua C:/JERE/PROJECTS/nes-experiments/XE/livecoding/listener-fceux.lua C:/JERE/PROJECTS/nes-experiments/XE/livecoding/roms/64.nes".runInTerminal;

// - STEP 3 -
~emu.connect; // connect supercollider to the emulator
//--------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------



//now you can start the main apu loop from the play button on the GUI or like this:
~loop.play // and .stop .resume .pause

// you can fill a pattern using this:
// first argument is a function that will evaluate for every apu register in every beat
// second argument is how many beats will have that pattern. defaults to 8.
~pat.fill({rand(256)}, 16);

// you can use the current beat as b, and the current byte as i
~pat.fill({255-i / 4 + b}, 32);
~pat.fill({2**(b)});

// soft clip
~pat.clip(2, 4); //pattern start in beat 2, and is 4 beats long
~pat.clip(-4, 2); //negative numbers start from the end.
~pat.clip(-1); // end beat gets repeated
~pat.clip(); //reset start and end points

// hard clip
~pat.crop(4); //actually crop the pattern to only 4 beats
~pat.crop(32); // if the number is bigger, repeats the beats until it fills the new length

// select and start playing other pattern slot
~pat.jump(2) // select and play pattern 2
~pat.jump() // select and play pattern 0



~hush.() //silence all channels and stop the loop
~revive.() //try to revive a crashed session
~speed = 4; // set global speed


// change the state of the APU in the current moment
// use end:true, so the emu parse this new data even if ~loop is on pause
// use bake:true, to actually write this data to the current pattern
(0 .. 15).f({255}, end:true);
[1, 5].f({2r11110111}, end:true); // only registers $4001 and $4005
(0 .. 15).f({rand(256)}, end:true);
(0 .. 15).f({|v| v >> 1}, end:true); //you can pass an argument that will represent the current byte value
(0 .. 15).f({|v| v << 1}, end:true);


// GUI: you can paint individual bits in the apu registers with left click
// and clean bits with right click.
// hold and drag also works.
// if the top-right button is on, changes will apply to all beats on the current pattern.
// jump to other beats and patterns by clicking the bars


// these couple of update functions are inside the ~loop routine
// you can livecode them and changes will be applied at the next bar
(
~updatebar = {
	//----------------
	// ~updatebar will be evaluated only at the beginning of pattern
	~speed = 2.0.rrand(2.5); //change speed every bar
	~pat.jump(rand(2)); //change pattern every bar
	//------------------
	~update = {
		// ~update will be evaluated every beat


		// mutating the bytes
		(0 .. 15).f(
			{|v|
				v
				& (~b)
				| [2r01000000, 0].p(~pat.s*2) //
			}
			, false
		);

		//random is always nice
		if(0.4.coin){
			2.do{[rand(16)].f({rand(255)}, false)}; //or bake it to the pattern with true
		};


		~apu.mixLoop = 2r11111111
		& [2r00001111, 2r00000111].p(4) // a little pattern disabling the noise channel
		;


		// the return of this function will be relevant to the wait time to the next beat
		1
		* ([1, 1.8]).p //add a little swing
		* ([1, 1, 1, 0.5, 0.5]).p(~pat.s) //double speed every fourth iteration
		;
	};
};
)



// Or make your own loop. It can be useful for poking other ram addresses that are not sound related
(
~forkme.stop();
~forkme = {
	var tick = 0;
	loop {
		tick = tick + 1;

		~send.ram(0x0754, 0); //force a mario size
		if(0.5.coin){~send.ppu((0x2000+rand(2000)), rand(255));}; //sometimes glitch a tile in the background
		~send.txt((0x2000+rand(2000)),"hola"); //write "hola" in the nametable on smb
		32.do{|i| ~send.ppu((0x3F00+i), tick+i)}; // changes palettes

		// when using custom loops, you need to send a "\n" char or use ~send.end();
		~send.end();
		0.1.wait; // wait a little or will crash
	}
}.fork
);



// rram, instantly poke a value. but only use as single evaluations!
~send.rram(0x0754, 1);

// this global bar increase every bar. can be usefull inside loop and functions
~tick

// change game. roms must exist in the path specified in the listener lua script
~emu.game("smb")
~emu.game("tetris")
// save/load savestates
~emu.save
~emu.load
// combo for changing between muted and unmuted roms.
// also, you can load ram snapshots to other games and see whats happen.
(
~emu.save;
~emu.game("64"); //~emu.game("64!");
~emu.load;
)
//NOTE: in the roms folder there is a python script for creating muted versions of games.



// dump the current pattern to dump.scd
~pat.save
// ~pat.load can load patterns. See patterns.scd for more info.