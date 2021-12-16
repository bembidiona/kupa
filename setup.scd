(
NetAddr.disconnectAll;
//init some vars
if(~loop.isKindOf(TaskProxy)){~loop.stop;~loop=nil};
if(~loop.isNil){

	~speed = 4;
	~b = 0;
	~bar = 0;
	~tick = 0;
	~pat = (
		patterns: 0!16!8!8,
		index: 0,
		current: {|self| self.patterns[self.index]},
		s: {|self| self.current.size},
		start: 0,
		end: 4,
		clip: {|self, start=0, steps=nil|
			if(start < 0){start = self.s + start};
			start = start.clip(0, self.s-1);
			self.start = start;

			if(steps.isNil){steps = self.s};

			self.end = (start+steps-1).clip(0, self.s-1);
		},
		fill: {|self, function, seq_size=8, pattern_index=nil|

			if(pattern_index.isNil){pattern_index = self.index};
			pattern_index = pattern_index.clip(0, self.patterns.size-1);

			seq_size = seq_size.floor.asInteger.abs;
			if(seq_size <= 0){seq_size=1};

			self.patterns[pattern_index] = Array.fill(seq_size, {|beat_index| Array.fill(16, {
				|byte_index|
				b = beat_index;
				i = byte_index;
				function.().asInteger.abs & 255;
			})
			});

			// make sure ~b falls inside the new lenght
			~b = ~b % self.current.size;
			self.clip(); //restore start-end labels
		},
		crop: {|self, new_size=4, start=0|
			var new_cajon;

			start = start.ceil.asInteger.abs%self.current.size;
			new_size = new_size.ceil.asInteger.abs;
			if(new_size == 0){new_size=1};

			new_cajon = 0!new_size;
			new_size.do{|i|
				new_cajon[i] = self.current[start+i%self.current.size].copy;
			};
			self.patterns[self.index] = new_cajon;
			~b = ~b%self.current.size;
			self.clip(); //restore start-end labels
		},
		jump: {|self, new_index=0|
			self.index = new_index % self.patterns.size;
			~b = ~b % self.s;
			self.clip(); //restore start-end labels
			"JUMP to ".post; new_index.postln;
		},
		save: {|self|
			var path, file, text;
			text = "";

			text = text ++ "(" ++"\n";
			text = text ++ "~pat.load(" ++ self.index.asString ++', "';
			text = text ++ "\n";

			self.current.do{
				|frame,i|
				// "".post; //a TAB
				frame.do{|reg, j|
					// if((j&3)==0){" ".post};
					text = text ++ reg.asHexString(2);
					text = text ++ " ";
				};
				text = text ++ "\n";
			};

			text = text ++ '")';
			text = text ++ "\n";
			text = text ++ ")";
			text = text ++ "\n";

			path = PathName.new(thisProcess.nowExecutingPath).parentPath ++ "dump.scd";
			file = File(path, "wb");
			file.write(text);
			file.close;
		},
		load: {|self, pattern_index, rawtxt|
			var elements;
			var frame = [];

			pattern_index = pattern_index % self.patterns.size;

			rawtxt = rawtxt.replace("\n", " "); //endline
			rawtxt = rawtxt.replace("  ", " "); //endline
			elements = rawtxt.split($ );

			elements.removeAt(0); //remove first element is glitched
			elements.removeAt(elements.size-1); //remove last element is glitched

			self.patterns[pattern_index] = [];
			elements.do{|ele, i|

				// ~hexstr_to_int
				ele = {|value|
					var result;
					value.do{|nibble,i|

						if(nibble.ascii <= 57,
							{nibble = nibble.ascii - 48}, //0 is 48
							{
								nibble = nibble.toUpper;
								nibble = nibble.ascii - 55; //A is 65
							}
						);

						if(i==0,{result=nibble<<4},{result=result+nibble});
						// nibble.postln;
					};
					result;
				}.(ele);

				frame = frame.add(ele);

				if(i%16==15){
					self.patterns[pattern_index] = self.patterns[pattern_index].add(frame);
					frame = [];
				}
			};
			self.patterns[pattern_index].postln;
			self.jump(pattern_index);
			"LOADED".postln;
		};
	);
	~apu = (
		state: 0!8!16,
		mixLoop: 2r00001111,
		mixGui: 2r00001111
	);

	//fill all cajons with unique arrays
	~pat.patterns.size.do{|i|
		~pat.fill({0}, 8, i);
	};


	//proto update functions
	~updatebar = {

		~update = {
			var data = ~pat.current[~b];
			16.do{|i|
				var val = data[i];
				~apu.state[i] = val.asBinaryDigits;
				~send.ram(0x4000+i, val);
			};
			~apu.mixLoop = 2r00001111;
			1 //always return a time till next beat
		}
	};

	~loop = TaskProxy.new;
	~loop.source = {
		loop{
			var time_until_next_beat, mix;
			// safe start: if 0 or nill can hang everything.
			time_until_next_beat = 0.1;

			// evaluate livecoding functions
			// ("beat: " ++ ~b.asString).postln;
			if(~b==~pat.start){~updatebar.()};

			time_until_next_beat = ~update.();

			// safe chack for the return of update. CYBERDEFOS FAIL :(
			if(time_until_next_beat.isNumber == false){
				"WARNING: ~update is not returning a valid wait time".postln;
				time_until_next_beat = 1;
			};
			if(time_until_next_beat.abs < 0.01){time_until_next_beat = 1};

			// apply ~spee
			time_until_next_beat = time_until_next_beat / ~speed.abs;

			~send.rram(0x00FC, 2r10000000);

			//on/off channels
			mix = ~apu.mixLoop & ~apu.mixGui;
			~send.ram(0x4015, mix);

			// end stream. TODO: it's really neaded? i already forgot lol
			~send.end();

			//update counters
			~tick = ~tick + 1;

			if(~speed > 0,
				{
					~b = ~b+1;
					if(~b > ~pat.end){~b = ~pat.start};
				},
				{
					~b = ~b-1;
					if(~b < ~pat.start){~b = ~pat.end};
				},
			);
			~b = ~b % ~pat.s;



			//wait for next beat
			time_until_next_beat.wait;
		}
	};
};

















//----------------------------------------------
// EMULATOR CONECTION AND HIGH LEVEL MESSAGES
//----------------------------------------------
~emu = (
	conection: nil, //will be a NetAddr.
	// autoender: nil, //will be a Routine.
	connect: {|self|
		{
			"Trying to connect...".postln;
			NetAddr.disconnectAll;
			0.1.wait;
			self.conection = NetAddr("localhost", 12345);
			0.25.wait; // wait a little or don't work
			self.conection.tryConnectTCP(
				onComplete: {
					if(self.conection.isConnected == true,
						{
							"--- CONECTED ---".postln;

							//----------------------------------------------------------------------------
							// FOR EVERY GAME FRAME ADD A END MESSAGGE TAG TO THE CHAIN SO THE LISTENER CAN GRAB IT
							//----------------------------------------------------------------------------
							// since (at least for now) the listener can't grab a chain of messajes
							// faster that one chain per game frame, it's easier that the end char gets added automatically.
							// instead of the user using ~send.end() by hand and other shenanigans
							// self.autoender = {
							// loop {
							// self.conection.sendRaw("\n");
							// (1/60).wait;
							// }
							// }.fork;
							//--------------------------------------------

						},
						{"First (re)start the lua script in the emulator!!!".postln}
					);
				},
				maxAttempts:1
			);
		}.fork;
	},
	reboot: {|self|
		self.conection.disconnect;
		self.conection.connect;
	},
	game: {|self, new_game|
		"LOAD GAME: ".post; new_game.postln;
		self.conection.sendRaw("0>"++new_game++">game|\n");
	},
	save: {|self, slot=1|
		slot = slot.abs.asInteger % 10;
		slot = slot.asString;
		"SAVESTATE: ".post; slot.postln;
		self.conection.sendRaw("0>"++slot++">savestate|\n");
	},
	load: {|self|
		"LOADSTATE".postln;
		self.conection.sendRaw("0>0>loadstate|\n");
	}
);







//----------------------------------------------
// SEND BYTE DATA AND OTHER LOW LEVEL MESSAGES
//----------------------------------------------
~send = (
	raw: {|self, message|
		~emu.conection.sendRaw(message);
	},
	msg: {|self, address, value, type|
		var message;
		message = address.asString++">"++value.asString++">"++type.asString++"|";
		// message.postln;
		self.raw(message);
	},
	end: {|self| self.raw("\n")},
	ram: {|self, address, value| self.msg(address, value, "ram")},
	rram: {|self, address, value| self.msg(address, value, "ram"); self.end.()},
	rom: {|self, address, value| self.msg(address, value, "rom")},
	ppu: {|self, address, value| self.msg(address, value, "ppu")},
	txt: {|self, address, value| self.msg(address, value, "txt");
	},
);









//----------------------------------------------
// HANDY FUNCTIONS
//----------------------------------------------
~hush = {
	~b = 0;
	~bar = 0;
	~loop.stop;
	~send.rram(0x4015, 2r00000000);
	4.do{|i| ~btn_mix[i].valueAction_(0)};
	~btn_play.value_(0);
	"HUSH".postln;
};
~restart = {
	~b = 0;
	~tick = 0;
	~loop.stop;
	~send.rram(0x4015, 2r00001111);
	4.do{|i| ~btn_mix[i].valueAction_(1)};
	~apu.mixLoop = 2r00001111;
	~apu.mixGui = 2r00001111;
	~loop.play;
	~btn_play.value_(1);
	"REVIVE".postln;
};
~revive = {~restart.()};
~defibrillator = {~restart.()};


)