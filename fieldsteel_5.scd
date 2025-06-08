s.meter;

s.plotTree;

x = {SinOsc.ar([300, 400])}.play;

(
x = {
	var sig, amp;
	amp = SinOsc.kr([7, 14]).range(0.1);
	sig = SinOsc.ar([300, 500, 700, 900, 1100]);
	sig = sig * amp;
/*	Mix.new(sig)!2 * 0.25;*/
	Splay.ar(sig) * 0.5;
}.play;
)
x.free;

60.dup(4);


x = {PinkNoise.ar(0.5)!2}.play;
x = {PinkNoise.ar(0.5!2)}.play;


(
SynthDef(\multi, {
	var sig, amp;
	amp = SinOsc.kr([7, 1, 2, 0.2, 6]).range(0.1);
	sig = SinOsc.ar([300, 500, 700, 900, 1100]);
	sig = sig * amp;
	Splay.ar(sig) * 0.5;
	Out.ar(0, sig);
}).add;
)

x = Synth(\multi);

{rrand(50, 1200)}!4;

(
SynthDef(\rand, {
	var sig, amp;
	amp = SinOsc.kr({exprand(0.2, 12).postln}!8);
	sig = SinOsc.ar({exprand(50, 1200).postln}!8);
	sig = sig * amp;
	sig = Splay.ar(sig) * 0.5;
	Out.ar(0, sig);
}).add;
)

x = Synth(\rand);
x.free;

(
SynthDef(\better_rand, {
	|lfoRange = 0.1, frqe|
	var sig, amp, env;
	env = EnvGen.kr(Env.new([0, 1, 0], [10, 10], [1, -1]),doneAction: 2);
	amp = SinOsc.kr({ExpRand(0.2, 12)}! 16).range(lfoRange);
	sig = SinOsc.ar({ExpRand(50, 1200)}! 16);
	sig = sig * amp * env;
	sig = Splay.ar(sig) * 0.5;
	Out.ar(0, sig);
}).add;
)

x = Synth(\better_rand);
x.set(\lfoRange, linexp(0.1, 2.0, 10));
x.free;

