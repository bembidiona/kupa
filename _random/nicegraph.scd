//Example18 - waveform
(
s.latency= 0.05;
s.waitForBoot{
    l= 800;  //global window size
    b= Buffer.alloc(s, l, 1);
    c= Buffer.read(s, Platform.resourceDir+/+"sounds/a11wlk01.wav");
    SynthDef(\avTrk, {|in= 0, bufnum, rate= 40, sample= 1|
        var z= In.ar(in, 1);
        var trig= Impulse.ar(rate*0.92);  //compensate
        var index= Phasor.ar(trig, sample, 0, BufFrames.ir(bufnum)-1);
        BufWr.ar(z, bufnum, index, 0);
        SendTrig.ar(trig, 0, bufnum);
    }).add;
    SynthDef(\avSnd, {|out= 0, bufnum|
        var z= PlayBuf.ar(
            1,
            bufnum,
            BufRateScale.ir(bufnum)*LFPulse.kr(0.05, 0, 0.5, 0.2, -1.5),
            Impulse.kr(LFPulse.kr(0.1, 0, 0.1, 2, 1)),
            BufFrames.ir(bufnum)*LFNoise0.kr(0.2, 0.5, 0.5).round(0.2),
            1
        );
        Out.ar(out, Pan2.ar(z));
    }).add;
};
)

(
//--setup
var width= l, height= l;
var w= Window("Example18 - waveform", Rect(99, 99, width, height), false);
var u= UserView(w, Rect(0, 0, width, height));

//--variables
var theta= 0;
var fps= 60;
var arr= Array.fill(l, 0);  //same as half windowsize above
var o= OSCFunc({|m|
    if(m[2]==0, {  //redraw once for each cycle of amps
        b.getn(0, l-1, {|data| {arr= data; u.refresh}.defer});
    });
}, '/tr', s.addr);
var trk= Synth(\avTrk, [\in, 0, \bufnum, b, \rate, fps]);
var snd= Synth(\avSnd, [\out, 0, \bufnum, c]);

//--interface
~trails= 1;
~speed= 0;
~sample= 1;
~amp= 0.5;
~version= 0;

//--main loop
u.drawFunc= {
    trk.set(\sample, ~sample);
    Pen.fillColor= Color.grey(0, ~trails);
    Pen.fillRect(u.bounds);  //manually clear
    Pen.strokeColor= Color.green;
	Pen.width = 4;
    switch(~version,
        0, {  //line
            Pen.rotate(theta, width/2, height/2);
            Pen.translate(0, height*0.5);
            arr.do{|y, x|
                var p= Point(x, y*(height*~amp));
                if(x==0, {Pen.moveTo(p)}, {Pen.lineTo(p)});
            };
            Pen.stroke;
        },
        1, {  //warp
            Pen.rotate(theta, width/2, height/2);
            Pen.translate(width*0.5, height*0.5);
            arr.do{|y, x|
                var p= Point(x*~amp, y*~amp).rotate(y*2pi);
                if(x==0, {Pen.moveTo(p)}, {Pen.lineTo(p)});
            };
            Pen.stroke;
        },
        2, {  //flower
            Pen.translate(width*0.5, height*0.5);
            Pen.moveTo(Point(arr[0], 0)*arr[0]);
            arr.do{|y, x|
                var p= Point(y, x)*y;
                var a= x%width/width*2pi+theta;
                Pen.lineTo(p.rotate(a));
            };
            Pen.stroke;
        }
    );
    theta= theta+~speed;
};

//--window management
u.clearOnRefresh= false;  //do not erase - just draw on top of
w.onClose= {
    snd.free;
    trk.free;
    o.free;
};
w.front;
CmdPeriod.doOnce({if(w.isClosed.not, {w.close})});
//note no animate_ here. the responder is driving the animation
)

//change these while the program is running
~sample= 1;
~sample= 10;
~sample= 1;
~trails= 0.2;
~speed= 0;
~speed= -0.05;
~trails= 0.01;
~amp= 0.02;
~speed= pi*0.25;
~amp= 0.2;
~sample= 2;
~version= 1;
~trails= 0.2;
~version= 2;
~sample= 1;
~version= 1;
~speed= 2pi*1.001;
~amp= 0.5;

//close the window to stop or press cmd+.
b.free;  //free the waveform buffer
c.free;  //free the sound file buffer