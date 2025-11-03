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































































