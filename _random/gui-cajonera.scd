(
var keys, userview;
var buttons, synths, tasks, releaseChangui;
var blackpattern = [false, true, false, true, false, false, true, false, true, false, true, false];
var step_acumulated = 0;
var transpose_home = 24 + (12 * 3);
var transpose = transpose_home;
var slider_volume, slider_mod;
var width = 450;
var height = 800;
var rootText = "C5";
var letterNotes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"];
var drawFunc, onClose, releaseAll;
var color_bg = Color.fromHexString("212226");
var color_bg_details = Color.fromHexString("838383");
var color_key_white = Color.fromHexString("FFFFFF");
var color_key_black = Color.fromHexString("3f4044");
var color_key_on = Color.fromHexString("15cdcb");
var sustainOn = false;
var toggleOn = false;
var sustain_keynumber = 32;
var toggle_keynumber = 16777217; //32
var btn_help;
var pianitoType;
var windowName;


if(~win != nil) {~win.close;};

windowName = "Cajonera";

~win = Window(windowName, Rect(128, 320, width, height), resizable: false); ~win.alwaysOnTop = true;




8.do {
	| i |
	rootText = StaticText(~win, Rect(5, 25 * i, 50, 25));
	rootText.string = (i + 1).asString;
	// Font.availableFonts.do{|font| font.postcs};
	Font.smoothing = true;
	Font.antiAliasing = true;
	rootText.font = Font("Roboto Medium", 14);
	rootText.stringColor = color_bg_details;
};

drawFunc = {
	Pen.width =1;

	(14 * 8).do {
		| i |
		var w = 24;
		var h = 24;
		var separation = 0;
		var current_channel = 0;
		var step_x = w / 2 + separation;
		var step_y = 30;
		var color_base = color_key_white;

		if(i%14 >= 4){current_channel = 1};
		if(i%14 >= 8){current_channel = 2};
		if(i%14 >= 11){current_channel = 3};

		step_x = step_x + (i % (14) * (w + separation)) + (current_channel*3);
		step_y = step_y + ((i / (14)).floor * (h + separation));

		Pen.fillColor_(color_base);
		Pen.strokeColor_(color_bg_details);
		Pen.fillRect(Rect(step_x, step_y, w, h));
		Pen.strokeRect(Rect(step_x, step_y, w, h));
	};
};
userview = UserView(~win, Rect(10, 10, width - 20, height - 20))
.canFocus_(false)
.drawFunc_(drawFunc);

userview.animate = true;


(14*8).do {
	| i |
	var rootText;
	var current_channel = 0;

	if(i%14 >= 4){current_channel = 1};
	if(i%14 >= 8){current_channel = 2};
	if(i%14 >= 11){current_channel = 3};

	rootText = StaticText(~win, Rect(22 +((i % 14) * 24)+(current_channel*3), 40 + ((i / (14)).floor * 24), 24, 24));
	// Font.availableFonts.do{|font| font.postcs};
	Font.smoothing = true;
	Font.antiAliasing = true;
	rootText.font = Font("Consolas", 14);
	rootText.stringColor = color_bg_details;
	rootText.align = \center;
	rootText.string = i.asHexString[6]++i.asHexString[7];
};



/*slider_volume = Slider(~win, Rect(width - 30, 0, 15, height)); slider_volume.value = 0.7; slider_volume.canFocus = false;

slider_mod = Slider(~win, Rect(width - 15, 0, 15, height)); slider_mod.value = 0.5; slider_mod.canFocus = false;*/

~win.view.keyDownAction_ {
	| view, char, mod, unicode, keycode, key |
		var pos;
	var transposeRoot = {
		| root,
		change |
		root = root + change;
		if (root < (12 * 2)) {
			root = (12 * 2)
		};
		if (root > (12 * 8)) {
			root = (12 * 8)
		};
		root;
	};

	char = char.toLower;
	char = char.asSymbol; //else is class Char


	switch (key,
		16777235, {
			"up".postln
		},
		16777237, {
			"down".postln
		},
		16777236, {
			"right".postln
		},
		16777234, {
			"left".postln
		}, {
			key.postln
	});
};


~win.front;
)