
Tdef(\x, { loop { 0.5.wait; "aaaaazzz".scramble.postln}}).play;
Tdef(\x, { loop { 0.125.wait; "aaxxx".scramble.postln}}).play;
Tdef(\x, { loop { 0.5.wait; (note: 14.rand).play;}})

(
Tdef(\x, { loop { 0.5.wait; "aaaaaaaaaaaaaazz".scramble.postln } }).play;
Tdef(\x, { loop { 0.125.wait; "aazz".scramble.postln } });
Tdef(\x, { loop { 0.5.wait; (note: 14.rand).play } });
Tdef(\x, { loop { 0.5.wait; (note: 14.rand + [0, 3, 6, 7].keep(4.rand)).play } });
)
Tdef(\x).stop;
Tdef(\x).play;
Tdef(\x).clear;