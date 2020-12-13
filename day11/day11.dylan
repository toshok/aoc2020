Module: day11
Synopsis: 
Author: 
Copyright: 

define constant *empty* = 'L';
define constant *occupied* = '#';
define constant *floor* = '.';

define function copy-grid
    (grid :: <vector>)
    let copy = copy-sequence(grid, start: 0);
    for (i :: <integer> from 0 to size(copy) - 1)
      copy[i] := copy-sequence(grid[i], start: 0);
    end for;
    copy
end function copy-grid;

define function dump-grid
    (grid :: <vector>)
  for (line in grid)
    format-out("%s\n", line);
  end for;
  format-out("\n");
end function dump-grid;

define function adjacent-occupied
    (grid :: <vector>, x :: <integer>, y :: <integer>)
  let adjacent = 0;

  // row above
  if(y > 0)
    if(x > 0 & grid[y - 1][x - 1] = *occupied*)
      adjacent := adjacent + 1;
    end if;
    if(grid[y - 1][x] = *occupied*)
      adjacent := adjacent + 1;
    end if;
    if(x < size(grid[y]) - 1 & grid[y - 1][x + 1] = *occupied*)
      adjacent := adjacent + 1;
    end if;
  end if;

  // // row of
  if(x > 0 & grid[y][x - 1] = *occupied*)
    adjacent := adjacent + 1;
  end if;
  if(x < size(grid[y]) - 1 & grid[y][x + 1] = *occupied*)
    adjacent := adjacent + 1;
  end if;

  // row below
  if(y < size(grid) - 1)
    if(x > 0 & grid[y + 1][x - 1] = *occupied*)
      adjacent := adjacent + 1;
    end if;
    if(grid[y + 1][x] = *occupied*)
      adjacent := adjacent + 1;
    end if;
    if(x < size(grid[y + 1]) - 1 & grid[y + 1][x + 1] = *occupied*)
      adjacent := adjacent + 1;
    end if;
  end if;

  adjacent;
end function adjacent-occupied;

define function check-for-occupied
    (grid :: <vector>, start-x :: <integer>, start-y :: <integer>, dx :: <integer>, dy :: <integer>)

   let x = start-x + dx;
   let y = start-y + dy;

   block(finished)
    while(x >= 0 & y >= 0 & y < size(grid) & x < size(grid[y]))
      if(grid[y][x] = *occupied*)
        // format-out("(%d,%d): found occupied for (dx = %d, dy = %d) at (%d,%d)\n", start-x, start-y, dx, dy, x, y);
        finished(#t)
      end if;
      if(grid[y][x] = *empty*)
        // format-out("(%d,%d): found empty for (dx = %d, dy = %d) at (%d %d)\n", start-x, start-y, dx, dy, x, y);
        finished(#f)
      end if;
      x := x + dx;
      y := y + dy;
    end while;
    // format-out("(%d,%d): fell off for (dx = %d, dy = %d)\n", start-x, start-y, dx, dy);
    #f
  end block
end function check-for-occupied;

define function adjacent-occupied2
    (grid :: <vector>, x :: <integer>, y :: <integer>)
  let adjacent = 0;

  // top left
  if(check-for-occupied(grid, x, y, -1, -1))
    adjacent := adjacent + 1;
  end if;

  // top center
  if(check-for-occupied(grid, x, y, 0, -1))
    adjacent := adjacent + 1;
  end if;

  // top right
  if(check-for-occupied(grid, x, y, 1, -1))
    adjacent := adjacent + 1;
  end if;

  // center left
  if(check-for-occupied(grid, x, y, -1, 0))
    adjacent := adjacent + 1;
  end if;

  // center right
  if(check-for-occupied(grid, x, y, 1, 0))
    adjacent := adjacent + 1;
  end if;

  // bottom left
  if(check-for-occupied(grid, x, y, -1, 1))
    adjacent := adjacent + 1;
  end if;

  // bottom center
  if(check-for-occupied(grid, x, y, 0, 1))
    adjacent := adjacent + 1;
  end if;

  // bottom right
  if(check-for-occupied(grid, x, y, 1, 1))
    adjacent := adjacent + 1;
  end if;

  adjacent;
end function adjacent-occupied2;

define function iterate-grid
    (grid :: <vector>, count-adjacent-occupied, occupied-to-empty-threshold)
    // advance the entire grid one timestep

  let changed = #f;
  let next = copy-grid(grid);

  for (y :: <integer> from 0 to size(grid) - 1)
    for (x :: <integer> from 0 to size(grid[y]) - 1)

      let occupied = count-adjacent-occupied(grid, x, y);

      // format-out("occupied for %d %d = %d\n", x, y, occupied);
      select(grid[y][x])
        *empty* =>
              if(occupied = 0)
                // format-out("switching %d %d to occupied\n", x, y);
                next[y][x] := *occupied*;
                changed := #t;
              end if;
        *occupied* =>
              if(occupied >= occupied-to-empty-threshold)
                // format-out("switching %d %d to empty\n", x, y);
                next[y][x] := *empty*;
                changed := #t;
              end if;
        *floor* => // it's floor, so we leave it
      end select;
    end for;
  end for;
  values(next, changed);
end function iterate-grid;

define function count-occupied
    (grid :: <vector>)

  let count = 0;
  for (y :: <integer> from 0 to size(grid) - 1)
    for (x :: <integer> from 0 to size(grid[y]) - 1)
      if(grid[y][x] = *occupied*)
        count := count + 1;
      end if;
    end for;
  end for;

  count;
end function count-occupied;

define function part1
    (grid :: <vector>)

  let working-grid = grid;
  let finished-grid = block(finished)
    while(#t)
      let (next-grid, changed) = iterate-grid(working-grid, adjacent-occupied, 4);
      if (~changed)
        finished(next-grid);
      end if;
      working-grid := next-grid;
    end while;
  end block;

  format-out("part1: occupied count = %d\n", count-occupied(finished-grid));
end function part1;

define function part2
    (grid :: <vector>)

  let working-grid = grid;
  let finished-grid = block(finished)
    while(#t)
      let (next-grid, changed) = iterate-grid(working-grid, adjacent-occupied2, 5);
      if (~changed)
        finished(next-grid);
      end if;
      working-grid := next-grid;
    end while;
  end block;

  format-out("part2: occupied count = %d\n", count-occupied(finished-grid));
end function part2;

define function main
    (name :: <string>, arguments :: <vector>)

  let grid = make(<vector>, of: <string>);

  until(stream-at-end?(*standard-input*))
    let line = read-line(*standard-input*);
    grid := add(grid, line);
  end until;

  part1(grid);
  part2(grid);

  exit-application(0);
end function main;

main(application-name(), application-arguments());
