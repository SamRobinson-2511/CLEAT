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
			\fund, exprand(60, 300).round(45)
		],
		~sourceGroup
	);
};
)
~sourceGroup.set([\decay, 1.0, \dens, 55]);
~sourceGroup.free;
~fxGroup.free;



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




//Groups
s.boot;
g = Group.new; // add a group at the head of the default Server's default group
h = Group.new(g, \addAfter);
s.queryAllNodes;
g.free; h.free;


//Group.basicNew(server, nodeID)
g = Group.basicNew(s);
s.sendBundle(nil, g.newMsg);
s.queryAllNodes;
g.free;

//Examples
(
SynthDef(\help_group_moto_rev, {
	|out=0, freq=100, ffreq=120|
	var x;
	x = RLPF.ar(
		LFPulse.ar(
			SinOsc.kr(0.2, 0, 10, freq),
			[0, 0.1],
			0.1
		),
		ffreq, 0.1
	).clip2(0.4);
	Out.ar(out, x);
}).add;

SynthDef(\help_group_wah, {
	|out, rate=1.5, cfreq=1400, mfreq=1200, rq=0.1|
	var zin, zout, q;

	zin = In.ar(out, 2);
	cfreq = Lag3.kr(cfreq, 0.1);
	mfreq = Lag3.kr(mfreq, 0.1);
	q = Ramp.kr(rq, 0.1);
	zout = RLPF.ar(zin, LFNoise1.kr(rate, mfreq, cfreq), q, 10).distort * 0.15;

	//replace incoming bus with the effected version
	ReplaceOut.ar(out, zout);
}).add;
)


g = Group.new;

(
l = Array.fill(3, {
	Synth(\help_group_moto_rev, ["out", 0, "freq", exprand(10, 1200)], g, \addToHead);
});
)
g.set("ffreq", 300);
g.set("freq", 80);

(
r = Routine({
    inf.do({
        l.do({ |node|
            node.set("freq", rrand(10, 45));
			node.set("ffreq", rrand(100, 200));
            1.0.wait;
        });
    })
});

r.play;
)

g.group.inspect;
x = Synth.after(g, \help_group_wah, ["out", 0]);
g.dumpTree;
x.free;
l = nil;
g.query;

(
3.do({
	Synth(\help_group_moto_rev, ["out", 0, "freq", rrand(10, 1200)], g, \addToHead);
})
)
(
g.queryTree({
	|msg|
	var i = 1, tabs = 0, dumpFunc;
	("NODE TREE Group" + msg[1]).postln;
	if(msg[2] > 0, {
		dumpFunc = { |numChildren|
			tabs = tabs + 1;
			numChildren.do({
				i = i + 3;
				tabs.do({ "   ".post });
				msg[i].post;
				(" " ++ msg[i + 2]).postln;
				if(msg[i + 1] > 0, {
					dumpFunc.value(msg[i + 1]) });
			});
			tabs = tabs - 1;
		};
		dumpFunc.value(msg[2]);
	});
});
)
g.free;
g.query;

//Order of execution
//Groups
(
l = Bus.control(s, 1); //get a bus for the LFO, not relevant to order of execution
b = Bus.audio(s, 2); //assuming this is stereo this is to keep the src->fx chain separate
~synthGroup = Group.tail(s);
~fxGroup = Group.tail(s);


SynthDef(\order_of_ex_dist, {
	|bus, preGain, postGain|
	var sig;
	sig = In.ar(bus, 2);
	sig = (sig * preGain).distort;
	ReplaceOut.ar(bus, sig * postGain);
}).add;

SynthDef(\order_of_ex_pulse, {
	|freq, bus, ffreq, pan, lfobus|
	var sig, noteLen;
	noteLen = In.kr(lfobus, 1);
	sig = RLPF.ar(Pulse.ar(freq, 0.2, 0.5), ffreq, 0.3);
	Out.ar(bus, Pan2.ar(sig, pan) * EnvGen.kr(Env.perc(0.1, 1), timeScale: noteLen, doneAction: Done.freeSelf));
}).add;

SynthDef(\LFNoise1, {
	|freq, mul, add, bus|
	Out.kr(bus, LFNoise1.kr(freq, mul:mul, add:add));
}).add;

)
(
//Place LFO
~lfo = Synth.head(s, \LFNoise1, [\freq, rrand(3,20), \mul, 0.68, \add, 0.7, \bus, l]);

//then place effect
~dist = Synth.tail(~fxGroup, \order_of_ex_dist, [\bus, b, \preGain, 8, \postGain, 0.06]);

//tranfer the results to main out with level scaling, play at tail of s's default group
~xfer = { Out.ar(0, 0.25 * In.ar(b, 2))}.play(s, addAction: \addToTail);
)

//start routine
(
r = Routine({
	{
		Synth.tail(~synthGroup, \order_of_ex_pulse,
			[
				\freq, rrand(200, 800),
				\ffreq, rrand(1000, 1500),
				\pan, 1.0.rand2,
				\bus, b,
				\lfobus, l
			]);
		0.07.wait;
	}.loop;
}).play(SystemClock);
)
r.stop;

~dist.run(false);
~dist.run(true);

(
r.stop;
[~synthGroup, ~fxGroup, b, l, ~lfo, ~xfer].do({|x| x.free });
currentEnvironment.clear;
)


//Dictionary
d = Dictionary();
d.put(\a, 440);
d.keys;
d.put(\a, nil);
d.keys;


//Dictionary.newFrom(aCollection);
d = Dictionary.newFrom([\a, 1, \b, 2, \c, 4]);


//Dictionary from an array of associations
Dictionary.with(*[\a->1, \b->2, \c->3]);

//Dictionary from a single association
d = Dictionary[\a -> 1];

//Dictionary.add(anAssociation)
(
d = Dictionary.new;
d.add(\monkey -> 0).postln;
d.add(\robot -> 1).postln;
d.add(\monkey -> 2).postln;
)

//Routine
a = Routine.new({ 1.yield; 2.yield });
a.next.postln;
a.next.postln;
a.next.postln;

//function class provides its own shortcut method
a = r { 1.yield; 2.yield };
a.next;
a.next;
a.next;
a.reset;

(
r = Routine {
	|inval|
	inval.postln;
	inval = 123.yield;
	inval.postln;
}
)
r.value("hello routine");
r.value("goodbye routine");

(
r = Routine {
	|inval|
	inval.postln; //post value passed in when started
	5.do {
		|i|
		inval = (i + 10).yield;
		inval.postln; //post the value passed in when resumed
	}

}
)
(
5.do {
	r.value("hello routine").postln; //post the value that the Routine yields

}
)

//Routine.play(clock, quant);
(
r = Routine {
	199.yield;
	189.yield;
	200.idle(6);
	199.yield;
	189.yield;
};

fork {
	loop {
		r.value.postln;
		1.wait;
	}
}
)
r.stop;

//the value can also be a stream or a function
(
r = Routine {
	199.yield;
	189.yield;
	Routine { 100.do {
		|i|
		i.yield;
	}}.idle(100);
	199.yield;
	189.yield;
};

fork {
	loop {
		r.value.postln;
		1.wait;
	}
}
)
























