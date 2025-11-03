(
{
	PinkNoise.ar(EnvGen.kr(
		Env.perc, doneAction: Done.freeSelf

	)
)}.play;
)


//as an amplitude envelope
(
{
	var env = Env([0,1, 0.5, 1, 0], [0.01, 0.5, 0.02, 0.5]);
	SinOsc.ar(470!2) * EnvGen.kr(env, doneAction:Done.freeSelf

	)
}.play;
)

//as an amplitude and modulation envelope
(
{
	var env = Env(
		[0, 1, 0.5, 0.8, 0, 1.2, 0],
		[0.01, 0.5, 0.02, 0.5, 0.2, 0.5]
	);
	var gate = Impulse.kr(
		MouseX.kr(0.2, 30), 0.5
	);
	var gen = EnvGen.kr(env, gate);
	SinOsc.ar(270!2, SinOsc.ar(gen*473))*gen * 0.2;
}.play;
)

//EnvGen multichannel expands when passed a multichannel envelope
(
{
	SinOsc.ar(
		EnvGen.kr(
			Env.circle(
				[0, 1, 0, (2..4), 0,
					LFNoise1.kr(0.1!5)*10,
				0], [0.01, 0.6]
			)
		)
		* 240 + 300
	).sum * 0.2
}.play;
)


//Examples

//retriggered envelope by Dust.kr
(
{
	var env = Env(
		[0.0, 0.5, 0.0, 1.0, 0.9, 0.0],
		[0.05, 0.1, 0.01, 1.0, 1.5],
		-4
	);
	var envgen = EnvGen.ar(env, Dust.ar(1));
	SinOsc.ar(
		envgen * 1000 + 440
	) * envgen * 0.1
}.play;
)

//two channels
(
{
	var env = Env(
		[0.0,
			[-0.2, 0.5],
			0.0, 1.0,
			[-0.4, 0.9],
			0.0],
		[0.05, 0.1, 0.01, 1.0, 1.5], -4
	);
	var envgen = EnvGen.ar(env, Dust.ar([1, 1]));
	SinOsc.ar(
		envgen * 440 + 550
	) * envgen * 0.1
}.play;
)


//an envelope in a SynthDef can be used to limit the synth's lifetime (doneAction: Done.freeSelf)

(
SynthDef(\env_help, {
	|out, gate=0, freq=440|
	var z;
	z = EnvGen.kr(
		Env.perc,
		doneAction:Done.freeSelf
	) *
	SinOsc.ar(freq, 0, 0.1);
	Out.ar(out, z);
}).add;

(
fork {
	10.do{
		Synth(\env_help);
		0.2.rand.wait;
	}
}
)
)


//using a gated envelope to gate a sound
(
SynthDef(\env_help, {
	|out, gate=0, freq=440, doneAction = 0|
	var z = EnvGen.kr(Env.adsr, gate, doneAction: doneAction) * SinOsc.ar(freq, 0, 0.1);
	Out.ar(out, z);
}).add;
)
a = Synth(\env_help);
a.set(\gate, 1);
a.set(\gate, 0);

//sed doneAction to two to let the synth free itself
a.set(\doneAction, 2, \gate, 0);

//free synth directly
a.free;

//SPECIFYING AN ENVELOPE FOR EACH NEW SYNTH
(
SynthDef(\help_Env_newClear, {
	|out = 0|
	var env, envctl;
	env = Env.newClear(4);
	envctl = \env.kr(env.asArray);
	Out.ar(out, SinOsc.ar(EnvGen.kr(envctl, \gate.tr), 0, 0.3));
}).add;
)

(
Synth(\help_Env_newClear, [
	\gate, 1,
	\env, Env([700, 900, 900, 800], [1, 1, 1], \exp)]);
)


//reset then play again
(
Synth(\help_Env_newClear, [
	\gate, 1,
	\env, Env({rrand(60, 70).midicps } ! 4, [1, 1, 1], \exp)
	]
);
)

//the same written as an event:
(
(
instrument: \help_Env_newClear,
gate: 1,
env: Env({ rrand(60, 70).midicps } ! 4, [1, 1, 1], \exp);
).play;
)


//Forced release
(
SynthDef(\stealMe, {
	|out, gate=1|
	Out.ar(out, {
		BrownNoise.ar}.dup * EnvGen.kr(Env.asr, gate, doneAction: Done.freeSelf)
	)
}).add;
)

a = Synth(\stealMe);
a.release(3);

//this is how the OSC data looks
s.sendMsg(\s_new, \stealMe, 1001, 1, 0);
s.sendMsg(\n_set, 1001, \gate, -1.1);

