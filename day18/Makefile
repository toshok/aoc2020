
DAY=day18

EXE=_build/bin/${DAY}

${EXE}: ${DAY}.dylan library.dylan
	dylan-compiler -build ${DAY}.lid

check: ${EXE}
	${EXE} < ${DAY}.input

check-small: ${EXE}
	${EXE} < ${DAY}.input.small

check-small2: ${EXE}
	${EXE} < ${DAY}.input.small.2
	
clean:
	rm -rf _build
