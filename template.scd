(
MIDIClient.init;
~k = MIDIOut(1);
~k.latency = 0;
CmdPeriod.add({(0..127).do{|n| ~k.noteOff(0, n)}});

s.options.inDevice = "US-16x08";
s.options.outDevice = "US-16x08";
s.options.numInputBusChannels = 16;
s.options.numOutputBusChannels_(16);
s.reboot;
s.meter;
s.plotTree;
)

(
SynthDef(\bpfsaw, {
	|atk=2, sus=0, rel=3, c1=1, c2=(-1), freq=500, cf=1500, rq=0.2, amp=1, out=0|
	var sig, env;
	env = EnvGen.kr(Env([0, 1, 1, 0], [atk, sus, rel], [c1, 0, c2]), doneAction: 2);
	sig = Saw.ar(freq);
	sig = BPF.ar(sig, cf, rq);
	sig = sig * env * amp;
	Out.ar(out, sig);
}).add;
)

(
[58, 65, 68, 73].midicps.do{
	|f|
	Synth(\bpfsaw,
		[
			\freq, f,
			\amp, 0.25,
			\cf, f * exprand(1, 12),
			\rq, exprand(0.01, 0.5)
		]
	);
};
)

(
4.do{
	Synth(
		\bpfsaw,
		[
			\freq, exprand(100, 1000),
			\amp, 0.25,
			\cf, exprand(200, 5000),
			\rq, exprand(0.01, 0.5)
		]

	)
}
)
//Scale
(
(1..12).choose.do{
	Synth(
		\bpfsaw,
		[
			\freq, (Scale.minor.degrees + 60).midicps.choose,
			\amp, 0.25,
			\cf, exprand(200, 5000),
			\rq, exprand(0.01, 0.5)
		]

	)
}
)


(
SynthDef(\bpfsaw0, {
	|atk=2, sus=0, rel=3, c1=1, c2=(-1), freq=500, cfmin=500, cfhzmin=0.1, cfhzmax=0.3, cfmax=2000, rqmin=0.1, rqmax=0.2, amp=1, lsf=200, ldb=0 out=0, detune=0.2, pan = 0|
	var sig, env;
	env = EnvGen.kr(Env([0, 1, 1, 0], [atk, sus, rel], [c1, 0, c2]), doneAction: 2);
	sig = Saw.ar(freq * {LFNoise1.kr(0.5, detune).midiratio}!8);
	sig = BPF.ar(
		sig,
		{LFNoise1.kr(
			LFNoise1.kr(4).exprange(cfhzmin, cfhzmax)
		).exprange(cfmin, cfmax)}!2,
		{LFNoise1.kr(0.1).exprange(rqmin, rqmax)}!8
	);
	/*sig = PanAz.ar(8, sig, LFNoise1.kr(0.5));*/
	sig = BLowShelf.ar(sig, lsf, 0.5, ldb);
	sig = Balance2.ar(sig[0], sig[1], pan);
	sig = sig * env * amp;
	Out.ar(out ! 2, sig);
}).add;
)

(
10.do{
	Synth(
		\bpfsaw0,
		[
			\freq, 50,
			\amp, 0.4,
			\cfmin, 50*2,
			\cfmax, 50*50,
			\rqmin, 0.005,
			\rqmax, 0.03,
			\pan, Pwhite(-1.0, 1.0)
		]
	)
}
)



(
SynthDef(\bpfsaw_8, {
	|atk=2, sus=0, rel=3, c1=1, c2=(-1), freq=500, cfmin=500, cfhzmin=0.1, cfhzmax=0.3, cfmax=2000, rqmin=0.1, rqmax=0.2, amp=1, lsf=200, ldb=0 out=0, detune=0.2, pan = 0, lfnoise=1|
	var sig, env;
	env = EnvGen.kr(Env([0, 1, 1, 0], [atk, sus, rel], [c1, 0, c2]), doneAction: 2);
	sig = Saw.ar(freq * LFNoise1.kr(0.5, detune).midiratio);
	sig = BPF.ar(
		sig,
		LFNoise1.kr(0.2).exprange(cfmin, cfmax),
		LFNoise1.kr(0.1).exprange(rqmin, rqmax)
	);
	sig = PanAz.ar(16, sig, LFNoise1.kr(lfnoise));
	/*sig = PanAz.ar(8, sig, LFSaw.kr(20));*/
	// sig = BLowShelf.ar(sig, lsf, 0.5, ldb);
	// sig = Balance2.ar(sig[0], sig[1], pan);
	sig = sig * env * amp;
	Out.ar(out, sig);
}).add;
)


(
12.do{
	Synth(
		\bpfsaw_8,
		[
			\freq, 20,
			\amp, 1,
			\detune, 2,
			\cfmin, 20*40,
			\cfmax, 20*50,
			\pan, 0,
			\atk, 5,
			\sus, 10,
			\rel, 30,
			\lfnoise, exprand(0.0125, 20.00).postln
		]
	)
}
)

//nested randomness
{SinOsc.ar(LFNoise0.kr(9).exprange(200, 800), 0, 0.2!2)}.play;










