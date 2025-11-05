s.boot;
Ndef(\a).play;
Ndef(\a).fadeTime = 1;

Ndef(\a, {SinOsc.ar([350, 351.3], 0, 0.2)});
Ndef(\a, { Pulse.ar([350, 351.3]/4, 0.4, 0.2)});
Ndef(\a, Pbind(\dur, 0.03, \freq, Pbrown(0, 1, 0.2, inf).linexp(0, 1, 200, 350)));
Ndef(\a, { Ringz.ar(Ndef.ar(\b), [350, 351.3] * 2, 0.4)});
Ndef(\b, { Impulse.ar([5, 7]/2, [0, 0.5], 0.15)});
Ndef.clear(3);

Ndef(\x);
Ndef(\x, {Dust.ar});

Ndef.all;
Ndef.dictFor(s);
Ndef(\x).proxyspace;

//Setting default parameters
//set default quant

Ndef(\x).proxyspace.quant = 1.0;
//can do clock, fadeTime, quant, reshaping, awake

Ndef(\sound).play;
Ndef(\sound).fadeTime = 1;
Ndef(\sound, { SinOsc.ar([600, 635] * 3, 0, SinOsc.kr(2 * 3).max(0) * 0.2)});

Ndef(\sound, Pbind(\dur, 0.17, \freq, Pfunc({rrand(300, 700)})));

Ndef(\lfo, { LFNoise1.kr(3, 400, 800)});
Ndef(\sound).map(\freq, Ndef(\lfo));