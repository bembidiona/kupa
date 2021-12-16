+ SimpleNumber {
	setbit {|value, position|
		var result;
		var mask_clean = (2r11111110 << position) | (2r11111111 >> (8-position));
		var mask_add = ((value&1) << position);
		value = value&1;
		result = (this & mask_clean) | mask_add;
		^result;
	}


	seq {|function| //deprecated
		var seq_size = this.floor.asInteger.abs;
		if(seq_size == 0){seq_size};

		~pat.current = Array.fill(seq_size, {|frame_index| Array.fill(16, {
			|byte_index|
			function.(frame_index, byte_index);
		})
		});

		~b = 0;
		~bar = 0;
	}

	b { // from a integer as 1001 to 0x09
		var in = this.asString;
		var result = 0;
		var pad = 0;

		pad = 8 - in.size;

		pad.do{
			in = "0" ++ in;
		};

		in.reverseDo{|bit_value, bit_index|
			if(bit_value==$1){
				result = result | (1 << bit_index)
			};
		};
		^result;
	}
}
+ Boolean {
	b {
		var result = 0;
		if(this){result = 1};
		^result;
	}

	* {|second_element|
		var first_element = this.b;
		if(second_element.isKindOf(Boolean)){
			second_element = second_element.b;
		};
		^(first_element * second_element);
	}
	+ {|second_element|
		var first_element = this.b;
		if(second_element.isKindOf(Boolean)){
			second_element = second_element.b;
		};
		^(first_element + second_element);
	}
	- {|second_element|
		var first_element = this.b;
		if(second_element.isKindOf(Boolean)){
			second_element = second_element.b;
		};
		^(first_element - second_element);
	}
	/ {|second_element|
		var first_element = this.b;
		if(second_element.isKindOf(Boolean)){
			second_element = second_element.b;
		};
		^(first_element / second_element);
	}
}
+ Array {
	p {|repeat=1|
		var element, index, tick;
		tick = (~tick/repeat).floor.asInteger;
		index = tick % this.size;
		element = this[index];

		if(element.isKindOf(Array))
		{
			var sub_index;
			sub_index = (tick/this.size).floor.asInteger % element.size;
			element = element[sub_index];
		};

		// element = element.asInteger;

		^element
	}

	f {|function, bake=true, end=false|
		var bytes;
		var val;

		if(this.isKindOf(Integer),
			{bytes = [this]},
			{bytes = this}
		);

		bytes.do{|byteindex|
			val = ~pat.current[~b][byteindex];
			val = function.value(val);
			//send
			~apu.state[byteindex] = val.asBinaryDigits;
			~send.ram(0x4000+byteindex, val);
			if(bake){
				~pat.current[~b][byteindex] = val;
			};
		};
		if(end){~send.end()};
		^val;
	}
}

//------------------------------------------
//------------------------------------------
//------------------------------------------
//------------------------------------------

