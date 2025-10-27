//https://www.youtube.com/watch?v=E8V2TIfT8Bc&list=PLPYzvS8A_rTYeUY_dHEhB_477LsybTvQ8


//2, 5, 8
(
s.options.sampleRate = 44100;
s.recChannels = 8;
s.options.numOutputBusChannels = 16;
s.boot;
s.meter;
s.makeGui;
)

{PinkNoise.ar([0.25, 0].reverse)}.play;

(
{
	var sig;
	sig = PinkNoise.ar(1)!16;
	Out.ar(0, sig);
}.play;
)

//play spatialization function
(
{
	var sig, env, panSpeed;
	env = EnvGen.kr(Env([0,1,0], [10, 10], [1, -1], doneAction: 2));
	panSpeed = EnvGen.kr(Env([0.001, 1.25, 0.001], [10, 10], [1, 1]));
	sig = PinkNoise.ar(0.4);
	sig = PanAz.ar(16, sig, LFSaw.kr(panSpeed), 1, mul, 0.5);
	sig = sig * env;
	Out.ar(0, sig);
}.play;
)

{ LFSaw.kr(2, [0, 1, 2], -1) }.plot(0.1)