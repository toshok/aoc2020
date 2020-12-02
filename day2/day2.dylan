Module: day2
Synopsis: 
Author: 
Copyright: 

define function password-valid-part1
    (min :: <integer>, max :: <integer>, letter :: <string>, password :: <string>)

  let count = count-substrings(password, letter);

  count >= min & count <= max;
end function password-valid-part1;

define function part1
    (lines :: <vector>)

  let valid-count = 0;

  for (i :: <integer> from 0 to size(lines) - 1)
    let line = lines[i];
    let strings = split(line, ":");
    let left = strip(strings[0]);

    let range-and-letter = split(left, " ");
    let range = split(range-and-letter[0], "-");
    let min = string-to-integer(range[0]);
    let max = string-to-integer(range[1]);

    let letter = range-and-letter[1];
    let password = strip(strings[1]);

    if(password-valid-part1(min, max, letter, password))
      valid-count := valid-count + 1
    end if;
  end for;

  format-out("part1: %d valid password\n", valid-count);
end function part1;

define function password-valid-part2
    (pos1 :: <integer>, pos2 :: <integer>, letter :: <character>, password :: <string>)

  let valid = password[pos1 - 1] == letter;
  if(password[pos2 - 1] == letter)
    valid := ~valid;
  end if;
  valid
end function password-valid-part2;


define function part2
    (lines :: <vector>)

  let valid-count = 0;

  for (i :: <integer> from 0 to size(lines) - 1)
    let line = lines[i];
    let strings = split(line, ":");
    let left = strip(strings[0]);

    let range-and-letter = split(left, " ");
    let range = split(range-and-letter[0], "-");
    let min = string-to-integer(range[0]);
    let max = string-to-integer(range[1]);

    let letter = range-and-letter[1];
    let password = strip(strings[1]);

    if(password-valid-part2(min, max, letter[0], password))
      valid-count := valid-count + 1
    end if;
  end for;

  format-out("part2: %d valid password\n", valid-count);
end function part2;


define function main
    (name :: <string>, arguments :: <vector>)

  let lines = make(<vector>, of: <string>);

  until(stream-at-end?(*standard-input*))
    let line = read-line(*standard-input*);
    lines := add(lines, line)
  end until;


  part1(lines);
  part2(lines);

  exit-application(0);
end function main;

main(application-name(), application-arguments());
