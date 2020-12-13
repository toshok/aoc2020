Module: day12
Synopsis: 
Author: 
Copyright: 

define constant *north* = 0;
define constant *east* = 1;
define constant *south* = 2;
define constant *west* = 3;


define function forward
    (pos-x :: <integer>,
     pos-y :: <integer>,
     amount :: <integer>,
     direction :: <integer>)

  select(direction)
    *north* => values(pos-x, pos-y - amount);
    *south* => values(pos-x, pos-y + amount);
    *east* => values(pos-x + amount, pos-y);
    *west* => values(pos-x - amount, pos-y);
    otherwise => values(pos-x, pos-y);
  end select
end function forward;

define function rotate
    (direction :: <integer>,
     amount :: <integer>)

  amount := floor/(amount, 90);

  modulo(direction + amount, 4);
end function rotate;

define function part1
    (directions :: <vector>)

  let pos-x = 0;
  let pos-y = 0;

  let direction = *east*;

  for(dir in directions)
    let action = dir[0];
    let amount = string-to-integer(copy-sequence(dir, start: 1));
    select(action)
      'N' => pos-y := pos-y - amount;
      'S' => pos-y := pos-y + amount;
      'E' => pos-x := pos-x + amount;
      'W' => pos-x := pos-x - amount;
      'L' => direction := rotate(direction, -amount);
      'R' => direction := rotate(direction, amount);
      'F' =>
        let (new-x, new-y) = forward(pos-x, pos-y, amount, direction);
        pos-x := new-x;
        pos-y := new-y;
    end select;
  end for;

  format-out("part1: %d\n", abs(pos-x) + abs(pos-y));
end function part1;

define function forward-waypoint
    (pos-x, pos-y, waypoint-x, waypoint-y, amount)

    values(pos-x + amount * waypoint-x, pos-y + amount * waypoint-y)
end function forward-waypoint;

define function rotate-waypoint
    (pos-x, pos-y, waypoint-x, waypoint-y, amount, cw)

  amount := floor/(amount, 90);

  if(cw)
    for(i from 1 to amount)
      let new-waypoint-x = waypoint-y;
      let new-waypoint-y = -waypoint-x;
      waypoint-x := new-waypoint-x;
      waypoint-y := new-waypoint-y;
    end for;
  else
    for(i from 1 to amount)
      let new-waypoint-x = -waypoint-y;
      let new-waypoint-y = waypoint-x;
      waypoint-x := new-waypoint-x;
      waypoint-y := new-waypoint-y;
    end for;
  end if;

  values(waypoint-x, waypoint-y)
end function rotate-waypoint;

define function part2
    (directions :: <vector>)

  let ship-x = 0;
  let ship-y = 0;
  let waypoint-x = 10;
  let waypoint-y = 1;

  let direction = *east*;

  block()
    for(dir in directions)
      let action = dir[0];
      let amount = string-to-integer(copy-sequence(dir, start: 1));
      select(action)
        'N' => waypoint-y := waypoint-y + amount;
        'S' => waypoint-y := waypoint-y - amount;
        'E' => waypoint-x := waypoint-x + amount;
        'W' => waypoint-x := waypoint-x - amount;
        'L' =>
          let (new-wp-x, new-wp-y) = rotate-waypoint(ship-x, ship-y, waypoint-x, waypoint-y, amount, #f);
          waypoint-x := new-wp-x;
          waypoint-y := new-wp-y;
        'R' =>
          let (new-wp-x, new-wp-y) = rotate-waypoint(ship-x, ship-y, waypoint-x, waypoint-y, amount, #t);
          waypoint-x := new-wp-x;
          waypoint-y := new-wp-y;
        'F' =>
          let (new-x, new-y) = forward-waypoint(ship-x, ship-y, waypoint-x, waypoint-y, amount);
          ship-x := new-x;
          ship-y := new-y;
      end select;
    end for;
  cleanup
    force-out();
  end block;

  format-out("part2: %d\n", abs(ship-x) + abs(ship-y));
end function part2;

define function main
    (name :: <string>, arguments :: <vector>)
  let lines = make(<vector>, of: <string>);

  until(stream-at-end?(*standard-input*))
    let line = read-line(*standard-input*);
    lines := add(lines, line);
  end until;

  part1(lines);
  part2(lines);

  exit-application(0);
end function main;

main(application-name(), application-arguments());
