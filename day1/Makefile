
_build/bin/day1: day1.dylan library.dylan
	dylan-compiler -build day1.lid

check: _build/bin/day1
	_build/bin/day1 < day1.input
