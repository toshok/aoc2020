Module: day17
Synopsis: 
Author: 
Copyright: 



define function key-to-position
    (key :: <string>)
  let split-up = map(string-to-integer, split(key, "|"));
  values(split-up[0], split-up[1], split-up[2], split-up[3])
end function key-to-position;

define function position-to-key
    (x :: <integer>, y :: <integer>, z :: <integer>, w :: <integer>)
  join (list(integer-to-string(x), integer-to-string(y), integer-to-string(z), integer-to-string(w)), "|")
end function position-to-key;

define function get-bounds
    (active :: <string-table>)

  let min-x = 99999;  
  let max-x = -99999;  
  let min-y = 99999;  
  let max-y = -99999;  
  let min-z = 99999;  
  let max-z = -99999;
  let min-w = 99999;  
  let max-w = -99999;

  for (key in active.key-sequence)
    let (x, y, z, w) = key-to-position(key);
    min-x := min(x, min-x);
    max-x := max(x, max-x);
    min-y := min(y, min-y);
    max-y := max(y, max-y);
    min-z := min(z, min-z);
    max-z := max(z, max-z);
    min-w := min(w, min-w);
    max-w := max(w, max-w);
  end for;

  // expand bounds by 1 in every direction to make sure we deal with border cells
  values(min-x - 1, max-x + 1,
         min-y - 1, max-y + 1,
         min-z - 1, max-z + 1,
         min-w - 1, max-w + 1)
end function get-bounds;

define function count-active-neighbors(x, y, z, w, active)
  let count = 0;
  for (cx from x - 1 to x + 1)
    for (cy from y - 1 to y + 1)
      for (cz from z - 1 to z + 1)
        for (cw from w - 1 to w + 1)
          if ((cx ~= x | cy ~= y | cz ~= z | cw ~= w) & element(active, position-to-key(cx, cy, cz, cw), default: #f))
            count := count + 1;
          end if;
        end for;
      end for;
    end for;
  end for;

  count
end function count-active-neighbors;

define function part1
  (active :: <string-table>)

  for (i from 1 to 6)
    let (min-x, max-x, min-y, max-y, min-z, max-z, min-w, max-w) = get-bounds(active);

    let new-active = make(<string-table>);
    for (x from min-x to max-x)
      for (y from min-y to max-y)
        for (z from min-z to max-z)
          for (w from min-w to max-w)
            let cube-active = element(active, position-to-key(x, y, z, w), default: #f);
            let active-neighbors = count-active-neighbors(x, y, z, w, active);
            if (cube-active & (active-neighbors ~= 3 & active-neighbors ~= 2))
              cube-active := #f;
            end if;
            if (~cube-active & active-neighbors = 3)
              cube-active := #t;
            end if;
            if (cube-active)
              new-active[position-to-key(x, y, z, w)] := #t;
            end if;
          end for;
        end for;
      end for;
    end for;
    active := new-active;
  end for;

  format-out("part1: %d\n", size(active));
end function part1;


define function dump-slice(active, z, w)
  let (min-x, max-x, min-y, max-y, min-z, max-z, min-w, max-w) = get-bounds(active);

  for (y from min-y to max-y)
    for (x from min-x to max-x)
      let cube-active = element(active, position-to-key(x, y, z, w), default: #f);
      if (cube-active)
        format-out("#");
      else
        format-out(".");
      end if;
    end for;
    format-out("\n");
  end for;
end function dump-slice;

define function main
    (name :: <string>, arguments :: <vector>)

  let lines = make(<vector>, of: <string>);
  until(stream-at-end?(*standard-input*))
    let line = read-line(*standard-input*);
    lines := add(lines, line);
  end until;

  let x-size = size(lines[0]);
  let y-size = size(lines);

  let active = make(<string-table>);
  for(y :: <integer> from 0 to y-size - 1)
    for (x :: <integer> from 0 to size(lines[y]) - 1)
      if (lines[y][x] = '#')
        active[position-to-key(x, y, 0, 0)] := #t;
      end if;
    end for;
  end for;

  dump-slice(active, 0, 0);
  part1(active);

end function main;

main(application-name(), application-arguments());
