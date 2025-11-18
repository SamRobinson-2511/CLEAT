(
MIDIClient.init;
MIDIIn.connectAll;
~k = MIDIOut(1);
~k.latency = 0;
CmdPeriod.add({(0..127).do{|n| ~k.noteOff(0, n)}});
s.options.memSize = 131072;
/*s.options.numWireBufs = 2048;*/
/*s.options.numControlBufs = 16384;*/
s.options.inDevice = "US-16x08";
s.options.outDevice = "US-16x08";
s.options.numInputBusChannels = 8;
s.options.numOutputBusChannels_(8);
s.reboot;
s.meter;
s.plotTree;
)

(
~k.noteOn(0, 36, 127);
~k.noteOn(0, 37, 127);
)

(
~k1 = Pbind(
	\type, \midi,
	\midicmd, \noteOn,
	\midiout, ~k,
	\chan, 0,
	\midinote, Pexprand(32, 33),
	\attack, 2,
	\amp, 127,
	\sustain, 10,
	\dur, 10,
	\stretch, 4*60/170
).play(quant: 4*60/60);

~k1_lfo2_rate = Pbind(
	\type, \midi,
	\midicmd, \control,
	\midiout, ~k,
	\chan, 0,
	\ctlNum, 12,
	\control, Pwrand([127, 64, 32, 0], [0.5, 0.10, 0.3, 0.1], inf),
	\dur, 0.15,
	\stretch, 4*60/60,
).play(quant: 4*60/60);

~k1_lfo2_depth = Pbind(
	\type, \midi,
	\midicmd, \control,
	\midiout, ~k,
	\chan, 0,
	\ctlNum, 13,
	\control, Pwrand([64, 32, 0], [0.5, 0.25, 0.25], inf),
	\dur, 0.15,
	\stretch, 60/60
).play(quant: 60/60);

~k1_env2_depth = Pbind(
	\type, \midi,
	\midicmd, \control,
	\midiout, ~k,
	\chan, 0,
	\ctlNum, 14,
	\control, Pwrand([127, 64, 32, 0], [0.9, 0.05, 0.5], inf),
	\dur, 0.15,
	\stretch, 60/60
).play(quant: 60/60);

~k1_atk = Pbind(
	\type, \midi,
	\midicmd, \control,
	\midiout, ~k,
	\chan, 0,
	\ctlNum, 73,
	\control, Pexprand(0, 127, inf),
	\dur, 10.00,
	\stretch, 60/60
).play(quant: 60/60);

~k1_rel = Pbind(
	\type, \midi,
	\midicmd, \control,
	\midiout, ~k,
	\chan, 0,
	\ctlNum, 71,
	\control, Pexprand(0, 127, inf),
	\dur, 10.00,
	\stretch, 60/60
).play(quant: 60/60);

~k1_dec = Pbind(
	\type, \midi,
	\midicmd, \control,
	\midiout, ~k,
	\chan, 0,
	\ctlNum, 72,
	\control, Pexprand(0, 127, inf),
	\dur, 100.00,
	\stretch, 60/60
).play(quant: 60/60);

)


(
SynthDef(\comb, {
	|out, in, time1=0.25, time2=0.5|
	var audio, efx;
	audio = SoundIn.ar(8, 1);
	efx = CombN.ar(audio, 0.5, [time1, time2], 10, 1, audio);
	Out.ar(out, efx);
}).add;
)

~k1_comb = Synth.after(1, \comb);

(
SynthDef(\k1, {
	|out = 0|
	var audio;
	audio = SoundIn.ar(8, 1);
	Out.ar(out, audio);
}).add;
)
s.meter;
(
Pbind(\instrument, \k1, \out, 20, \dur, Pseq([0.25, 0.5, 0.25], inf), \root, [-24, -17],
    \degree, Pseq([0, 3, 5, 7, 9, 11, 5, 1], inf), \pan, Pfunc({ 1.0.rand2 }),
    \cut, Pxrand([1000, 500, 2000, 300], inf), \rez, Pfunc({ 0.7.rand +0.3 }), \amp, 0.12).play;
)
