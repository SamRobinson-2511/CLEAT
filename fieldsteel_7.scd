s.boot;
s.plotTree;

//Nodes, Busses, Order of Execution

(
SynthDef(\blip, {
	|out, fund=300, dens=2, decay=0.2|
	var freq, trig, sig;
	freq = LFNoise0.kr(3).exprange(fund, fund*4).round(fund);
	sig = SinOsc.ar(freq) * 0.25;
	trig = Dust.kr(dens);
	sig = sig * EnvGen.kr(Env.perc(0.01, decay), trig);
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
s.options.numOutputBusChannels = 8;
s.options.numInputBusChannels = 16;
s.reboot;
s.boot;
s.meter;

x = Synth(\blip, [\out, ~reverbBus]);
y = Synth(\reverb, [\in, ~reverbBus]);
x.free; y.free;

~reverbBus = Bus.audio(s, 1);
~reverbBus.index;


(
SynthDef(\blip, {
	|out|
	var freq, trig, sig;
	freq = LFNoise0.kr(3).exprange(300, 1200).round(300);
	sig = SinOsc.ar(freq) * 0.25;
	trig = Dust.kr(2);
	sig = sig * EnvGen.kr(Env.perc(0.01, 0.2), trig);
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

~reverbBus2 = Bus.audio(s, 2);
~reverbBus3 = Bus.audio(s, 1);

~reverbBus2.index;




(
x.free;
y.free;
)



//Order of Execution:
s.freeAll;
s.plotTree;


//1
x = Synth(\blip, [\out, ~reverbBus2], s);
y = Synth(\reverb, [\in, ~reverbBus2], s, \addToTail);

//2
x = Synth(\blip, [\out, ~reverbBus2]);
y = Synth(\reverb, [\in, ~reverbBus2], x, \addAfter);

//3
y = Synth(\reverb, [\in, ~reverbBus2]);
x = Synth.before(y, \blip, [\out, ~reverbBus2]);


//Group: collection of nodes in specific order

g = Group.new;
x.free;
y.free;
g.free;

//Target: synth or group on server








//Using Groups
(
~sourceGrp = Group.new;
~fxGrp = Group.after(~sourceGrp);
)
(
x = Synth(\blip, [\out, ~reverbBus2], ~sourceGrp);
y = Synth(\reverb, [\in, ~reverbBus2], ~fxGrp);
)
x.free; y.free;


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
	sig = FreeVerb.ar(sig, 0.5, 0.8, 0.2)!2;
	Out.ar(out, sig);
}).add;
)

(
8.do{
	Synth(
		\blip,
		[
			\out, ~reverbBus2,
			\fund, exprand(60, 300).round(30)
		],
		~sourceGrp;
	);
};

)
y = Synth(\reverb, [\in, ~reverbBus2], ~fxGrp);
y.free;

~sourceGrp.set(\decay, 0.03);
~sourceGrp.set(\dens, 1.25);
~sourceGrp.freeAll;








