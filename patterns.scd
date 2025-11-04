//Pattern Guide 01: Introduction

(
a = Routine {
	var i = 0;
	loop {
		i.yield;
		i = i + 1;
	};
};
a.nextN(10);
)

//simplified control structure
(
a = Routine {
	(0..).do{
		|i|
		i.yield;
	};
};
a.nextN(10);
)

//Pseries
(
a = Pseries(start: 0, step:1, length: inf).asStream;
a.nextN(10);
)

(
p = Pseries(0, 1, 10);
q = p.asStream;
)


r = p.asStream;
r.next;


[q.next, r.next]

//Pattern Guide 02: Basic Vocabulary

//Functional Description of Patterns
//List Patterns

Pseq(#[1,2,3],4).asStream.all;
(
p = Pbind(
	\degree, Pseq(#[0, 0, 4, 4, 5, 5, 4], 1),
	\dur, Pseq(#[0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 1], 1)
).play;
)

Pser(#[1,2,3],4).asStream.all;

Pslide(#[1, 2, 3, 4, 5, 6, 7, 8], 10, 3, 1, 0, false).asStream.all;

Pslide(#[1, 2, 3, 4, 5, 6, 7, 8], 10, 3, 1, 0, false).clump(3).asStream.all;

(
p = Pbind(
	\degree, Pslide((-6, -4 .. 12), 8, 3, 1, 0),
	\dur, Pseq(#[0.1, 0.1, 0.2], inf),
	\sustain, 0.15
).play;
)


//Random Order List Patterns

//Prand = equal distribution
(
p = Pbind(
	\degree, Prand([0, 1, 2, 4, 5], inf),
	\dur, 0.25
).play;
)

//Pxrand = never repeats 2x in a row
(
p = Pbind(
	\degree, Pxrand([0, 1, 2, 4, 5], inf),
	\dur, 0.25
).play;
)

//Pshuf = shufflethe list in random order and use the same random order repeats times (list.scramble)



(
p = Pbind(
	\degree, Pshuf([0, 1, 2, 4, 5], inf),
	\dur, 0.25
).play;
)

//Pwrand = choose randomly according to weighted probabilities (list.wchoose(weights))

(
p = Pbind(
	\degree, Pwrand((0..7), [4, 1, 3, 1, 3, 2, 1].normalizeSum, inf),
	\dur, 0.25
).play;
)

//Pwalk = random walk over the list
(
a = Pwalk(
	Array.series(20, 0, 1),
	Pwrand([-2, -1, 0, 1, 2], [0.05, 0.1, 0.15, 1, 0.1].normalizeSum, inf),
	Pseq([1, -1], inf),
	10);
x = a.asStream;

200.do({ x.next.post; ", ".post });

b = a.copy.directionPattern_(1);
x = b.asStream;

200.do({ x.next.post; ", " });
)
(
a = Pwalk(
	[60, 64, 67, 72, 76, 79, 84].midicps,
	Pseq([1], inf),
	Pseq([1, -1], inf),
	0);
x = a.asStream;
SynthDef(\help_walk, {
	|out, freq|
	Out.ar(out, Saw.ar([freq, freq+1], 0.5) *
		EnvGen.kr(Env.perc(0.01, 0.1), doneAction: Done.freeSelf))
}).add;
)

s.reboot;
(
r = Task({
	{
		Synth(\help_walk, [\freq, x.next]);
		0.1.wait;
	}.loop;
}).play(SystemClock);
)

r.stop;


//Interlacing Values and Making Arrays
//Place
(
Place([0, [1, 2], [3, 4, 5]], 3).asStream.all;
)

(
Place([0, [1,2], [3,4,5]], 3).clump(3).do(_.postln);
)

//Ppatlace(list, repeats, offset)
//Hanon exercise
(
p = Pbind(
	\degree, Ppatlace([
		Pseries(0, 1, 8),
		Pseries(2,1,7)
	], inf),
	\dur, 0.25
).play;
)

//Ptuple(list, repeats): get one value from each item in the array and return all of them as an array of values

(
p = Pbind(
	\degree, Ptuple([
		Pseries(7, -1, 8),
		Pseq([9, 7, 7, 7, 4, 4, 2, 2], 1),
		Pseq([4, 4, 4, 2, 2, 0, 0, -3], 1)
	], 1),
	\dur, 1
).play;
)


//Arithmetic and Geometric Series
//Pseries(start, step, length):

//Pgeom(start, grow, length): successively multiplying the current value by grow

//Use Pseries for a scale and Pgeom for an accelerando

(
p = Pbind(
	\degree, Pseries(-7, 1, 15),
	\dur, Pgeom(0.5, 0.89140193218427, 15)
).play;
)

//Random numbers and probability distributions
//Pwhite(lo, hi, length)
//Pexprand(lo, hi, length)
//Pbrown(lo, hi, step, length)

(
Pmeanrand(0.0, 1.0, inf).asStream.nextN(10000).histo(200,0.0, 1.0).plot;
)


//Pfunc(nextFunc, resetFunc)
//Pfuncn(func, repeats)
//Prout(routineFunc)

//Pattern Guide 03: What is Pbind

(
e = (freq: 440, dur: 0.5);
e.at(\freq);
e[\freq];
e.freq; //see IdentityDictionary
)

(
p = Pbind(
	\degree, Pseq(#[0, 0, 4, 4, 5, 5, 4], 1),
	\dur, Pseq(#[0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 1], 1)
).asStream;
)
p.next(());

//Pmono: monophonic
(
p = Pbind(
	\degree, Pwhite(0, 7, inf),
	\dur, 0.25,
	\legato, 1
).play;
)
p.stop;

(
p = Pmono(
	\default,
	\degree, Pwhite(0, 7, inf),
	\dur, 0.25
).play;
)
p.stop;

//Connecting event values to SynthDef inputs
(
SynthDef(\default, {
	|out=0, freq=440, amp=0.1, pan=0, gate=1|
	var z;
	z = LPF.ar(
		Mix(VarSaw.ar(freq + [0, Rand(-0.4, 0.0), Rand(0.0, 0.4)], 0, 0.3)),
		XLine.kr(Rand(4000, 5000), Rand(2500, 3200), 1)
	) * Linen.kr(gate, 0.01, 0.7, 0.3, 2);
	OffsetOut.ar(out, Pan2.ar(z, pan, amp));
}, [\ir]);
)

(freq: 293.3333, amp:0.2, pan: -0.7).play;
(freq: 440, amp:0.1, pan:0.7).play;

//THE NAMES THAT YOU USE FOR PATTERNS IN PBIND SHOULD CORRESPOND TO THE ARGUMENTS IN THE SYNTHDEF BEING PLAYED

(
SynthDef(\harpsi, {
	|outbus = 0, freq=440, amp=0.1, gate=1|
	var out;
	out = EnvGen.ar(Env.adsr, gate, doneAction: Done.freeSelf) * amp * Pulse.ar(freq, 0.25, 0.75);
	Out.ar(outbus, out ! 2);
}).add;
)

(
p = Pbind(
	\instrument, \harpsi,
	\degree, Pseries(0, 1, 8),
	\dur, 0.25
).play;
)

//Rest events
//Ligeti, 'touches bloquees'(
(
// first, pitches ascending by 1-3 semitones, until 2 octaves are reached
var    pitches = Pseries(0, Pconst(24, Pwhite(1, 3, inf)), inf).asStream.all,
        // randomly block 1/3 of those
    mask = pitches.scramble[0 .. pitches.size div: 3];

p = Pbind(
    \arpeg, Pseq(pitches[ .. pitches.size - 2] ++ pitches.reverse[ .. pitches.size - 2], inf),
        // if the note is found in the mask array, replace it with Rest
        // then that note does not sound
    \note, Pif(Pfunc { |event| mask.includes(event[\arpeg]) }, Rest(0), Pkey(\arpeg)),
    \octave, 4,
    \dur, 0.125
).play;
)
p.stop;

//Writing SynthDefs for Patterns
//1. Synths should release themeselves
//2. Argument name prefixes

(
SynthDef(\trig_demo, {
	|out, freq=440, gate=1, t_trig=1|
	var env = Decay2.kr(t_trig, 0.01, 0.1),
	sig = SinOsc.ar(freq, 0, env) * Linen.kr(gate, 0.01, 0.1, 0.1, doneAction: Done.freeSelf);
	Out.ar(out, sig ! 2)
}).add;
)

(
p = Pmono(\trig_demo,
	\freq, Pexprand(200, 800, inf),
	\trig, 1,
	\delta, 0.125
).play;
)
p.stop;












































































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

//Pattern Guide Cookbook 03: External Control

//Triggering a pattern by a GUI
s.reboot;
(
var    pattern = Pbind(
        \degree, Pseries(7, Pwhite(1, 3, inf) * Prand(#[-1, 1], inf), inf).fold(0, 14)
            + Prand(#[[0, -2, -4], [0, -3, -5], [0, -2, -5], [0, -1, -4]], inf),
        \dur, Pwrand(#[1, 0.5], #[0.8, 0.2], inf)
    ),
    player, window;

window = Window.new("Pattern trigger", Rect(5, 100, 150, 100))
        // onClose is fairly important
        // without it, closing the window could leave the pattern playing
    .onClose_({ player.stop });
Button.new(window, Rect(5, 5, 140, 90))
    .states_([["Pattern GO"], ["Pattern STOP"]])
    .font_(Font.new("Helvetica", 18))
    .action_({ |button|
        if(button.value == 1 and: { player.isNil or: { player.isPlaying.not } }) {
            player = pattern.play;
        } {
            player.stop;
            button.value = 0;
        };
    });
window.front;
)

p.stop;


//Triggering a Pattern by MIDI
(
var    pattern = Pbind(
        \degree, Pseries(7, Pwhite(1, 3, inf) * Prand(#[-1, 1], inf), inf).fold(0, 14)
            + Prand(#[[0, -2, -4], [0, -3, -5], [0, -2, -5], [0, -1, -4]], inf),
        \dur, Pwrand(#[1, 0.5], #[0.8, 0.2], inf)
    ),
    player;

~noteOnFunc = MIDIFunc.noteOn({
    if(player.isNil or: { player.isPlaying.not }) {
        player = pattern.play;
    } {
        player.stop;
    };
// 60 limits this MIDIFunc to listen to middle-C only
// but it will pick up that note from any port, any channel
}, 60);
)

// when done
~noteOnFunc.free;

//Triggering a pattern by signal amplitude
//inbus: s.options.numOutputBusChannels

/*(
var amp = Amplitude.kr(In.ar(inbus, 1), attackTime: 0.01, releaseTime: decay), trig = HPZ1.kr(amp >= thresh);
SendTrig.kr(trig.abs, 1, trig);
)*/

s.reboot;
(
var pattern = Pbind(
	\degree, Pseries(7, Pwhite(1, 3, inf) * Prand(#[-1, 1], inf), inf).fold(0, 14)
	+ Prand(#[[0, -2, -4], [0, -3, -5], [0, -2, -5], [0, -1, -4]], inf),
	\dur, Pwrand(#[1, 0.5], [0.8, 0.2], inf)
),
player;

~w = Window(\Threshold_setting, Rect(15, 100, 300, 100))
.onClose_({
	~ampSynth.free;
	~ampUpdater.free;
	~oscTrigResp.free;
	player.stop;
});
~w.view.decorator = FlowLayout(~w.view.bounds, 2@2, 2@2);
~ampView = EZSlider(~w, 295@20, "amplitude", \amp, labelWidth: 80, numberWidth: 60);
~ampView.sliderView.canFocus_(false).enabled_(false);
~ampView.numberView.canFocus_(false).enabled_(false);
~threshView = EZSlider(~w, 295@30, "threshold", \amp, action: {
	|ez|
	~ampSynth.set(\thresh, ez.value);
}, initVal: 0.4, labelWidth: 80, numberWidth: 60);
~decayView = EZSlider(~w, 295@30, "decay", #[0.1, 100, \exp], action: {
	|ez|
	~ampSynth.set(\decay, ez.value);
}, initVal: 80.0, labelWidth: 80, numberWidth: 60);

~w.front;

~ampSynth = SynthDef(\ampSynth, {
	|inbus, thresh = 0.8, decay = 1|
	var amp = Amplitude.kr(In.ar(inbus, 1), attackTime: 0.01, releaseTime: decay);
	SendReply.kr(Impulse.kr(10), '\amp', amp);
	SendReply.kr(amp >= thresh, '\amptrig');
}).play(args: [inbus: s.options.numOutputBusChannels, thresh: ~threshView.value, decay: ~decayView.value]);

~ampUpdater = OSCFunc({
	|msg|
	if(player.isNil or: { player.isPlaying.not }) {
		player = pattern.play;
	} {
		player.stop;
	};
}, '\amptrig', s.addr)
)

//Pattern Guide Cookbook 04: Sending MIDI

MIDIClient.init;    // if not already done

(
    // substitute your own device here
var    mOut = MIDIOut.newByName("FastLane USB", "Port A").latency_(Server.default.latency);

p = Pbind(
    \type, \midi,
        // this line is optional b/c noteOn is the default
        // just making it explicit here
    \midicmd, \noteOn,
    \midiout, mOut,    // must provide the MIDI target here
    \chan, 0,
        // degree is converted to midinote, not just frequency
    \degree, Pwhite(-7, 12, inf),
    \dur, Pwrand([0.25, Pn(0.125, 2)], #[0.8, 0.2], inf),
    \legato, sin(Ptime(inf) * 0.5).linexp(-1, 1, 1/3, 3),
    \amp, Pexprand(0.5, 1.0, inf)
).play(quant: 1);
)

p.stop;


//Pattern Guide Cookbook 05: Using Samples


(
b = Buffer.read(s, ExampleFiles.child);

//one loop segment
SynthDef(\oneLoop, {
	|out, bufnum, start, time, amp, rate = 1|
	var sig = PlayBuf.ar(
		1,
		bufnum,
		rate: rate * BufRateScale.kr(bufnum),
		startPos: start,
		loop: 9
	),
	env = EnvGen.kr(Env.linen(0.01, time, 0.05, level: amp),
		doneAction: Done.freeSelf);
	Out.ar(out, (sig * env).dup);
}).add;

SynthDef(\bell, {
	|out, accent = 0, amp = 0.1, decayScale = 1|
	var exc = PinkNoise.ar(amp) * Decay2.kr(Impulse.kr(0), 0.01, 0.05),
	sig = Klank.ar(`[
		{ ExpRand(0.1, 0.4)} ! 4,
		1 ! 4,
		{ ExpRand(0.1, 0.4)} ! 4
	], exc, freqscale: accent + 1, decayscale: decayScale);
	DetectSilence.ar(sig, doneAction: Done.freeSelf);
	Out.ar(out, sig.dup)
}).add;
)

(
var start = 0.404561, end = 3.185917, beatsInLoop = 4, originalTempo = beatsInLoop / (end-start);

TempoClock.tempo = originalTempo;

p = Ptpar([
	0, Pbind(
		\instrument, \oneLoop,
		\bufnum, b,
		\amp, 0.4,
		\start, start * b.sampleRate,
		\dur, beatsInLoop,
		\time, Pkey(\dur) / Pfunc { thisThread.clock.tempo },
		\rate, Pfunc { thisThread.clock.tempo / originalTempo
		}
	),
	0.5, Pn(
		Pfindur(4,
			Pbind(
				\instrument, \bell,
				\accent, Pseq([2, Pn(0, inf)], 1),
				\amp, Pseq([0.3, Pn(0.1, inf)], 1),
				\decayScale, Pseq([6, Pn(1, inf)], 1),
				\dur, Pwrand(#[0.25, 0.5, 0.75, 1], #[2,3,1,1].normalizeSum, inf)
			)
		),
	inf),
	0.5, Pbind(
		\instrument, \bell,
		\accent, -0.6,
		\amp, 0.2,
		\decayScale, 0.1,
		\dur, 1
	)
], 1).play;
)

TempoClock.tempo = 104/60;
p.stop;

s.reboot;


//Using quant
(
var start = 0.404561, end = 3.185917, beatsInLoop = 4, originalTempo = beatsInLoop / (end - start);

TempoClock.tempo = originalTempo;

p = Pbind(
	\instrument, \oneLoop,
	\bufnum, b,
	\amp, 0.4,
	\start, start * b.sampleRate,
	\dur, beatsInLoop,
	\time, Pkey(\dur) / Pfunc { thisThread.clock.tempo },
	\rate, Pfunc { thisThread.clock.tempo / originalTempo }
).play(quant: [4, 3.5]);

q = Pn(
	Pfindur(4,
		Pbind(
			\instrument, \bell,
			\accent, Pseq([2, Pn(0, inf)], 1),
			\amp, Pseq([0.3, Pn(0.1, inf)], 1),
			\decayScale, Pseq([6, Pn(1, inf)], 1),
			\dur, Pwrand(#[0.25, 0.5, 0.75, 1], #[2, 3, 1, 1].normalizeSum, inf)
		)
	),
	inf).play(quant: [4, 4]);

r = Pbind(
	\instrument, \bell,
	\accent, -0.6,
	\amp, 0.2,
	\decayScale, 0.1,
	\dur, 1
).play(quant: [4, 4]);
)

[p, q, r].do(_.stop);
b.free;






(
b = Buffer.read(s, ExampleFiles.child);

// one loop segment
SynthDef(\oneLoop, { |out, bufnum, start, time, amp, rate = 1|
    var sig = PlayBuf.ar(1, bufnum,
        rate: rate * BufRateScale.kr(bufnum),
        startPos: start, loop: 0
    ),
    env = EnvGen.kr(Env.linen(0.01, time, 0.05, level: amp),
        doneAction: Done.freeSelf);
    Out.ar(out, (sig * env).dup);
}).add;

SynthDef(\bell, { |out, accent = 0, amp = 0.1, decayScale = 1|
    var exc = PinkNoise.ar(amp)
    * Decay2.kr(Impulse.kr(0), 0.01, 0.05),
    sig = Klank.ar(`[
        { ExpRand(400, 1600) } ! 4,
        1 ! 4,
        { ExpRand(0.1, 0.4) } ! 4
    ], exc, freqscale: accent + 1, decayscale: decayScale);
    DetectSilence.ar(sig, doneAction: Done.freeSelf);
    Out.ar(out, sig.dup)
}).add;
)

(
var start = 0.404561, end = 3.185917,
beatsInLoop = 4,
originalTempo = beatsInLoop / (end - start);

TempoClock.tempo = originalTempo;

p = Ptpar([
    0, Pbind(
        \instrument, \oneLoop,
        \bufnum, b,
        \amp, 0.4,
        \start, start * b.sampleRate,
        \dur, beatsInLoop,
        \time, Pkey(\dur) / Pfunc { thisThread.clock.tempo },
        \rate, Pfunc { thisThread.clock.tempo / originalTempo }
    ),
    0.5, Pn(
        Pfindur(4,
            Pbind(
                \instrument, \bell,
                \accent, Pseq([2, Pn(0, inf)], 1),
                \amp, Pseq([0.3, Pn(0.1, inf)], 1),
                \decayScale, Pseq([6, Pn(1, inf)], 1),
                \dur, Pwrand(#[0.25, 0.5, 0.75, 1], #[2, 3, 1, 1].normalizeSum, inf)
            )
        ),
    inf),
    0.5, Pbind(
        \instrument, \bell,
        \accent, -0.6,
        \amp, 0.2,
        \decayScale, 0.1,
        \dur, 1
    )
], 1).play;
)

// for fun, change tempo
// resyncs on next bar
TempoClock.tempo = 200/60;

p.stop;


//

(
var recorder;
fork {
	b = Buffer.alloc(s, 44100*2, 1);
	s.sync;
	recorder = {
		|freq=440|
		var initPulse = Impulse.kr(0),
		mod = SinOsc.ar(freq) * Decay2.kr(initPulse, 0.01, 3) * 5,
		car = SinOsc.ar(freq + (mod*freq)) * Decay2.kr(initPulse, 0.01, 2.0);
		RecordBuf.ar(car, b, loop:0, doneAction: Done.freeSelf);
		car ! 2
	}.play;
	o = OSCFunc({
		|msg|
		if(msg[1] == recorder.nodeID, {
			"done recording".postln;
			o.free;
		});
	}, '/n_end', s.addr);
};
SynthDef(\sampler, {
	|out, bufnum, freq=1, amp=1|
	var sig = PlayBuf.ar(1, bufnum, rate: freq, doneAction: Done.freeSelf) * amp;
	Out.ar(out, sig ! 2)
}).add;
)

//WAIT for "done recording" message before doing this
(
var samplerEvent = Event.default.put(\freq, {
	~midinote.midicps / ~sampleBaseFreq
});

TempoClock.default.tempo = 1;
p = Pbind(
	\degree, Pwhite(0, 12, inf),
	\dur, Pwrand([0.25, Pn(0.125, 2)], #[0.8, 0.2], inf),
	\amp, Pexprand(0.1, 0.5, inf),
	\sampleBaseFreq, 440,
	\instrument, \sampler,
	\bufnum, b
).play(protoEvent: samplerEvent);
)

p.stop;
b.free;

//Multisampled instruments
//xfade between buffers


/*(
var bufCount;
~midiNotes = (39, 46 .. 88);
bufCount = ~midiNotes.size;

fork {
	//record the samples at different frequencies
	b = Buffer.allocConsecutive(~midinotes.size, s, 44100 * 2, 1);
	SynthDef(\sampleSource, {
		|freq=440, bufnum|
		var initPulse = Impulse.kr(0),
		mod = SinOsc.ar(freq) * Decay2.kr(initPulse, 0.01, 3) * 5,
		car = SinOsc.ar(freq + (mod*freq)) * Decay2.kr(initPulse, 0.01, 2.0);
		RecordBuf.ar(car, bufnum, loop:0, doneAction:Done.freeSelf);
	}).send(s);
	s.sync;
	//record all 8 buffers concurrently
	b.do({
		|buf, i|
		Synth(\sampleSource, [freq: ~midinotes[i].midicps, bufnum: buf])
	});
};
o = OSCFunc({
	|msg|
	bufCount = bufCount-1;
	if(bufCount == 0){
		"done recording".postln;
		o.free;
	};
}, '/n_end', s.addr);

SynthDef(\multiSampler, {
	|out, bufnum, bufBase, baseFreqBuf, freq=440, amp=1|
	var buf1 = bufnum.floor,
	buf2 = buf1 + 1,
	xfade = (bufnum -buf1).madd(2, -1),
	basefreqs = Index.kr(baseFreqBuf, [buf1, buf2]),
	playbufs = PlayBuf.ar(1, bufBase + [buf1, buf2], freq/basefreqs, loop: 0, doneAction: Done.freeSelf),
	sig = XFade2.ar(playbufs[0], playbufs[1], xfade, amp);
	Out.ar(out, sig ! 2);
}).add;

~baseBuf = Buffer.alloc(s, ~midinotes.size, 1, {
	|buf|
	buf.setnMsg(0, ~midinotes.midicps) });
)*/

/////////


(
var bufCount;
~midinotes = (39, 46 .. 88);
bufCount = ~midinotes.size;

fork {
    // record the samples at different frequencies
    b = Buffer.allocConsecutive(~midinotes.size, s, 44100 * 2, 1);
    SynthDef(\sampleSource, { |freq = 440, bufnum|
        var initPulse = Impulse.kr(0),
        mod = SinOsc.ar(freq) * Decay2.kr(initPulse, 0.01, 3) * 5,
        car = SinOsc.ar(freq + (mod*freq)) * Decay2.kr(initPulse, 0.01, 2.0);
        RecordBuf.ar(car, bufnum, loop: 0, doneAction: Done.freeSelf);
    }).send(s);
    s.sync;
    // record all 8 buffers concurrently
    b.do({ |buf, i|
        Synth(\sampleSource, [freq: ~midinotes[i].midicps, bufnum: buf]);
    });
};
o = OSCFunc({ |msg|
    bufCount = bufCount - 1;
    if(bufCount == 0) {
        "done recording".postln;
        o.free;
    };
}, '/n_end', s.addr);

SynthDef(\multiSampler, { |out, bufnum, bufBase, baseFreqBuf, freq = 440, amp = 1|
    var buf1 = bufnum.floor,
    buf2 = buf1 + 1,
    xfade = (bufnum - buf1).madd(2, -1),
    basefreqs = Index.kr(baseFreqBuf, [buf1, buf2]),
    playbufs = PlayBuf.ar(1, bufBase + [buf1, buf2], freq / basefreqs, loop: 0,
        doneAction: Done.freeSelf),
    sig = XFade2.ar(playbufs[0], playbufs[1], xfade, amp);
    Out.ar(out, sig ! 2)
}).add;

~baseBuf = Buffer.alloc(s, ~midinotes.size, 1, { |buf| buf.setnMsg(0, ~midinotes.midicps) });
)

(
TempoClock.default.tempo = 1;
p = Pbind(
    \instrument, \multiSampler,
    \bufBase, b.first,
    \baseFreqBuf, ~baseBuf,
    \degree, Pseries(0, Prand(#[-2, -1, 1, 2], inf), inf).fold(-11, 11),
    \dur, Pwrand([0.25, Pn(0.125, 2)], #[0.8, 0.2], inf),
    \amp, Pexprand(0.1, 0.5, inf),
    // some important conversions
    // identify the buffer numbers to read
    \freq, Pfunc { |ev| ev.use(ev[\freq]) },
    \bufnum, Pfunc({ |ev| ~midinotes.indexInBetween(ev[\freq].cpsmidi) })
    .clip(0, ~midinotes.size - 1.001)
).play;
)

p.stop;
b.do(_.free); ~baseBuf.free;


//Pattern Guide Cookbook 06: Phrase Network
(
SynthDef(\sawpulse, {
	|out, freq=440, gate=0.5, plfofreq=6, mw=0, ffreq=2000, rq=0.3, freqlag=0.05, amp=1|
	var sig, plfo, fcurve;
	plfo = SinOsc.kr(plfofreq, mul:mw, add:1);
	freq = Lag.kr(freq, freqlag) * plfo;
	fcurve = EnvGen.kr(Env.adsr(0, 0.3, 0.1, 20), gate);
	fcurve = (fcurve -1).madd(0.7, 1) * ffreq;
	sig = Mix.ar([Pulse.ar(freq, 0.9), Saw.ar(freq*1.007)]);
	sig = RLPF.ar(sig, fcurve, rq) * EnvGen.kr(Env.adsr(0.04, 0.2, 0.6, 0.1), gate, doneAction: Done.freeSelf) * amp;
	Out.ar(out, sig ! 2)
}).add;
)

(
TempoClock.default.tempo = 128/60;

// Pmul does only one thing here: take ~amp from each event
// and replace it with ~amp * 0.4
p = Pmul(\amp, 0.4, Pfsm([
    #[0, 3, 1],        // starting places
    PmonoArtic(\sawpulse,
        \midinote, Pseq([78, 81, 78, 76, 78, 76, 72, 71, 69, 66], 1),
        \dur, Pseq(#[0.25, 1.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25], 1),
        \sustain, Pseq(#[0.3, 1.2, 0.3, 0.2, 0.3, 0.2, 0.3, 0.2, 0.3, 0.2],1 ),
        \amp, Pseq(#[1, 0.5, 0.75, 0.5, 0.75, 0.5, 0.75, 0.5, 0.75, 0.5], 1),
        \mw, Pseq([0, 0.03, Pseq(#[0], inf)], 1)
    ), #[1, 2, 3, 4, 7],

    PmonoArtic(\sawpulse,
        \midinote, Pseq([64, 66, 69, 71, 72, 73], 1),
        \dur, Pseq(#[0.25], 6),
        \sustain, Pseq(#[0.3, 0.2, 0.2, 0.2, 0.3, 0.2], 1),
        \amp, Pseq(#[1, 0.5, 0.5, 0.5, 0.5, 0.5], 1),
        \mw, 0
    ), #[1, 1, 1, 1, 2, 2, 3, 3, 4, 4, 5],

    PmonoArtic(\sawpulse,
        \midinote, Pseq([69, 71, 69, 66, 64, 69, 71, 69], 1),
        \dur, Pseq(#[0.125, 0.625, 0.25, 0.25, 0.25, 0.25, 0.25, 0.75], 1),
        \sustain, Pseq(#[0.2, 0.64, 0.2, 0.2, 0.2, 0.3, 0.3, 0.75], 1),
        \amp, Pseq(#[0.5, 0.75, 0.5, 0.5, 0.5, 1, 0.5, 0.5], 1),
        \mw, 0
    ), #[0, 1, 1, 1, 1, 3, 3, 3, 3, 5],

    PmonoArtic(\sawpulse,
        \midinote, Pseq([72, 73, 76, 72, 71, 69, 66, 71, 69], 1),
        \dur, Pseq(#[0.25, 0.25, 0.25, 0.083, 0.083, 0.084, 0.25, 0.25, 0.25], 1),
        \sustain, Pseq(#[0.3, 0.2, 0.2, 0.1, 0.07, 0.07, 0.2, 0.3, 0.2], 1),
        \amp, Pseq(#[1, 0.5, 0.5, 1, 0.3, 0.3, 0.75, 0.75, 0.5], 1),
        \mw, 0
    ), #[1, 1, 1, 1, 3, 3, 4, 4, 4],

    PmonoArtic(\sawpulse,
        \midinote, Pseq([64, 66, 69, 71, 72, 73, 71, 69, 66, 71, 69, 66, 64, 69], 1),
        \dur, Pseq(#[0.25, 0.25, 0.25, 0.25, 0.125, 0.375, 0.166, 0.166, 0.168,
                0.5, 0.166, 0.166, 0.168, 0.5], 1),
        \sustain, Pseq(#[0.3, 0.2, 0.2, 0.2, 0.14, 0.4, 0.2, 0.2, 0.2, 0.6, 0.2, 0.2, 0.2, 0.5],1),
        \amp, Pseq(#[0.5, 0.5, 0.6, 0.8, 1, 0.5, 0.5, 0.5, 0.5, 1,
            0.5, 0.5, 0.5, 0.45], 1),
        \mw, 0
    ), #[0, 1, 1, 1, 1, 3, 3, 5],

    PmonoArtic(\sawpulse,
        \midinote, Pseq([72, 73, 76, 78, 81, 78, 83, 81, 84, 85], 1),
        \dur, Pseq(#[0.25, 0.25, 0.25, 0.25, 0.5, 0.5, 0.5, 0.5, 0.125, 1.125], 1),
        \sustain, Pseq(#[0.3, 0.2, 0.2, 0.2, 0.95, 0.25, 0.95, 0.25, 0.2, 1.13], 1),
        \amp, Pseq(#[0.7, 0.5, 0.5, 0.5, 0.7, 0.5, 0.8, 0.5, 1, 0.5], 1),
        \mw, Pseq([Pseq(#[0], 9), 0.03], 1)
    ), #[6, 6, 6, 8, 9, 10, 10, 10, 10, 11, 11, 13, 13],

    PmonoArtic(\sawpulse,
        \midinote, Pseq([83, 81, 78, 83, 81, 78, 76, 72, 73, 78, 72, 72, 71], 1),
        \dur, Pseq(#[0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25,
                0.25, 2], 1),
        \sustain, Pseq(#[0.3, 0.3, 0.2, 0.3, 0.3, 0.3, 0.2, 0.3, 0.2, 0.3, 0.2, 0.3, 2], 1),
        \amp, Pseq(#[0.5, 0.5, 0.5, 0.8, 0.5, 0.5, 0.5, 0.8, 0.5, 0.8, 0.5,
                1, 0.4], 1),
        \mw, Pseq([Pseq([0], 12), 0.03], 1)
    ), #[0, 7, 7, 7, 7, 7, 3, 3, 3, 3],

    PmonoArtic(\sawpulse,
        \midinote, Pseq([69, 71, 72, 71, 69, 66, 64, 69, 71], 1),
        \dur, Pseq(#[0.25, 0.25, 0.25, 0.25, 0.166, 0.167, 0.167, 0.25, 0.25], 1),
        \sustain, Pseq(#[0.2, 0.2, 0.3, 0.2, 0.2, 0.2, 0.14, 0.3, 0.2], 1),
        \amp, Pseq(#[0.5, 0.5, 0.8, 0.5, 0.5, 0.5, 0.5, 0.8, 0.5], 1)
    ), #[3, 3, 3, 4, 4, 5],

    PmonoArtic(\sawpulse,
        \midinote, Pseq([84, 85, 84, 84, 88, 84, 83, 81, 83, 81, 78, 76, 81, 83], 1),
        \dur, Pseq(#[0.125, 0.535, 0.67, 1.92, 0.25, 0.166, 0.167, 0.167,
                0.25, 0.25, 0.25, 0.25, 0.25, 0.25], 1),
        \sustain, Pseq(#[0.2, 3.12, 0.2, 0.2, 0.2, 0.2, 0.2, 0.15, 0.3, 0.2, 0.2, 0.2,
                0.3, 0.2], 1),
        \amp, Pseq(#[1, 0.8, 0.8, 0.8, 1, 1, 0.8, 0.8, 1, 0.8, 0.8, 0.8,
                1, 0.8], 1),
        \mw, Pseq([0, 0.005, 0.005, 0.06, Pseq(#[0], 10)], 1)
    ), #[10, 10, 10, 11, 11, 11, 11, 12, 12, 12],

        // same as #4, 8va
    PmonoArtic(\sawpulse,
        \midinote, Pseq(([64, 66, 69, 71, 72, 73, 71, 69, 66, 71, 69, 66, 64, 69]+12), 1),
        \dur, Pseq(#[0.25, 0.25, 0.25, 0.25, 0.125, 0.375, 0.166, 0.166, 0.168,
                0.5, 0.166, 0.166, 0.168, 0.5], 1),
        \sustain, Pseq(#[0.3, 0.2, 0.2, 0.2, 0.14, 0.4, 0.2, 0.2, 0.2, 0.6, 0.2, 0.2, 0.2, 0.5],1),
        \amp, Pseq(#[0.5, 0.5, 0.6, 0.8, 1, 0.5, 0.5, 0.5, 0.5, 1,
            0.5, 0.5, 0.5, 0.45], 1),
        \mw, 0
    ), #[11, 11, 11, 11, 11, 12, 12],

    PmonoArtic(\sawpulse,
        \midinote, Pseq([81, 84, 83, 81, 78, 76, 81, 83], 1),
        \dur, Pseq(#[0.25], 8),
        \sustain, Pseq(#[0.2, 0.3, 0.3, 0.2, 0.3, 0.2, 0.3, 0.2], 1),
        \amp, Pseq(#[0.5, 1, 0.5, 0.5, 0.6, 0.5, 0.8, 0.5], 1),
        \mw, 0
    ), #[0, 9, 9, 11, 11, 12, 12, 12, 12, 12],

        // same as #1, 8va
    PmonoArtic(\sawpulse,
        \midinote, Pseq(([64, 66, 69, 71, 72, 73]+12), 1),
        \dur, Pseq(#[0.25], 6),
        \sustain, Pseq(#[0.3, 0.2, 0.2, 0.2, 0.3, 0.2], 1),
        \amp, Pseq(#[1, 0.5, 0.5, 0.5, 0.5, 0.5], 1),
        \mw, 0
    ), #[6, 6, 8, 9, 9, 9, 9, 10, 10, 10, 10, 13, 13, 13],

    PmonoArtic(\sawpulse,
        \midinote, Pseq([78, 81, 83, 78, 83, 84, 78, 84, 85], 1),
        \dur, Pseq(#[0.25, 0.25, 0.5, 0.25, 0.25, 0.5, 0.25, 0.25, 1.75], 1),
        \sustain, Pseq(#[0.2, 0.3, 0.2, 0.2, 0.3, 0.2, 0.2, 0.3, 1.75], 1),
        \amp, Pseq(#[0.4, 0.8, 0.5, 0.4, 0.8, 0.5, 0.4, 1, 0.8], 1),
        \mw, Pseq([Pseq([0], 8), 0.03], 1)
    ), #[8, 13, 13],

    PmonoArtic(\sawpulse,
        \midinote, Pseq([88, 84, 83, 81, 83, 81, 78, 76, 81, 83], 1),
        \dur, Pseq(#[0.25, 0.166, 0.167, 0.167,
                0.25, 0.25, 0.25, 0.25, 0.25, 0.25], 1),
        \sustain, Pseq(#[0.2, 0.2, 0.2, 0.15, 0.3, 0.2, 0.2, 0.2,
                0.3, 0.2], 1),
        \amp, Pseq(#[1, 1, 0.8, 0.8, 1, 0.8, 0.8, 0.8,
                1, 0.8], 1),
        \mw, 0
    ), #[10]
], inf)).play;
)

p.stop;


//Pattern Guide Cookbook 07: Rhythmic Variations
(
~kik = Penvir(~kikEnvir, Pn(Plazy({
    ~init.value;
    ~addNotes.value;
    Pbindf(
        Pbind(
            \instrument, \kik,
            \preamp, 0.4,
            \dur, 0.25,
            *(~pbindPairs.value(#[amp, decay2]))
        ),
        \freq, Pif(Pkey(\amp) > 0, 1, \rest)
    )
}), inf)).play(quant: 4);
)

(
SynthDef(\kik, {
	|basefreq=50, ratio=7, sweeptime=0.05, preamp=1, amp=1, decay1=0.3, decay1L=0.8, decay2=0.15, out|
	var fcurve = EnvGen.kr(Env([basefreq * ratio, basefreq], [sweeptime], \exp)),
	env = EnvGen.kr(Env([1, decay1L, 0], [decay1, decay2], -4), doneAction:Done.freeSelf),
	sig = SinOsc.ar(fcurve, 0.5pi, preamp).distort * env * amp;
	Out.ar(out, sig!2)
}).add;

SynthDef(\kraftySnr, {
	|amp=1, freq=2000, rq=3, decay=0.3, pan, out|
	var sig = PinkNoise.ar(amp),
	env = EnvGen.kr(Env.perc(0.01, decay), doneAction:Done.freeSelf);
	sig = BPF.ar(sig, freq, rq, env);
	Out.ar(out, Pan2.ar(sig, pan))
}).add;

~commonFuncs = (
	init: {
		if(~startTime.isNil){
			~startTime = thisThread.clock.beats
		};
	},
	pbindPairs: {
		|keys|
		var pairs = Array(keys.size * 2);
		keys.do({
			|key|
			if(key.envirGet.notNil){
				pairs.add(Pseq(key.envirGet, 1))
			};
		});
		pairs
	},
	getRestIndices: {
		|array|
		var result = Array(array.size);
		array.do({
			|item, i|
			if(item==0){result.add(i)}
		});
		result
	}
);
)

(
TempoClock.default.tempo = 104 / 60;

~kikEnvir = (
    parent: ~commonFuncs,
    baseAmp: #[1, 0, 0, 0,  0, 0, 0.7, 0,  0, 1, 0, 0,  0, 0, 0, 0] * 0.5,
    baseDecay: #[0.15, 0, 0, 0,  0, 0, 0.15, 0,  0, 0.15, 0, 0,  0, 0, 0, 0],
    addNotes: {
        var    beat16pos = (thisThread.clock.beats - ~startTime) % 16,
            available = ~getRestIndices.(~baseAmp);
        ~amp = ~baseAmp.copy;
        ~decay2 = ~baseDecay.copy;
            // if last bar of 4beat cycle, do busier fills
        if(beat16pos.inclusivelyBetween(12, 16)) {
            available.scramble[..rrand(5, 10)].do({ |index|
                    // crescendo
                ~amp[index] = index.linexp(0, 15, 0.2, 0.5);
                ~decay2[index] = 0.15;
            });
        } {
            available.scramble[..rrand(0, 2)].do({ |index|
                ~amp[index] = rrand(0.15, 0.3);
                ~decay2[index] = rrand(0.05, 0.1);
            });
        }
    }
);

~snrEnvir = (
    parent: ~commonFuncs,
    baseAmp: #[0, 0, 0, 0,  1, 0, 0, 0,  0, 0, 0, 0,  1, 0, 0, 0] * 1.5,
    baseDecay: #[0, 0, 0, 0,  0.7, 0, 0, 0,  0, 0, 0, 0,  0.4, 0, 0, 0],
    addNotes: {
        var    beat16pos = (thisThread.clock.beats - ~startTime) % 16,
            available = ~getRestIndices.(~baseAmp),
            choice;
        ~amp = ~baseAmp.copy;
        ~decay = ~baseDecay.copy;
        if(beat16pos.inclusivelyBetween(12, 16)) {
            available.scramble[..rrand(5, 9)].do({ |index|
                ~amp[index] = index.linexp(0, 15, 0.5, 1.8);
                ~decay[index] = rrand(0.2, 0.4);
            });
        } {
            available.scramble[..rrand(1, 3)].do({ |index|
                ~amp[index] = rrand(0.15, 0.3);
                ~decay[index] = rrand(0.2, 0.4);
            });
        }
    }
);

~hhEnvir = (
    parent: ~commonFuncs,
    baseAmp: 15 ! 16,
    baseDelta: 0.25 ! 16,
    addNotes: {
        var    beat16pos = (thisThread.clock.beats - ~startTime) % 16,
            available = (0..15),
            toAdd;
            // if last bar of 4beat cycle, do busier fills
        ~amp = ~baseAmp.copy;
        ~dur = ~baseDelta.copy;
        if(beat16pos.inclusivelyBetween(12, 16)) {
            toAdd = available.scramble[..rrand(2, 5)]
        } {
            toAdd = available.scramble[..rrand(0, 1)]
        };
        toAdd.do({ |index|
            ~amp[index] = ~doubleTimeAmps;
            ~dur[index] = ~doubleTimeDurs;
        });
    },
    doubleTimeAmps: Pseq(#[15, 10], 1),
    doubleTimeDurs: Pn(0.125, 2)
);


~kik = Penvir(~kikEnvir, Pn(Plazy({
    ~init.value;
    ~addNotes.value;
    Pbindf(
        Pbind(
            \instrument, \kik,
            \preamp, 0.4,
            \dur, 0.25,
            *(~pbindPairs.value(#[amp, decay2]))
        ),
            // default Event checks \freq --
            // if a symbol like \rest or even just \,
            // the event is a rest and no synth will be played
        \freq, Pif(Pkey(\amp) > 0, 1, \rest)
    )
}), inf)).play(quant: 4);

~snr = Penvir(~snrEnvir, Pn(Plazy({
    ~init.value;
    ~addNotes.value;
    Pbindf(
        Pbind(
            \instrument, \kraftySnr,
            \dur, 0.25,
            *(~pbindPairs.value(#[amp, decay]))
        ),
        \freq, Pif(Pkey(\amp) > 0, 5000, \rest)
    )
}), inf)).play(quant: 4);

~hh = Penvir(~hhEnvir, Pn(Plazy({
    ~init.value;
    ~addNotes.value;
    Pbindf(
        Pbind(
            \instrument, \kraftySnr,
            \rq, 0.06,
            \amp, 15,
            \decay, 0.04,
            *(~pbindPairs.value(#[amp, dur]))
        ),
        \freq, Pif(Pkey(\amp) > 0, 12000, \rest)
    )
}), inf)).play(quant: 4);
)

// stop just before barline
t = TempoClock.default;
t.schedAbs(t.nextTimeOnGrid(4, -0.001), {
    [~kik, ~snr, ~hh].do(_.stop);
});

//Pn

(
var a, b;
a = Pn(Pseq(#[1, 2, 3], 1), 4);
b = a.asStream;
16.do({ b.next.postln });
)

(
SynthDef(\help_sinegrain, {
	|out=0, freq=440, sustain=0.05|
	var env;
	env = EnvGen.kr(Env.perc(0.01, sustain, 0.2), doneAction:Done.freeSelf);
	Out.ar(out, SinOsc.ar(freq, 0, env))
}).add;
)

(
var a;
a = Pn(Pshuf([1, 2, 2, 3, 3, 3], 4)).asStream;
{
	loop {
		Synth(\help_sinegrain, [\freq, a.next * 600 + 300]);
		0.2.wait;
	}
}.fork;
)

















































































