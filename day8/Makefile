
DAY=day8

EXE=_build/bin/${DAY}

${EXE}: ${DAY}.dylan library.dylan
	dylan-compiler -build ${DAY}.lid

check: ${EXE}
	${EXE} < ${DAY}.input

check-small: ${EXE}
	${EXE} < ${DAY}.input.small

clean:
	rm -rf _build
