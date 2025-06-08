[6, 4, 0.5, 10, 7].do{"hello".postln};

(
[6, 4, 0.5, 10, 7].do{
	|i, count|
	[count,i.squared].postln;
};
)

(
x = Array.newClear(5);
[6, 4, 0.5, 10, 7].do{
	|i, count|
	x[count] = i.squared;
};
)
x;

(
z = [6, 4, 0.5, 10, 7].collect(_.squared);
)

[0,1,2,3,4].do{|i| i.postln};

5.do{|i| i.postln};


x = {VarSaw.ar(40!2, 0, 0.05)}.play;
x.free;

(
SynthDef(\iter, {
	|freq=40|
	var temp, sum, env;
	sum = 0;
	env = EnvGen.kr(
		Env.perc(0.01, 5, 1, -2),
		doneAction: 2
	);
	10.do{
		temp = VarSaw.ar(
			freq * {Rand(0.99, 1.02)}!2,
			{Rand(0.0, 1.0)}!2,
			{ExpRand(0.005, 0.05)}!2
		);
		sum = sum + temp;
	};
	sum = sum * 0.05 * env;
	Out.ar(0, sum);
}).add;
)

x = Synth(\iter);
Synth(\iter, [\freq, rrand(40, 400)]);

Synth(\iter, [\freq, rrand(40, 45).midicps]);

(
[53, 59, 63, 68].do{
	|midinote|
	Synth(\iter, [\freq, midinote.midicps])
}
)

(
SynthDef(\iter2, {
	|freq=200, dev=1.02|
	var temp, sum;
	sum = 0;
	10.do{
		|count|
		temp = SinOsc.ar(
			freq * (count + 1) * LFNoise1.kr({
				Rand(0.05, 0.2)}!2).range(dev.reciprocal, dev)
		);
		temp = temp * LFNoise1.kr({Rand(0.5, 8)}!2).exprange(0.01, 1);
		sum = sum + temp
	};
	sum = sum * 0.05;
	Out.ar(0, sum);
}).add;
)

x = Synth(\iter2,[\freq, rrand(50, 150)]);
x.set(\dev, 0.125);
x.free;

















