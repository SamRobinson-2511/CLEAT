//Nodes, Busses, Order of Execution
s.reboot;
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


s.reboot
//NodeProxy

a = NodeProxy.new.play; //play to hardware output
a.fadeTime = 2; //specifies crossfade
a.source = {SinOsc.ar([350, 351.3] / 0, 0.2)};
a.source = { Pulse.ar([350, 351.3] / 4, 0.4 ) * 0.2 };
a.source = Pbind(\dur, 0.03, \freq, Pbrown(0, 1, 0.1, inf).linexp(0, 1, 200, 350));


b = NodeProxy.new;
a.source = { Ringz.ar(b.ar, [350, 351.3] * 8, 0.2) * 4 };
b.source = { Impulse.ar([5, 7]/2,[0, 0.5])};

a.clear(3);
b.clear(3);

//Class Methods
//NodeProxy.new(server, rate, numChannels, inputs);

//new node proxy
a = NodeProxy(s, \audio, 4);
a.numChannels; //4
a.clear; //remove bus
a.numChannels; //nil

NodeProxy.defaultNumAudio;
NodeProxy.defaultNumAudio = 16;






