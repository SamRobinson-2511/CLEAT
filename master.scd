a = Array2D.new(4, 4);
a[2,2] = 1;
a.postln;

a = Array2D.fromArray(4,4, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]);
a.colsDo(_.postln);

~cleatWhole = Array2D.fromArray(4,4, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]);
~cleatWhole;

s.options.numOutputBusChannels = 16;
s.reboot;
s.meter;

~cleatWhole;

~cleatWhole0 = Array.newClear(16);

(
~cleatWhole.do({
	|i|
	Out.ar(s, i);
})
)

