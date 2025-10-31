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

