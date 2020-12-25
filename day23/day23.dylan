Module: day23
Synopsis: 
Author: 
Copyright: 

define class <cup> (<object>)
  slot label :: <integer>, init-keyword: label:;
  slot next :: false-or(<cup>) = #f;
  slot prev :: false-or(<cup>) = #f;
end class <cup>;

define function dump-cups(prefix :: <string>, starting-cup :: <cup>, current-cup :: <cup>)
  format-out("%s: ", prefix);
  let cup = starting-cup;
  block(break)
    while (#t)
      if (cup.label = current-cup.label)
        format-out("(%d) ", cup.label);
      else
        format-out("%d ", cup.label);
      end if;
      cup := cup.next;
      if (cup.label = starting-cup.label)
        break();
      end if;
    end while;
  end block;
  format-out("\n");
end function dump-cups;

define function pick-up-next-three(current-cup :: <cup>)
  let first-pick = current-cup.next;
  let last-pick = first-pick.next.next;

  first-pick.prev.next := last-pick.next;
  last-pick.next.prev := first-pick.prev;

  first-pick.prev := last-pick;
  last-pick.next := first-pick;

  first-pick;
end function pick-up-next-three;

define function pick-destination(current-cup :: <cup>, picked-up :: <cup>, highest-label :: <integer>)
  let excluded = make(<table>);

  let c = picked-up;
  for (p from 1 to 3)
    excluded[c.label] := #t;
    c := c.next;
  end for;

  let cup-to-find = block(found-cup)
    // first we try the below cups, iterating from cup-1 to 0 until we find one not in the hash
    for (c from current-cup.label - 1 to 1 by -1)
      if (~element(excluded, c, default: #f))
        found-cup(c);
      end if;
    end for;
    // next we loop from the highest-label down, same deal
    for (c from highest-label to current-cup.label + 1 by -1)
      if (~element(excluded, c, default: #f))
        found-cup(c);
      end if;
    end for;
  end block;

  cup-to-find
end function pick-destination;

define function compute-string
    (cups-by-label :: <vector>)

  let cup = cups-by-label[1].next;
  let str = "";
  while(cup.label ~= 1)
    str := concatenate(str, integer-to-string(cup.label));
    cup := cup.next;
  end while;
  str
end function compute-string;

define function run-game(cups-by-label :: <vector>, first-cup :: <cup>, current-cup :: <cup>, num-moves :: <integer>)
  for (move from 1 to num-moves)
    if (modulo(move, 100000) = 0)
      format-out("ran %d moves\n", move);
      force-out();
    end if;

    // format-out("\n-- move %d --\n", move);
    // dump-cups("cups", first-cup, current-cup);
    // force-out();

    let picked-up = pick-up-next-three(current-cup);
    // dump-cups("pick up", picked-up, current-cup);
    // force-out();

    let destination-label = pick-destination(current-cup, picked-up, last(cups-by-label).label);
    // format-out("destination: %d\n", destination-label);
    // force-out();
    
    // splice picked up cups after destination
    let before = cups-by-label[destination-label];
    let after = before.next;

    let first-pick = picked-up;
    let last-pick = picked-up.prev;

    before.next := first-pick;
    first-pick.prev := before;

    after.prev := last-pick;
    last-pick.next := after;

    current-cup := current-cup.next;
  end for;
end function run-game;

define function part1
    (cup-labels :: <vector>)

  let cups-by-label = make(<vector>, of: <cup>, size: size(cup-labels) + 1);
  // fill in one at index 0 (we'll never access it)
  cups-by-label[0] := make(<cup>, label: 0);

  let first-cup = #f;
  let last-cup = #f;
  for (cup-label in cup-labels)
    let cup = make(<cup>, label: cup-label);
    cups-by-label[cup-label] := cup;

    if (~first-cup)
      first-cup := cup;
    end if;
    if (last-cup)
      cup.prev := last-cup;
      last-cup.next := cup;
    end if;
    last-cup := cup;
  end for;

  first-cup.prev := last-cup;
  last-cup.next := first-cup;

  // assume the first current-cup is cup-labels[0]
  let current-cup = cups-by-label[cup-labels[0]];

  run-game(cups-by-label, first-cup, current-cup, 100);
  format-out("-- final --\n");
  dump-cups("cups", first-cup, first-cup);

  format-out("part1: %s\n", compute-string(cups-by-label));
end function part1;

define function part2
    (cup-labels :: <vector>)

  format-out("starting part2\n");
  force-out();

  let min-cup = 1;
  let max-cup = 1000000;

  let cups-by-label = make(<vector>, of: <cup>, size: 1000000 + 1);
  // fill in one at index 0 (we'll never access it)
  cups-by-label[0] := make(<cup>, label: 0);

  let first-cup = #f;
  let last-cup = #f;
  for (cup-label in cup-labels)
    let cup = make(<cup>, label: cup-label);
    cups-by-label[cup-label] := cup;

    if (~first-cup)
      first-cup := cup;
    end if;
    if (last-cup)
      cup.prev := last-cup;
      last-cup.next := cup;
    end if;
    last-cup := cup;
  end for;

  // now we insert a huge number of cups, ugh.
  for (i from size(cup-labels) + 1 to 1000000)
    if (modulo(i, 50000) = 0)
      format-out("added %d cups\n", i);
      force-out();
    end if;
    let cup = make(<cup>, label: i);
    cups-by-label[i] := cup;

    cup.prev := last-cup;
    last-cup.next := cup;

    last-cup := cup;
  end for;

  format-out("last cup label = %d\n", last-cup.label);
  first-cup.prev := last-cup;
  last-cup.next := first-cup;

  // assume the first current-cup is cup-labels[0]
  let current-cup = cups-by-label[cup-labels[0]];

  run-game(cups-by-label, first-cup, current-cup, 10000000);

  let first-cup = cups-by-label[1].next;
  let second-cup = first-cup.next;

  format-out("part2: %d * %d = %d\n", first-cup.label, second-cup.label, first-cup.label * second-cup.label);
end function part2;

define function main
    (name :: <string>, arguments :: <vector>)

  let lines = make(<vector>, of: <string>);
  until(stream-at-end?(*standard-input*))
    let line = read-line(*standard-input*);
    lines := add(lines, line);
  end until;


  let cups = make(<vector>);
  for (i from 0 below(size(lines[0])))
    cups := add(cups, string-to-integer(copy-sequence(lines[0], start: i, end: i + 1)));
  end for;

  part1(cups);
  part2(cups);

  exit-application(0);
end function main;

main(application-name(), application-arguments());
