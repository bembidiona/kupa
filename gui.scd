(
var size = 24;
var win_x = 25;
var win_y = 0;
var margin = 4;
var hud_size = 24;
var width = size*(4*8)+(space_x*3)+(margin*2);
var height = size*10+(margin);
var pos_x = margin;
var pos_y = margin;
var space_x = 2;
var space_y = 4;
var bit_usefull = [
	1,1,1,1,1,1,1,1,  1,1,1,1,1,1,1,1,  1,1,1,1,1,1,1,1,  1,1,1,1,1,1,1,1,
	1,1,1,1,1,1,1,1,  1,1,1,1,1,1,1,1,  1,1,1,1,1,1,1,1,  1,1,1,1,1,1,1,1,
	1,1,1,1,1,1,1,1,  0,0,0,0,0,0,0,0,  1,1,1,1,1,1,1,1,  1,1,1,1,1,1,1,1,
	0,0,1,1,1,1,1,1,  0,0,0,0,0,0,0,0,  1,0,0,0,1,1,1,1,  1,1,1,1,1,0,0,0

];
var paint_brush = 1;
var color = (
	bg: Color.fromHexString("d8d4d1"),
	// bg: Color.fromHexString("a62e2d"),
	stroke: Color.fromHexString("3d3d3d"),
	bitON: Color.fromHexString("f83f47"),
	bitOFF: Color.fromHexString("858585"),
	unbitON: Color.fromHexString("d0b1b1"),
	unbitOFF: Color.fromHexString("d8d4d1"),
	cream: Color.fromHexString("d1c9a5"),

);


//-------SCOPE
~scope = s.scope(numChannels:1)
.style_(1);
~scope.view.alwaysOnTop_(true)
.bounds_(Rect(0+win_x, 20+win_y, width,190))
// .bounds_(Rect(1505, 810, 415,290))
;
~scope.scopeView.fill_(false)
.xZoom_(8)
.yZoom_(8)
.fill_(false)
.background_(Color.black)
.waveColors_([color.bitON])
;
//----------------------

if(w != nil) {w.close;};

w = Window("KUPA", Rect(0+win_x, 172+win_y, width, height-40), resizable: false, border: true);
// w = Window("KUPA", Rect(718, 840, width, height), resizable: false, border: true);
w.alwaysOnTop = true;
w.background = color.bg;
w.front;

~layout_V = VLayoutView(w,Rect(margin,margin,width-(margin*2),height-(margin*2)));
//~mainloop pause/resume

~layout_buttons = HLayoutView(~layout_V,Rect(0,0,50,size));

~btn_play = Button(~layout_buttons, Rect(margin, margin, width/2, 30))
.canFocus_(false)
.states_([
	[">", color.stroke, Color.white],
	["||", Color.white, color.bitON],
])
.action_({ arg butt;
	if(butt.value == 0,
		{~loop.stop()},
		{~loop.play()}
	);
})
;
if(~loop.isPlaying){~btn_play.value = 1};


//~mix_mow bits
~btn_mix = [];
4.do{|i|
	~btn_mix = ~btn_mix.add(
		Button(~layout_buttons, Rect(width-(18*4)-margin+(18*i), margin, width/14, size))
		.canFocus_(false)
		.states_([
			["", color.stroke, Color.white],
			["", color.stroke, color.bitON],
		])
		.value_(1)
		.action_({ arg butt;
			~apu.mixGui = ~apu.mixGui.setbit(butt.value, 3-i);
			~send.rram.(0x4015, ~apu.mixGui);
			// ("0x4015 = " ++ ~apu.mixGui.asBinaryString).postln;

		});
	)
};
//~dump cajon frame
Button(~layout_buttons, Rect(0, margin, width/14, 14))
.canFocus_(false)
.states_([
	["🤫", Color.black, Color.grey],
])
.action_({ arg butt;
	~hush.();
});
Button(~layout_buttons, Rect(0, margin, width/14, 14))
.canFocus_(false)
.states_([
	["🙏", Color.black, Color.grey],
])
.action_({ arg butt;
	~revive.();
});



//paint all frames
~btn_paintAllFrames = Button(~layout_buttons, Rect(margin, margin, width/14, size))
.canFocus_(false)
.states_([
	["🖌️", color.stroke, Color.white],
	["🖌️", Color.white, color.bitON],
]);



~uv_bar = UserView(~layout_V, Rect(0, 0, width, 22));
~uv_bar.drawFunc = {
	Pen.smoothing_(true);
	Pen.width_(2);

	Pen.fillColor_(color.bitON);
	Pen.strokeColor_(color.stroke);

	~pat.s.do{|i|
		var position_x;
		var position_y;
		position_x = i*(width-(margin*4)/~pat.s)+margin;
		position_y = margin;


		if(i == ~b){
			Pen.fillRect( Rect(position_x, position_y, (width-(margin*4)/~pat.s),14) );
		};

		Pen.strokeRect( Rect(position_x, position_y, (width-(margin*4)/~pat.s),14) );

	};
};
~uv_bar.animate = true;
~uv_bar.mouseDownAction = {|userview, x, y, modifiers, buttonNumber, clickCount|
	var new_beat;
	var data ;
	// buttonNumber.postln;
	new_beat = ((x/~uv_bar.bounds.width) * ~pat.s).floor.asInteger;

	~b = new_beat;
	data = ~pat.current[~b];
	16.do{|i|
		var val = data[i];
		~apu.state[i] = val.asBinaryDigits;
		~send.ram(0x4000+i, val);
	};
	~send.end.();
};


~uv_patterns = UserView(~layout_V, Rect(0, 0, width, 22));
~uv_patterns.drawFunc = {
	Pen.smoothing_(true);
	Pen.width_(2);

	Pen.fillColor_(color.bitON);
	Pen.strokeColor_(color.stroke);

	8.do{|i|
		var position_x;
		var position_y;
		position_x = i*(width-(margin*4)/~pat.patterns.size)+margin;
		position_y = margin;


		if(i == ~pat.index){
			Pen.fillRect( Rect(position_x, position_y, (width-(margin*4)/~pat.patterns.size),14) );
		};

		Pen.strokeRect( Rect(position_x, position_y, (width-(margin*4)/~pat.patterns.size),14) );

	};
};
~uv_patterns.animate = true;
~uv_patterns.mouseDownAction = {|userview, x, y, modifiers, buttonNumber, clickCount|
	var new_index, data;
	new_index = ((x/~uv_patterns.bounds.width) * ~pat.patterns.size).floor.asInteger;

	~pat.jump(new_index);

	if(buttonNumber == 1){~b = 0};

	data = ~pat.current[~b];
	16.do{|i|
		var val = data[i];
		~apu.state[i] = val.asBinaryDigits;
		~send.ram(0x4000+i, val);
	};
	~send.end.();
};


~layout_sliders = HLayoutView(~layout_V,Rect(0,0,width,16));


~slider_speed = Slider(~layout_sliders, Rect(0, 0, width/2, 10))
.action_({
	~speed = (~slider_speed.value*2-1) * 10;
	if(~speed == 0){~speed = 1}; // actually make this
})
.value_(0.5)
.background_(color.bitOFF)
.thumbSize_(30)
.knobColor_(color.bitON)
;

~slider_swing = Slider(~layout_sliders, Rect(0, 0, width/2, 10))
.action_({
	~speed = (~slider_swing.value*2-1) * 10;
	if(~speed == 0){~speed = 1}; // actually make this
})
.value_(0.5)
.background_(color.bitOFF)
.thumbSize_(30)
.knobColor_(color.bitON)
;



~uv_bits_h = size*4 + (space_y*4);
~uv_bits = UserView(~layout_V, Rect(0, 0, width, ~uv_bits_h));
// ~userview.background = color.bitOFF;
~uv_bits.drawFunc = {
	w.name = "KUPA " ++ "[CAJON:"++ ~pat.index.asString ++ "]" ++ "[BEAT:"++ (~b).asString ++ "-" ++ ~pat.s.asString ++ "]";
	Pen.smoothing_(true);
	Pen.width_(2);

	~apu.state.do{|byte, byteindex|
		var position_x;
		var position_y;

		Pen.fillColor_(color.stroke);
		Pen.strokeColor_(color.stroke);
		position_x = (byteindex%4)*((size*8+space_x));
		position_y = ((byteindex/4).floor)*(size+space_y) + margin;
		Pen.fillRect( Rect(position_x+(size/2), position_y,size*7,size));
		Pen.strokeRect( Rect(position_x+(size/2), position_y,size*7,size));

		byte.do{|bit, bitindex|
			position_x = (byteindex%4)*((size*8+space_x)) +(bitindex*size);
			position_y = ((byteindex/4).floor)*(size+space_y) + margin;

			// var bit_state = ~apu_state[mem][bit];

			if(bit_usefull[byteindex*8+bitindex] == 1,
				{
					if(bit == 1,
						{Pen.fillColor_(color.bitON);},
						{Pen.fillColor_(color.bitOFF);}
					);
					Pen.strokeColor_(color.stroke);
				},
				{
					if(bit == 1,
						{Pen.fillColor_(color.unbitON);},
						{Pen.fillColor_(color.unbitOFF);}
					);
					Pen.strokeColor_(color.bitOFF);
				}
			);

			Pen.fillOval( Rect(position_x, position_y,size,size));
			Pen.strokeOval( Rect(position_x, position_y,size,size));
		};


	};

};
~uv_bits.animate = true;



~uv_bits.mouseMoveAction = {|userview, x, y, modifiers, buttonNumber, clickCount|

	~change_bit.(x,y,paint_brush);
};

~uv_bits.mouseDownAction = {|userview, x, y, modifiers, buttonNumber, clickCount|
	// buttonNumber.postln;
	switch(buttonNumber,
		0,{paint_brush = 1},
		1,{paint_brush = 0},
	);
	if(buttonNumber <= 1){~change_bit.(x, y, paint_brush);}
};

~uv_bits.keyDownAction = {|view, char, mod, unicode, keycode, key|

	char = char.toLower;
	char = char.asSymbol; //else is class Char
	char.postln;

	if((unicode >= 49)&&(unicode <= 56)){
		var bit = 56 - unicode;
		bit.postln;
	};

	/*switch (key,
		1, {},
		2, {},
		{}
	)*/
};

~change_bit = {|x, y, new_bit_value|
	var frames_to_paint, frame_index, byte_index, bit_index, byte_value, bit_value, end_value;


	y = y;
	x = x.clip(0, width);
    y = y.clip(0, ~uv_bits_h);


	byte_index = (x/width*4).asInteger + ((y/(size+space_y)).asInteger*4);
	bit_index = ((x/width*(4*8)).floor % 8);

	byte_index = byte_index.clip(0, 15);
	bit_index = bit_index.clip(0, 7);


	if(~btn_paintAllFrames.value == 1,
		{frames_to_paint = (0 .. ~pat.s-1)},
		{frames_to_paint = [~b]}
	);

	frames_to_paint.do{|frame_index|

		// ~pat.s.do{|i|

		byte_value = ~pat.current[frame_index][byte_index].asBinaryDigits;

		bit_value = byte_value[bit_index];
		end_value = 0;

		if(bit_value != new_bit_value && (new_bit_value != nil))
		{


			byte_value.do{|bitcito, i|
				if(i == bit_index,
					{
						if(new_bit_value==1){
							end_value = end_value | (1 << (7-i));
						};
					},
					{
						if(bitcito==1){
							end_value = end_value | (1 << (7-i));
						};
					}
				);
			};


			// "----------------".postln;
			// "frames_to_paint ".post; frames_to_paint.postln;
			// "frameindex ".post; frame_index.postln;
			// "bit_index ".post; bit_index.postln;
			// "byte_value ".post; byte_value.postln;
			// "bit_value ".post; bit_value.postln;
			// "new_bit_value ".post; new_bit_value.postln;
			// "end_value  ".post; end_value.asBinaryDigits.postln;*/

			~pat.current[frame_index][byte_index] = end_value;


			if(frame_index == ~b){ //if the changed byte is on the current frame
				//update array that its used to display bits in gui
				~apu.state[byte_index][bit_index] = new_bit_value;
				//actually send value to emu
				~send.rram(0x4000+byte_index, end_value);
			};
		}
	};





};







)


