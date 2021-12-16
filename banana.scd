(
o = Server.default.options;
// o.inDevice = "Microphone (Realtek High Defini";
o.inDevice = "VoiceMeeter Output (VB-Audio Vo";
o.outDevice = "MME : Speakers (Realtek High Definiti";
s.reboot;
)
// ServerOptions.outDevices.do{|device| device.postln}; // Print all devices



(
if(Ndef(\out).isPlaying == false){Ndef(\out).play;};
Ndef(\out, {
	var sig = SoundIn.ar(0);
	// sig = PitchShift.ar(sig, 0.2, (0 .. 2).midiratio);
	sig = FreeVerb.ar(sig, 0.3, 0.9);
	sig = FreeVerb.ar(sig, 1.3, 0.9) + sig;
	sig = LPF.ar(sig, SinOsc.kr(0.1).range(3000, 10000));
	// sig = sig * Pulse.kr(1, 0.9);
	sig = CombC.ar(sig, 0.1, 0.8, 1) + sig;


	sig = Mix.ar(sig);
	sig = LPF.ar(sig, 10000);
	Limiter.ar(sig!2);
});
Ndef(\out).fadeTime = 4;
)


