Module: day5
Synopsis: 
Author: 
Copyright: 

define function eval-path
    (path :: <string>, upper-char :: <character>, lower-char :: <character>)
  let lower-val :: <integer> = 0;
  let upper-val :: <integer> = (2 ^ size(path)) - 1;
  let middle :: <integer> = 0;

  for (i :: <integer> from 0 to size(path) - 1)
    if(path[i] = upper-char)
      // we're taking the upper half, so round the middle up
      middle := ceiling/(upper-val + lower-val, 2);
      lower-val := middle;
    else
      // we're taking the lower half, so round the middle down
      middle := floor/(upper-val + lower-val, 2);
      upper-val := middle;
    end if;
  end for;
  
  middle;
end function eval-path;

define function part1
    (paths :: <vector>)

  let highest-seat-id = 0;
  for (i :: <integer> from 0 to size(paths) - 1)
    let path = paths[i];

    let front-to-back-path = copy-sequence(path, start: 0, end: 7);
    let left-to-right-path = copy-sequence(path, start: 7);

    let ftb-val = eval-path(front-to-back-path, 'B', 'F');
    let ltr-val = eval-path(left-to-right-path, 'R', 'L');

    let seat-id = ftb-val * 8 + ltr-val;
    if(seat-id > highest-seat-id)
      highest-seat-id := seat-id;
    end if;
  end for;

  format-out("highest seat id = %d\n", highest-seat-id);
end function part1;

define function part2
    (paths :: <vector>)

  let seatmap = pad("", 128 * 8);

  let highest-seat-id = 0;
  for (i :: <integer> from 0 to size(paths) - 1)
    let path = paths[i];

    let front-to-back-path = copy-sequence(path, start: 0, end: 7);
    let left-to-right-path = copy-sequence(path, start: 7);

    let ftb-val = eval-path(front-to-back-path, 'B', 'F');
    let ltr-val = eval-path(left-to-right-path, 'R', 'L');

    let seat-id = ftb-val * 8 + ltr-val;
    seatmap[seat-id] := 'x';
  end for;

  format-out("seatmap = '%s'\n", seatmap);

  let seat-id-before-mine = find-substring(seatmap, "x x");
  format-out("my seat id = %d\n", seat-id-before-mine + 1);
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
