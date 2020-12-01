
DAY=day1

EXE=_build/bin/${DAY}

${EXE}: day1.dylan library.dylan
	dylan-compiler -build day1.lid

check: ${EXE}
	${EXE} < day1.input

clean:
	rm -rf _build
