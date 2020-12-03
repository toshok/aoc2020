
DAY=day2

EXE=_build/bin/${DAY}

${EXE}: ${DAY}.dylan library.dylan
	dylan-compiler -build ${DAY}.lid

check: ${EXE}
	${EXE} < ${DAY}.input

clean:
	rm -rf _build
