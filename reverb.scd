//Reverb buss
//Fieldsteel: Busses, Groups, Server Architecture

(
SynthDef(\test0, {
	var sig;
	sig = PinkNoise.ar(0.2!2);
	//just provide number for output buss
	Out.ar(0, sig);
}).add;
)
s.options.numOutputBusChannels = 8;
s.reboot;
s.meter;

Synth(\test0);

//Buffer allocation
(
~s1 = Buffer.read(s, "/Users/robinson.will.sam/Desktop/taste_rubber_test/02-251013_2314.wav" );
~s2 = Buffer.read(s, "/Users/robinson.will.sam/Desktop/taste_rubber_test/02-251016_0143.wav");
)
(
~s1.numChannels =1;
~s1.numChannels;

~s2.numChannels =1;
~s2.numChannels;
)

(
SynthDef(\sampler, {
	|buf=0, atk, sus, rel, amp|
	var sig;
	sig = BufRd.ar(1!2, buf, Line.ar(0, BufFrames.ir(buf)-1, BufDur.ir(buf)));
	Out.ar(0, sig!2);
}).add;
)

(
Synth(\sampler, [buf: ~s2]);
)

s.meter;