/*Kupa {
	classvar <emucom = nil;
	classvar <>boi = nil;


	var <>mainloop;
	var <>seq;
	var <>beat = 0;
	var <>bar = 0;
	var <>apu_step;
	var <>changes;
	var <>apu_virtual_state;
	var <>virtual_snapshot;
	var <>time_until_next_beat = 0;
	var <>speed = 8;

	*new {
		^super.new.init()
	}

	init {
		"A NEW NES OBJECT".postln;

		// init vars
		apu_step = {};
		changes = {};
		apu_virtual_state = Array.fill(16, {0.asBinaryDigits});
		virtual_snapshot = [];
		mainloop = TaskProxy.new;
		seq = Array.fill(8, { Array.fill(16, {|i| rand(255)}) });


		// just a prototype of the livecoded function
		// so mainloop.source can be evaluated
		changes = {
			beat = 0;
			// ("changes").postln;
			apu_step = {
				var data, dur, mix, value;

				data = seq[beat];

				16.do{|i|
					this.ram(0x4000+i, data[i]);
				};

				this.ram(0x4015, 0x00001111);
				this.end();

				beat = beat + 1;
				beat = beat % seq.size;

				dur = 1/speed;
				dur; // return for time_until_next_beat
			};
		};

		mainloop.source = {
			loop{
				// ("beat: " ++ beat.asString).postln;
				if(beat==0){changes.()};
				time_until_next_beat = apu_step.();

				//update GUI
				// gui_bits_update.();

				//wait for next beat
				time_until_next_beat.wait;
			}
		};

		// mainloop.play; Can no be run just yet for some reason

	}


	// --------------------------------
	// conection to fceux
	// --------------------------------
	start {
		{
			"Trying to connect...".postln;
			NetAddr.disconnectAll;
			0.1.wait;
			emucom = NetAddr("localhost", 12345);
			0.25.wait; // wait a little or don't work
			emucom.tryConnectTCP(
				onComplete: {
					if(emucom.isConnected == true,
						{"--- CONECTED ---".postln},
						{"First (re)start the lua script in the emulator!!!".postln}
					);
				},
				maxAttempts:1
			);
		}.fork;
	}

	reboot {
		emucom.disconnect;
		emucom.connect;
	}

	// --------------------------------
	// functions to send data to fceux
	// --------------------------------
	sendvalue {|address, value, type|
		var message;
		message = address.asString++">"++value.asString++">"++type.asString++"|";

		if(emucom.isKindOf(NetAddr))
		{
			emucom.sendRaw(message)
		};
	}

	end {
		emucom.sendRaw("\n");
	}

	ram { |address, value|
		this.sendvalue(address, value, "ram");
	}

	now { |address, value|
		this.ram(address, value);
		this.end();
	}

	rom { |address, value|
		this.sendvalue(address, value, "rom");
	}

	ppu { |address, value|
		this.sendvalue(address, value, "ppu");
	}

	txt { |address, value|
		var temp = "";
		value.size.do{ |i|
			var char = value[i];
			char = ((char.asInteger) - 87);
			char = char.asAscii.asString;
			temp = temp++char;
		};
		value = temp;
		this.sendvalue(address, value, "txt");
	}

	// --------------------------------
	// functions to affect loops
	// --------------------------------

	play {
		if(mainloop.isPlaying == true){mainloop.stop};
		mainloop.play;
	}
	hush {
		beat = 0;
		bar = 0;
		mainloop.stop;
		this.now(0x4015, 2r00000000);
	}

	// --------------------------------
	// functions to affect loops
	// --------------------------------
	parseseq {|rawtxt|
		var elements;
		var frame = [];

		rawtxt = rawtxt.replace("	", ""); //tabs
		rawtxt = rawtxt.replace("  ", " "); //doble space
		rawtxt = rawtxt.replace("\n", ""); //endline
		elements = rawtxt.split($ );
		// elements.removeAt(0);
		// elements.removeAt(elements.size-1);
		elements.size.postln;

		seq = [];
		elements.do{|ele, i|

			var result;

			ele.do{|nibble,i|
				if(nibble.ascii <= 57,
					{nibble = nibble.ascii - 48}, //0 is 48
					{
						nibble = nibble.toUpper;
						nibble = nibble.ascii - 55; //A is 65
					}
				);

				if(i==0,{result=nibble<<4},{result=result+nibble});
			};

			frame = frame.add(result);

			if(i%16==15){
				seq = seq.add(frame);
				frame = [];
			};
		};
	}

	postseq {
		"--------------------".postln;
		// '('.postln;
		// '~parse.("'.postln;
		seq.do{
			|frame,i|
			"".post; //a TAB
			frame.do{|reg, j|
				if((j&3)==0){" ".post};
				reg.asHexString(2).post; " ".post;
			};
			"".postln;
		};
		// '");'.postln;
		// ')'.postln;
		"--------------------".postln;
	}

	postframe {
		var current_frame = beat-1; //aparently it already incremented
		("FRAME: " ++ (current_frame).asString).postln;
		"--------------------".postln;
		// ~beat.postln;
		// '('.postln;
		// '~parse.("'.postln;
		"".post; //a TAB
		seq[current_frame].do{|reg, j|
			if((j&3)==0){" ".post};
			reg.asHexString(2).post; " ".post;
		};
		"".postln;
		// '");'.postln;
		// ')'.postln;
		"--------------------".postln;
	}

	//------------------------------------------


}*/




