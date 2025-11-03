//Pattern Guide Cookbook 01: Basic Sequencing

(
TempoClock.default.tempo = 84/60;

p = Pbind(
	\scale, #[0, 2, 3, 5, 7, 8, 10],
	\root, 2,
	\degree, Pseq(#[rest, 4, 3, 4, 2, 4, 1, 4, 0, 4, -0.9, 4, 0, 4, 1, 4, 2, 4, -3, 4, -1.9, 4, -0.9, 4, 0, 4, -0.9, 4, 0, 4, 1, 4, 2], inf),
	\dur, 0.25
).play;
)

(
p = Pbind(
	\scale, #[0, 2, 3, 5, 7, 8, 10],
	\root, 2,
	\degree, Place([#
		[rest, 3, 2, 1, 0, -0.9, 0, 1, 2, -3, -1.9, -0.9, 0, -0.9, 0, 1, 2],
		(4 ! 16) ++ \rest], 17),
	\dur, 0.25
).play;
)


(
p = Pbind(
    \scale, #[0, 2, 3, 5, 7, 8, 10],
    \root, 2,
    \degree, Ppatlace([Pseq(#[rest, 3, 2, 1, 0, -0.9, 0, 1, 2, -3, -1.9, -0.9, 0, -0.9, 0, 1, 2], 1),
        Pn(4, 16)], inf),
    \dur, 0.25
).play;
)


//"Multichannel expansion"
(
(
p = Pbind(
	\degree, Pseries(
		7,
		Pwhite(1, 3, inf) * Prand(#[-1, 1], inf),
		inf).fold(0, 14) + Prand(#[
		[0, -2, -4],
		[0, -3, -5],
		[0, -2, -5],
		[0, -1, -4]
	], inf),
	\dur, Pwrand(#[1, 0.5], #[0.8, 0.2], inf)
)
).play;
)
p.stop;

//Using custom SynthDefs

(
b = Buffer.read(s, ExampleFiles.child);
)
(
SynthDef(\stretchedFragments, {
	|out, bufnum, start, time=1, stretch=1, amp=1, attack=0.01, decay=0.05|
	var sig = PlayBuf.ar(
		1,
		bufnum,
		rate: stretch.reciprocal,
		startPos: start), eg;
	sig = PitchShift.ar(sig, pitchRatio: stretch);
	eg = EnvGen.kr(Env.linen(attack, time, decay), sig.abs > 0, doneAction: Done.freeSelf);
	Out.ar(out, (sig * eg) ! 2);
}).add;
)

(
TempoClock.default.tempo = 1;

p = Pbind(
	\instrument, \stretchedFragments,
	\bufnum, b,
	\start, Pwhite(0, (b.numFrames * 0.2).asInteger, inf),
	\delta, Pexprand(0.2, 0.8, inf),
	\time, Pkey(\delta),
	\stretch, Pexprand(1.0, 4.0, inf),
	\amp, 0.5,
	\attack, 0.1,
	\decay, 0.2
).play;
)

p.stop;
b.free;

//Pattern Guide Cookbook 02: Manipulating Patterns




//Manipulating Pattern Data
(
var melodies = (
	lowMelody: Pseries(4, Prand(#[-2, -1, 1, 2], inf), inf.fold(-7, 11)),
	highMelody: Pseries(14, Prand(#[-3, -2, 2, 3], inf), inf).fold(7, 18);
);

p = Pbind(
	\degree, Pnsym1(Pwrand(#[lowMelody, highMelody], [0.7, 0.3], inf), melodies),
	\dur, Pwrand(#[0.25, 0.5], #[0.4, 0.6], inf)
).play;
)


//Reading an array forward or backward arbitrarily

(
var pitches = (0..14), move = 0, window, slider;

window = Window(\Mouse_Transport, Rect(5, 100, 500, 50));
slider = Slider(window, Rect(5, 5, 490, 20))
.action_({
	|view|
	move = (view.value * 4 -2).round;
})
.value_(0.5);
window.front;

p = Pbind(
	\degree, Pwalk(pitches, Pfunc { move }, 1, 7),
	\dur, 0.25
).play;
)


//changing pbind values on the fly

//using environment variables
(
~degree = PatternProxy(Pn(Pseries(0, 1, 8), inf));
~dur = PatternProxy(Pn(0.25, inf));

p = Pbind(
	\degree, ~degree,
	\dur, ~dur
).play;
)

~degree.source = (Pexprand(1, 8, inf) -1).round;
~dur.source = Pwrand(#[0.25, 0.5, 0.75], #[0.5, 0.3, 0.2], inf);

p.stop;

//Pdefn
(
Pdefn(\degree, Pn(Pseries(0, 1, 8), inf));
Pdefn(\dur, Pn(0.25, inf));

p = Pbind(
	\degree, Pdefn(\degree),
	\dur, Pdefn(\dur)
).play;
)

Pdefn(\degree, (Pexprand(1, 8, inf) -1).round);

Pdefn(\dur, Pwrand(#[0.25, 0.5, 0.75], #[0.5, 0.3, 0.2], inf));
p.stop;




















































































