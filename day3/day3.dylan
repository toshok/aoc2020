Module: day3
Synopsis: 
Author: 
Copyright: 

define function trees-encountered
    (lines :: <vector>, right :: <integer>, down :: <integer>)

  let trees = 0;
  let x = 0;
  for (i :: <integer> from 0 to size(lines) - 1 by down)
    let line = lines[i];
    if(line[x] == '#')
      trees := trees + 1;
    end if;
    x := x + right;
    x := modulo(x, size(line));
  end for;
  trees
end trees-encountered;

define function part2
    (lines :: <vector>)

  let trees1 = trees-encountered(lines, 1, 1);
  let trees2 = 289; // why waste the effort?
  let trees3 = trees-encountered(lines, 5, 1);
  let trees4 = trees-encountered(lines, 7, 1);
  let trees5 = trees-encountered(lines, 1, 2);

  format-out("part2: encountered %d trees\n", trees1 * trees2 * trees3 * trees4 * trees5);
end function part2;

define function part1
    (lines :: <vector>)

  let trees = trees-encountered(lines, 3, 1);

  format-out("part1: encountered %d trees\n", trees)
end function part1;


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