//if the synthdef has an arg named 'gate' the convenience method of Node can be used
d = { |gate = 1| { BrownNoise.ar }.dup * EnvGen.kr(Env.asr, gate, doneAction: Done.freeSelf) }.play;
d.release(3);

//Fast triggering tests
s.reboot;
(
{
	EnvGen.kr(
		Env([0.001, 1, 0.5, 0], [0.01, 0.3, 1], -4, 2, nil),
		Impulse.kr(10)
	) * SinOsc.ar(440, 0, 0.1)
}.play;
)

(
{
	EnvGen.kr(
		Env.perc(0.1, 0.0, 0.5, 1, \welch),
		Impulse.kr(100),
		timeScale: 0.1
	) * SinOsc.ar(440, 0, 0.3)
}.play;
)

//Modulating the level scale
(
{
	EnvGen.kr(
		Env.asr(0.1, 1.0, 0.5, \welch),
		1.0,
		FSinOsc.ar(1.0).range(0.0, 1.0),
		timeScale: 0.1
	) * SinOsc.ar(440, 0, 0.3)
}.play;
)

(
{
	EnvGen.kr(
		Env.asr(0.1, 1.0, 0.5, \welch),
		1.0,
		Rand(0.1, 1.0),
		timeScale: 0.1
	) * SinOsc.ar(440, 0, 0.3)
}.play;
)


//filter cutoff modulation and initial envelope level

(
a = Bus.control(s, 1);

Slider(nil, Rect(800, 200, 200, 25))
.action_({ |view| a.set(view.value.lincurve(0, 1, 0, 0.12, 4)) })
.front
.onClose_({ p.stop; a.free });

SynthDef(\test, { |out = 0, freq = 100, ffreq = 500, rq = 0.25, modFactor = 12, atk = 0, dcy = 0.12|
    // change to 'envInit = 0' to hear the short-attack artifacts
    // warning: envInit = 0 may be LOUD
    var envInit = atk.linlin(0, 0.05, 1, 0);
    var filtEg = EnvGen.kr(Env([envInit, 1, 0], [atk, dcy], -4));
    var ampEg = EnvGen.ar(Env.linen(0.001, 0.2, 0.1), doneAction: 2);
    var sig = Saw.ar(freq);
    ffreq = ffreq * (1 + (filtEg * modFactor));
    sig = BLowPass4.ar(sig, ffreq, rq) * ampEg;
    Out.ar(out, (sig * 0.1).dup)
}).add;

p = Pbind(
    \instrument, \test,
    \freq, 100,
    \atk, a.asMap
).play;
)



//
(
Slider(nil, Rect(800, 200, 200, 25))
.action_({ |view| z.set(\atk, view.value.lincurve(0, 1, 0, 0.12, 4)) })
.front
.onClose_({ z.free });

z = SynthDef(\test, { |out = 0, freq = 100, ffreq = 500, rq = 0.25, modFactor = 12, atk = 0, dcy = 0.12|
    var trig = Impulse.kr(1);
    var filtEg = EnvGen.kr(Env([0, 1, 0], [atk, dcy], -4), trig);
    var ampEnvDelay = max(0, (0.05 - atk) * 0.1);
    var ampEg = EnvGen.ar(Env.linen(0.001, 0.2, 0.1), TDelay.kr(trig, ampEnvDelay));
    var sig = Saw.ar(freq);
    ffreq = ffreq * (1 + (filtEg * modFactor));
    sig = BLowPass4.ar(sig, ffreq, rq) * ampEg;
    Out.ar(out, (sig * 0.1).dup)
}).play;
)



//More examples

//1. Changing an envelope while playing

(
SynthDef(\env, {
	|i_outbus = 0|
	var env, envctl;
	//make a dummy 8 segment envelope
	env = Env.newClear(8);
	//create a control argument array
	envctl = \env.kr(env.asArray);
	ReplaceOut.kr(i_outbus, EnvGen.kr(envctl, doneAction: Done.freeSelf));
}).add;
)

(
SynthDef(\sine, {
	|out, freq=440|
	Out.ar(out, SinOsc.ar(freq, 0, 0.2));
}).add;
)

f = Bus.control(s, 1);
f.set(800);

//use f's control bus value for frequency
//i.e. *map* the control to read from the bus
a = Synth(\sine, [\freq, f.asMap]);

Synth(\env, [i_outbus: f, env: Env([700, 900, 900, 800], [1, 1, 1] * 0.4, \exp)]);

Synth(\env, [i_outbus: f, env: Env([1000, 1000, 800, 1000, 900, 1000], [1, 1, 1, 1, 1] * 0.3)]);

a.free;
f.free;































































































































