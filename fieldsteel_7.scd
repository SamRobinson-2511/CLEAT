//Nodes, Busses, Order of Execution

(
SynthDef(\blip, {
	|out|
	var freq, trig, sig;
	freq = LFNoise0.kr(3).exprange(300, 1200).round(300);
	sig = SinOsc.ar(freq) * 0.25;
	trig = Dust.kr(20);
	sig = sig * EnvGen.kr(Env.perc(0.01, 0.2), trig);
	Out.ar(out, sig);
}).add;

SynthDef(\reverb, {
	|in, out=0|
	var sig;
	sig = In.ar(in, 1);
	sig = FreeVerb.ar(sig, 0.5, 0.8, 0.2)!2;
	Out.ar(out, sig);
}).add;
)

s.options.numAudioBusChannels;
s.options.numOutputBusChannels;
s.options.numInputBusChannels;


y = Synth(\reverb, [\in, 6]);
x = Synth(\blip, [\out, 6]);

~reverbBus = Bus.audio(s, 1);
~reverbBus.index;


y = Synth(\reverb, [\in, ~reverbBus]);
x = Synth(\blip, [\out, ~reverbBus]);
s.freeAll;


(
SynthDef(\blip, {
	|out, fund=300, dens=2, decay=0.2|
	var freq, trig, sig;
	freq = LFNoise0.kr(3).exprange(fund, fund*4).round(fund);
	sig = SinOsc.ar(freq) * 0.25;
	trig = Dust.kr(dens);
	sig = sig * EnvGen.kr(Env.perc(0.01, decay), trig);
	sig = Pan2.ar(sig, LFNoise1.kr(10));
	Out.ar(out, sig);
}).add;


SynthDef(\reverb, {
	|in, out=0|
	var sig;
	sig = In.ar(in, 2);
	sig = FreeVerb.ar(sig, 0.5, 0.8, 0.2);
	Out.ar(out, sig);
}).add;
)

y = Synth(\reverb, [\in, ~reverbBus2]);
x = Synth(\blip, [\out, ~reverbBus2]);

~reverbBus2 = Bus.audio(s, 2);
~reverbBus2.index;
s.freeAll;

//Order of Execution
//Default action is addToHead

(
x = Synth(\blip, [\out, ~reverbBus2]);
y = Synth(\reverb, [\in, ~reverbBus2], x, \addAfter);
)
x.free;
y.free;
s.freeAll;

x = Synth.before(y, \blip, [\out, ~reverbBus2]);

~sourceGroup = Group.new;
~fxGroup = Group.after(~sourceGroup);

(
x = Synth(\blip, [\out, ~reverbBus2], ~sourceGroup);
y = Synth(\reverb, [\in, ~reverbBus2], ~fxGroup);
)
x.free;

(
8.do{
	Synth(
		\blip,
		[
			\out, ~reverbBus2,
			\fund, exprand(60, 300).round(30)
		],
		~sourceGroup
	);
};
)
~sourceGroup.set([\decay, 0.1, \dens, 0.5]);
~sourceGroup.free;
~fxGroup.free;










