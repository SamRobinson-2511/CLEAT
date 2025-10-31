//Routine
a = Routine.new({ 1.yield; 2.yield });
a.next.postln;
a.next.postln;
a.next.postln;

//function class provides its own shortcut method
a = r { 1.yield; 2.yield };
a.next;
a.next;
a.next;
a.reset;

(
r = Routine {
	|inval|
	inval.postln;
	inval = 123.yield;
	inval.postln;
}
)
r.value("hello routine");
r.value("goodbye routine");

(
r = Routine {
	|inval|
	inval.postln; //post value passed in when started
	5.do {
		|i|
		inval = (i + 10).yield;
		inval.postln; //post the value passed in when resumed
	}

}
)
(
5.do {
	r.value("hello routine").postln; //post the value that the Routine yields

}
)





//Routine.play(clock, quant);
(
r = Routine {
	199.yield;
	189.yield;
	200.idle(6);
	199.yield;
	189.yield;
};

fork {
	loop {
		r.value.postln;
		1.wait;
	}
}
)
r.stop;

//the value can also be a stream or a function
(
r = Routine {
	199.yield;
	189.yield;
	Routine { 100.do {
		|i|
		i.yield;
	}}.idle(100);
	199.yield;
	189.yield;
};

fork {
	loop {
		r.value.postln;
		1.wait;
	}
}
)

//Routine.reschedule
//rescheduling to a different clock, same time
c = TempoClock.new;
(
t = Routine {
	var lastSeconds = thisThread.seconds;
	loop {
		1.0.wait;
		[thisThread.beats, thisThread.seconds - lastSeconds].postln;
		lastSeconds = thisThread.seconds;
	}
}.play;
)
t.reschedule(c); //seconds delta = 1.0 throughout
t.stop;

//rescheduling to a later time, same clock
(
t = Routine {
	var lastSeconds = thisThread.seconds;
	loop {
		1.0.wait;
		[thisThread.beats, thisThread.seconds - lastSeconds].postln;
		lastSeconds = thisThread.seconds;
	}
}.play;
)
t.reschedule(quant: 1);
t.stop;

//Fieldsteel: Routines and Clocks

~kick = Buffer.read(s, "/Users/robinson.will.sam/Desktop/taste_rubber_test/02-251013_2314.wav" );
~snare = Buffer.read(s, "/Users/robinson.will.sam/Desktop/taste_rubber_test/02-251016_0143.wav");

(
SynthDef(\sine, {
	var sig;
	sig = SinOsc.ar(\freq.ir(440), \phs.ir(0));
	sig = Pan2.ar(sig, \pan.ir(0), \amp.kr(0.2));
	sig = sig * Env(
		levels: [0, 1, 1, 0],
		times: [\atk.ir(0.001), \sus.ir(0.03), \rel.ir(0.001)]
	).ar(Done.freeSelf);
	Out.ar(\out.ir(0), sig);
}).add;

SynthDef(\sampler, {
	var sig, env, buf = \buf.ir(0);
	sig = PlayBuf.ar(1, buf, BufRateScale.ir(buf) * \rate.ir(1));
	sig = LPF.ar(sig, \lpf.ir(20000));
	sig = HPF.ar(sig, \hpf.ir(40));
	sig = Pan2.ar(sig, \pan.ir(0), \amp.ir(0.2));
	sig = sig * Env(
		levels: [0, 1, 1, 0],
		times: [\atk.ir(0), \sus.ir(1), \rel.ir(1)],
		curve: [\sin, 0, \relcrv.ir(-4)]
	).ar(Done.freeSelf);
	Out.ar(\out.ir(0), sig);
}).add;
)

(
Synth(\sampler, [
	buf: [~kick, ~snare],
	atk: 2,
	sus: 10000,
	rel: 10000,
	lpf: rrand(5000, 7000).round(45),
	hpf: rrand(1500, 20000),
	rate: exprand(1, 200.5),
	amp: 0.1
]);
)

//Routine
(
f = {
	Synth(\sampler, [buf: ~kick, atk: rrand(0.1, 2.0), sus:20, rel: 40, rate: 20.33.midiratio, amp: 0.5, lpf: 50]);
	Synth(\sampler, [buf: ~snare, atk: rrand(0.1, 4.0), sus:20, rel: 4, rate: 61.midiratio, amp: 0.1, lpf: 350, pan: rrand(-1, 1)]);
	Synth(\sampler, [buf: ~kick, atk: rrand(0.1,0.6), sus:20, rel: 4, rate: 62.midiratio, amp: 0.1, lpf: 1200]);
};
)
f.();






(
r = Routine({
	0.postln;
	2.wait;
	10.postln;
	6.wait;
	100.postln;
});
)
r.play;




(
f = {
	Synth(\sampler, [buf: ~kick, atk: rrand(0.1, 2.0), sus:20, rel: 40, rate: 20.33.midiratio, amp: 0.5, lpf: 50]);
	1.yield;
	Synth(\sampler, [buf: ~snare, atk: rrand(0.1, 4.0), sus:20, rel: 4, rate: 61.midiratio, amp: 0.1, lpf: 350, pan: rrand(-1, 1)]);
	1.yield;
	Synth(\sampler, [buf: ~kick, atk: rrand(0.1,0.6), sus:20, rel: 4, rate: 62.midiratio, amp: 0.1, lpf: 1200]);
	1.yield;
};
)

(
r = Routine(f);
)
r.play;
r.next;
r.next;
r.next;













