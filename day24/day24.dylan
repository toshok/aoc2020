Module: day24
Synopsis: 
Author: 
Copyright: 

define function consume-direction(path :: <string>)
  if (path[0] = 'w' | path[0] = 'e')
    values(copy-sequence(path, start: 0, end: 1), copy-sequence(path, start: 1));
  else
    values(copy-sequence(path, start: 0, end: 2), copy-sequence(path, start: 2));
  end if;
end function consume-direction;

define function pos-to-key(x :: <integer>, y :: <integer>, z :: <integer>)
  // join(list(integer-to-string(x), integer-to-string(y), integer-to-string(z)), "|")
  format-to-string("%d|%d|%d", x, y, z);
end function pos-to-key;

define function key-to-pos(key :: <string>)
  let s = split(key, "|");
  values(string-to-integer(s[0]), string-to-integer(s[1]), string-to-integer(s[2]))
end function key-to-pos;


define function evaluate-path(path :: <string>)
  // start at the center tile
  let x = 0;
  let y = 0;
  let z = 0;

  while (size(path) > 0)
    let (dir, rest-path) = consume-direction(path);

    path := rest-path;
    case
      dir = "e"
        => x := x + 1;
           y := y - 1;
      dir = "se"
        => z := z + 1;
           y := y - 1;
      dir = "sw"
        => x := x - 1;
           z := z + 1;
      dir = "w"
        => x := x - 1;
           y := y + 1;
      dir = "nw"
        => z := z - 1;
           y := y + 1;
      dir = "ne"
        => x := x + 1;
           z := z - 1;
    end case;
  end while;
  values(x, y, z);
end function evaluate-path;

define function count-black-tiles
    (black-tiles :: <string-table>)
  let count = 0;
  for (key in black-tiles.key-sequence)
    if (black-tiles[key])
      count := count + 1;
    end if;
  end for;
  count
end function count-black-tiles;

define function part1
    (lines :: <vector>)

  let black-tiles = make(<string-table>);
  for (line in lines)
    let (x, y, z) = evaluate-path(line);
    let path-key = pos-to-key(x, y, z);
    black-tiles[path-key] := ~element(black-tiles, path-key, default: #f);
  end for;

  format-out("part1: %d\n", count-black-tiles(black-tiles));
  black-tiles
end function part1;

define constant neighbors = #[#[0, -1, 1], #[1, -1, 0], #[1, 0, -1], #[0, 1, -1], #[-1, 1, 0], #[-1, 0, 1]];

define function count-black-neighbors
    (black-tiles :: <string-table>, x, y, z)

  let count = 0;
  for (delta in neighbors)
    if ((element(black-tiles, pos-to-key(x + delta[0], y + delta[2], z + delta[1]), default: #f)))
      count := count + 1;
    end if;
  end for;
  
  count
end function count-black-neighbors;

define function run-game
    (black-tiles :: <string-table>)

  let min-x = 999;
  let min-y = 999;
  let min-z = 999;
  let max-x = -999;
  let max-y = -999;
  let max-z = -999;

  // figure out our bounds
  for (key in black-tiles.key-sequence)
    let (x, y, z) = key-to-pos(key);
    if (x < min-x)
      min-x := x;
    end if;
    if (x > max-x)
      max-x := x;
    end if;

    if (y < min-y)
      min-y := y;
    end if;
    if (y > max-y)
      max-y := y;
    end if;

    if (z < min-z)
      min-z := z;
    end if;
    if (z > max-z)
      max-z := z;
    end if;
  end for;

  let new-black-tiles = make(<string-table>);

  for (x from min-x - 1 to max-x + 1)
    for (y from min-y - 1 to max-y + 1)
      for (z from min-z - 1 to max-z + 1)
        let key = pos-to-key(x, y, z);
        let adjacent-black-tiles = count-black-neighbors(black-tiles, x, y, z);
        if (element(black-tiles, key, default: #f))
          if (adjacent-black-tiles = 0 | adjacent-black-tiles > 2)
          else
            new-black-tiles[key] := #t;
          end if;
        else    
          if (adjacent-black-tiles = 2)
            new-black-tiles[key] := #t;
          end if;
        end if;
      end for;
    end for;
  end for;

  new-black-tiles
end function run-game;

define function part2
    (black-tiles :: <string-table>)

  for (after-days from 1 to 100)
    black-tiles := run-game(black-tiles);
    format-out("Day %d: %d\n", after-days, count-black-tiles(black-tiles));
    force-out();
  end for;
end function part2;

define function main
    (name :: <string>, arguments :: <vector>)

  let lines = make(<vector>, of: <string>);
  until(stream-at-end?(*standard-input*))
    let line = read-line(*standard-input*);
    lines := add(lines, line);
  end until;

  let black-tiles = part1(lines);
  part2(black-tiles);

  exit-application(0);
end function main;

main(application-name(), application-arguments());
