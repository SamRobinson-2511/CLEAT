s.boot;


Pdef(\x, Pbind(\note, Pbrown(0, 6, 0.1, inf)));
Pdef(\x).quant = 0;
Pbindf(Pdef(\x), \dur, 0.03).play;
Pbindf(Pdef(\x), \dur, 0.1, \ctranspose, 12.5).play;
Pbindf(Pdef(\x), \dur, 0.3, \ctranspose, 2).play;

//now change the definition
Pdef(\x, Pbind(\note, Pseq([0, 3, 5, 7, 9, 11], inf)));
Pdef(\x, Pbind(\freq, Pseq([1000, 1923, 245.2, 1718]/1.2 + 0.1, inf)));

//Class Methods
Pdef.all;


(
SynthDef(\Pdefhelp, {
	|out, freq, sustain=1, amp=1, pan|
	var env = EnvGen.kr(Env.perc(0.01, sustain), 1, doneAction: Done.freeSelf);
	Out.ar(out, Pan2.ar(SinOsc.ar(freq, 0.5pi, amp * env), pan));
}).add;
)

//Event pattern as argument

(
Pdef(\x, Pbind(
	\instrument, \Pdefhelp,
	\note, Pbrown(0, 6, 0.1, inf),
	\dur, 0.2
));
)

Pdef(\x);
Pdef(\x).play;
Pdef(\x).source.postcs;

//function as an argument, create a new pattern each time it is called
(
Pdef(\x, {Pbind(
	\note, Pseries(10.rand, 5.rand, 8.rand + 1),
	\dur, 1 / (8.rand+1))
})
)
Pn(Pdef(\x)).play;


//function is called in the incoming event as a current environment, so parameters can be passed
Pdef(\stut, { Pdup(~dup ? 1, ~pattern)})