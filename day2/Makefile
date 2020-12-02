
DAY=day2

EXE=_build/bin/${DAY}

${EXE}: day2.dylan library.dylan
	dylan-compiler -build day2.lid

check: ${EXE}
	${EXE} < day2.input

clean:
	rm -rf _build
