// schedule an event at next whole beat
t.schedAbs(t.beats.ceil, { arg beat, sec; [beat, sec].postln; 1 });

(
(
SynthDef(\bip, { |out, freq=400|
    Out.ar(out,
        SinOsc.ar(freq, 0, 0.5) * Line.kr(1, 0, 0.1, doneAction: Done.freeSelf)
    )
}).add
);
~forko = TaskProxy.new;
// ~forko.quant(8);
~forko.play;
~forko.stop;
~forko.clock = t;
~beat = 0;
)

t = TempoClock.default;
t.tempo = 4;

t.schedAbs(t.nextBar, "lol".postln);


t.schedAbs(t.nextBar, { arg beat, sec; [beat, sec].postln; 1 });



(
~changes = {

~beat = 0;

~fun = {

	if(~beat==0,
			{" ".postln;Synth(\bip, [\freq, 500 + rand(80)])},
		{Synth(\bip)}
	);
	(~beat+1).post;
	(" ").post;
	~beat = ~beat +1;
	~beat = ~beat % 4;
	0.5;
};
};
)

(
"".postln;
"-------------".postln;
~forko.source = {
	loop{
		var lel;

		if(~beat==0){~changes.value};
		lel = ~fun.value;


		lel.wait;
	}
}
)

~beat = 0
~forko.play

(
"".postln;
"-------------".postln;
~forko.stop;
~forko.source = {
	loop{
		if(~beat==0,
			{" ".postln;Synth(\bip, [\freq, 500])},
			{Synth(\bip)}
		);
		(~beat+1).post;
		(" ").post;
		~beat = ~beat +1;
		~beat = ~beat % 4;
		0.4.wait;
	}
};
~forko.play;
)
