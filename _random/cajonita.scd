s.boot

(
SynthDef(\apu, {|out= 0, gate= 1, dur=1, a0= 0, a1= 0, a2= 0, a3= 0, b0= 0, b1= 0, b2= 0, b3= 0, c0= 0, c2= 0, c3= 0, d0= 0, d2= 0, d3= 0, e0= 0, e1= 0, e2= 0, e3= 0, smask= 0, amp= 1, pan= 0|
    var sig;
	sig = Nes2.ar(gate, a0, a1, a2, a3, b0, b1, b2, b3, c0, c2, c3, d0, d2, d3, e0, e1, e2, e3, smask);

    Out.ar(out, sig * Line.kr(1, 1, dur, doneAction: Done.freeSelf););
}).add;
)


(
~durpat = Pseq([2, 1.75], inf).asStream;
~forko.stop();
~forko = {
	var beat = 0;
	var data;
	loop {
		~dur = 1/~durpat.next/4;
		data = a[beat];


		~apu = Synth(\apu, [
			\dur, ~dur,
			\a0, data[0],  \a1, data[1], \a2, data[2],  \a3, data[3],
			\b0, data[4],  \b1, data[5], \b2, data[6],  \b3, data[7],
			\c0, data[8]               , \c2, data[9],  \c3, data[10],
			\d0, data[11]              , \d2, data[12], \d3, data[13],
			\smask, 2r00001111]);
		(~dur).wait;

		a[beat][rand(14)] = rand(255);

		beat = beat + 1;
		beat = beat % a.size;
	};
}.fork
)


(
a =
[
	[rand(255), 1, rand(255), rand(255),  rand(255),0,rand(255),rand(255),  rand(255),rand(255),rand(255), rand(255),rand(255),rand(255) ],
	[rand(255), 1, rand(255), rand(255),  rand(255),0,rand(255),rand(255),  rand(255),rand(255),rand(255), rand(255),rand(255),rand(255) ],
	[rand(255), 1, rand(255), rand(255),  rand(255),0,rand(255),rand(255),  rand(255),rand(255),rand(255), rand(255),rand(255),rand(255) ],
	[rand(255), 1, rand(255), rand(255),  rand(255),0,rand(255),rand(255),  rand(255),rand(255),rand(255), rand(255),rand(255),rand(255) ],
	[rand(255), 1, rand(255), rand(255),  rand(255),0,rand(255),rand(255),  rand(255),rand(255),rand(255), rand(255),rand(255),rand(255) ],
	[rand(255), 1, rand(255), rand(255),  rand(255),0,rand(255),rand(255),  rand(255),rand(255),rand(255), rand(255),rand(255),rand(255) ],
	[rand(255), 1, rand(255), rand(255),  rand(255),0,rand(255),rand(255),  rand(255),rand(255),rand(255), rand(255),rand(255),rand(255) ],
	[rand(255), 1, rand(255), rand(255),  rand(255),0,rand(255),rand(255),  rand(255),rand(255),rand(255), rand(255),rand(255),rand(255) ],
]
)
s.scope



Ndef(\foo, {|freq=220|
VarSaw.ar(
freq.lag(0.6)
) * 0.1
}).play(0, 2);
Ndef(\ctl, { LFNoise1.kr(1).range(200, 1200) })
Ndef(\foo).map(\freq, Ndef(\ctl)kr)

