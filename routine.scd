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

