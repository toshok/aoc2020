Module: day20
Synopsis: 
Author: 
Copyright: 

define constant *north* = 0;
define constant *east* = 1;
define constant *south* = 2;
define constant *west* = 3;

define constant *corner* = 1;
define constant *edge* = 2;
define constant *middle* = 3;

define class <tile> (<object>)
  slot id :: <integer>, init-keyword: id:;
  slot contents :: <vector>, init-keyword: contents:; // vector of string.  the lines that make up the tile
  slot edges :: <vector>;

  slot edge-matches :: <vector>;

  slot flipped :: <boolean>, init-keyword: flipped:;
  slot rotations-cw :: <integer>, init-keyword: rotations-cw:; // 0-3
  slot position :: <integer>; // *corner*, *edge*, *middle* above
end class <tile>;
define method initialize (v :: <tile>, #key)
  next-method();
  v.edges := encode-edges(v);
  v.edge-matches := make(<vector>, of: <integer>, size: 4, fill: 0);
end method initialize;

define method encode-edges(t :: <tile>)
  let edges = make(<vector>, size: 4);

  edges[*north*] := t.contents[0];
  edges[*east*] := reduce(
    method(acc, l)
      concatenate(acc, copy-sequence(l, start: 9))
    end method,
    "",
    t.contents
  );
  edges[*south*] := t.contents[9];
  edges[*west*] := reduce(
    method(acc, l)
      concatenate(acc, copy-sequence(l, start: 0, end: 1))
    end method,
    "",
    t.contents
  );
  edges
end method encode-edges;

define function rotate-tile-contents-90-cw
    (contents :: <vector>)

    // format-out("before:\n");
    // for (line in contents)
    //   format-out(" - %s\n", line);
    // end for;

    let rotated-contents = make(<vector>, of: <string>);
    for (ri from 0 to size(contents) - 1)
      let new-row = make(<vector>);
      for (li from 0 to size(contents[0]) - 1)
        new-row := add(new-row,
                       copy-sequence(contents[size(contents) - 1 - li], start: ri, end: ri + 1));
      end for;

      rotated-contents := add(rotated-contents, join(new-row, ""));
    end for;

    // format-out("after:\n");
    // for (line in rotated-contents)
    //   format-out(" - %s\n", line);
    // end for;

    rotated-contents
end function rotate-tile-contents-90-cw;

define function flip-tile-contents
    (contents :: <vector>)
  let flipped-contents = make(<vector>, of: <string>);

  for (row in contents)
    flipped-contents := add(flipped-contents, reverse(row));
  end for;

  flipped-contents
end function flip-tile-contents;

define function split-into-tiles
    (lines :: <vector>)

    let tiles = make(<vector>);
    let orientable-tiles-by-id = make(<table>);
    let idx = 0;
    while (idx < size(lines) - 1)
      // assume we start on a tile line
      let s = split(lines[idx], " ");
      let tile-id = string-to-integer(s[1]);
      idx := idx + 1;
      // now we read the next 10 lines
      let tile-contents = make(<vector>, of: <string>);
      for (j from 0 to 9)
        tile-contents := add(tile-contents, lines[idx + j]);
      end for;

      idx := idx + 11;

      // format-out("generating orientable tiles for tile id %d\n", tile-id);
      // force-out();
      let orientable-tiles = make(<vector>, of: <tile>);

      let rotated-contents = tile-contents;
      let rotation = 0;
      let oriented-tiles = make(<vector>, of: <tile>);
      while (rotation < 4)
        let tile = make(<tile>, id: tile-id, contents: rotated-contents, flipped: #f, rotations-cw: rotation);
        orientable-tiles := add(orientable-tiles, tile);

        rotated-contents := rotate-tile-contents-90-cw(rotated-contents);
        rotation := rotation + 1;
      end while;

      let flipped-contents = flip-tile-contents(tile-contents);
      rotated-contents := flipped-contents;
      rotation := 0;
      while (rotation < 4)
        let tile = make(<tile>, id: tile-id, contents: rotated-contents, flipped: #t, rotations-cw: rotation);
        orientable-tiles := add(orientable-tiles, tile);

        rotated-contents := rotate-tile-contents-90-cw(rotated-contents);
        rotation := rotation + 1;
      end while;
      orientable-tiles-by-id[tile-id] := orientable-tiles;
      tiles := add(tiles, orientable-tiles);
    end while;

    values(tiles, orientable-tiles-by-id)
end function split-into-tiles;

define function part1
    (lines :: <vector>)

  let (tiles, orientable-tiles-by-id) = split-into-tiles(lines);
  let orientations = make(<vector>, of: <integer>, size: size(tiles), fill: *north*);

  let tile-row = make(<vector>, of: <tile>);
  let positions = make(<table>);

  let corner-tiles = make(<table>);
  let edge-tiles = make(<table>);
  let middle-tiles = make(<table>);

  for (source-tiles in tiles)
    for (source-tile in source-tiles)
      // format-out("checking tile %d, flipped %s, rotated cw %d times\n", source-tile.id, source-tile.flipped, source-tile.rotations-cw);
      // force-out();
      let match-count = 0;
      for (source-edge-i from 0 to size(source-tile.edges) - 1)
        let source-edge = source-tile.edges[source-edge-i];
        block(continue-source-edge)
          for (dest-tiles in tiles)
            for (dest-tile in dest-tiles)
              block(continue-dest)
                if (source-tile.id = dest-tile.id)
                  continue-dest();
                end if;

                for (dest-edge-i from 0 to size(dest-tile.edges) - 1)
                  let dest-edge = dest-tile.edges[dest-edge-i];
                  if (source-edge = dest-edge)
                    // format-out("  shares an edge with tile %d flipped %s, rotated cw %d times\n", dest-tile.id, dest-tile.flipped, dest-tile.rotations-cw);
                    // force-out();

                    match-count := match-count + 1;

                    source-tile.edge-matches[source-edge-i] := dest-tile.id;
                    dest-tile.edge-matches[dest-edge-i] := source-tile.id;

                    continue-source-edge();
                  end if;
                end for;
              end block;
            end for;
          end for;
        end block;
      end for;
      if (match-count = 2)
        corner-tiles[source-tile.id] := #t;
      elseif (match-count = 3)
        edge-tiles[source-tile.id] := #t;
      else
        middle-tiles[source-tile.id] := #t;
      end if;
    end for;
  end for;

  format-out("%d tiles that can be used in corner positions:\n", size(corner-tiles.key-sequence));
  let product = 1;
  for (id in corner-tiles.key-sequence)
    product := product * id;
  end for;

  format-out("part1: %d\n", product);
end function part1;

define function part2
    (lines :: <vector>)

  let (tiles, orientable-tiles-by-id) = split-into-tiles(lines);
  let orientations = make(<vector>, of: <integer>, size: size(tiles), fill: *north*);

  let tile-row = make(<vector>, of: <tile>);
  let positions = make(<table>);

  let corner-tiles = make(<table>);
  let edge-tiles = make(<table>);
  let middle-tiles = make(<table>);

  for (source-tiles in tiles)
    for (source-tile in source-tiles)
      // format-out("checking tile %d, flipped %s, rotated cw %d times\n", source-tile.id, source-tile.flipped, source-tile.rotations-cw);
      // force-out();
      let match-count = 0;
      for (source-edge-i from 0 to size(source-tile.edges) - 1)
        let source-edge = source-tile.edges[source-edge-i];
        block(continue-source-edge)
          for (dest-tiles in tiles)
            for (dest-tile in dest-tiles)
              block(continue-dest)
                if (source-tile.id = dest-tile.id)
                  continue-dest();
                end if;

                for (dest-edge-i from 0 to size(dest-tile.edges) - 1)
                  let dest-edge = dest-tile.edges[dest-edge-i];
                  if (source-edge = dest-edge)
                    // format-out("  shares an edge with tile %d flipped %s, rotated cw %d times\n", dest-tile.id, dest-tile.flipped, dest-tile.rotations-cw);
                    // force-out();

                    match-count := match-count + 1;

                    source-tile.edge-matches[source-edge-i] := dest-tile.id;
                    dest-tile.edge-matches[dest-edge-i] := source-tile.id;

                    continue-source-edge();
                  end if;
                end for;
              end block;
            end for;
          end for;
        end block;
      end for;
      if (match-count = 2)
        corner-tiles[source-tile.id] := #t;
      elseif (match-count = 3)
        edge-tiles[source-tile.id] := #t;
      else
        middle-tiles[source-tile.id] := #t;
      end if;
    end for;
  end for;

  format-out("%d tiles that can be used in corner positions:\n", size(corner-tiles.key-sequence));
  format-out("%d tiles that can be used in edge positions:\n", size(edge-tiles.key-sequence));
  format-out("%d tiles that can be used in middle positions:\n", size(middle-tiles.key-sequence));
  // let's try and figure out one entire edge just for kicks

 // pick a corner and try to solve the puzzle for it, for all its orientations that have a match to the eastern side
  let corner-id = corner-tiles.key-sequence[0];
  let solution = block(success)
    format-out("using tile %d, there are %d possible orientations\n", corner-id, size(orientable-tiles-by-id[corner-id]));
    format-out("  but only %d that have both east and south matches\n",
      reduce(method (acc, t)
        if (t.edge-matches[*east*] > 0 & t.edge-matches[*south*]> 0)
          acc + 1
        else
          acc
        end if
      end method,
      0,
      orientable-tiles-by-id[corner-id])
    );
    force-out();
    for (t in orientable-tiles-by-id[corner-id])
      block(continue)
        if (t.edge-matches[*east*] > 0 & t.edge-matches[*south*]> 0)
          format-out("starting attempt from corner tile %d, flipped %s, rotations %d\n", t.id, t.flipped, t.rotations-cw);
          force-out();
          let rv = attempt-solve-from(t, orientable-tiles-by-id, corner-tiles, edge-tiles, middle-tiles, continue);
          success(rv);
        end if;
      end block;
    end for;
  end block;

  format-out("done!!!\n");
  dump-puzzle(solution);

  let image-with-seamonsters-rendered = block(finished)
    let image = finalize-puzzle(solution);
    let rotated-image = image;
    for (rotation from 0 to 3)
      rotated-image := rotate-image(rotated-image);
      let (seamonster-count, rendered-image) = count-and-render-seamonsters(rotated-image, #f);
      if (seamonster-count > 0)
        format-out("1 found %d after %d rotations\n", seamonster-count, rotation + 1);
        finished(rendered-image);
      end if;
    end for;

    rotated-image := hflip-image(image);
    for (rotation from 0 to 3)
      rotated-image := rotate-image(rotated-image);
      let (seamonster-count, rendered-image) = count-and-render-seamonsters(rotated-image, #f);
      if (seamonster-count > 0)
        format-out("2 found %d\n", seamonster-count);
        finished(rendered-image);
      end if;
    end for;
  end block;

  format-out("puzzle with seamonsters rendered:\n");
  dump-image(image-with-seamonsters-rendered);

  format-out("part2: %d\n", count-hashes(image-with-seamonsters-rendered));
end function part2;

define function count-hashes(image)
  let width = dimension(image, 0);
  let height = dimension(image, 1);

  let count = 0;
  for (y from 0 to height - 1)
    for (x from 0 to width - 1)
      if (image[x, y] = '#')
        count := count + 1;
      end if;
    end for;
  end for;
  count
end function count-hashes;

define function dump-image(image)
  let width = dimension(image, 0);
  let height = dimension(image, 1);

  for (y from 0 to height - 1)
    for (x from 0 to width - 1)
      format-out("%c", image[x, y]);
    end for;
    format-out("\n");
  end for;
  format-out("\n");
end function dump-image;

define function rotate-image(image)
  let return-image = make(<array>, dimensions: dimensions(image), fill: '.');

  let width = dimension(image, 0);
  let height = dimension(image, 1);

  for (y from 0 to height - 1)
    for (x from 0 to width - 1)
      return-image[x,y] := image[y, height - 1 - x];
    end for;
  end for;

  return-image;
end function rotate-image;

define function hflip-image(image)
  let return-image = make(<array>, dimensions: dimensions(image), fill: '.');

  let width = dimension(image, 0);
  let height = dimension(image, 1);

  for (y from 0 to height - 1)
    for (x from 0 to width - 1)
      return-image[x,y] := image[width - 1 - x, y];
    end for;
  end for;

  return-image;
end function hflip-image;

define function count-and-render-seamonsters(image, debugf)
  let return-image = make(<array>, dimensions: dimensions(image), fill: '.');

  let width = dimension(return-image, 0);
  let height = dimension(return-image, 1);

  // copy the original image
  for (y from 0 to height - 1)
    for (x from 0 to width - 1)
      return-image[x,y] := image[x, y];
    end for;
  end for;

  let count = 0;
  for (y from 0 to height - 3 - 1)
    for (x from 0 to width - 20 - 1)
      if (debugf)
        format-out("checking for monster at %dx%d: ", x, y)
      end if;
      if (check-monster-at(x, y, image))
        if (debugf)
          format-out("found one!\n");
        end if;
        render-monster-at(x, y, return-image);
        count := count + 1;
      else
        if (debugf)
          format-out("nada\n");
        end if;
      end if;
    end for;
  end for;
  values(count, return-image)
end function count-and-render-seamonsters;

define function check-monster-at(x, y, image)
  //             1111111111
  //   01234567890123456789
  // 0                   # 
  // 1 #    ##    ##    ###
  // 2  #  #  #  #  #  #   

  let is-hash = method(c)
    c = '#'
  end method;

  // row 0
  is-hash(image[x + 18, y + 0]) &
  // row 1
  is-hash(image[x + 0, y + 1]) &
  is-hash(image[x + 5, y + 1]) &
  is-hash(image[x + 6, y + 1]) &
  is-hash(image[x + 11, y + 1]) &
  is-hash(image[x + 12, y + 1]) &
  is-hash(image[x + 17, y + 1]) &
  is-hash(image[x + 18, y + 1]) &
  is-hash(image[x + 19, y + 1]) &
  // row 2
  is-hash(image[x + 1, y + 2]) &
  is-hash(image[x + 4, y + 2]) &
  is-hash(image[x + 7, y + 2]) &
  is-hash(image[x + 10, y + 2]) &
  is-hash(image[x + 13, y + 2]) &
  is-hash(image[x + 16, y + 2])
end function check-monster-at;

define function render-monster-at(x, y, image)

  //             1111111111
  //   01234567890123456789
  // 0                   # 
  // 1 #    ##    ##    ###
  // 2  #  #  #  #  #  #   

  // row 0
  image[x + 18, y + 0] := 'O';
  // row 1
  image[x + 0, y + 1] := 'O';
  image[x + 5, y + 1] := 'O';
  image[x + 6, y + 1] := 'O';
  image[x + 11, y + 1] := 'O';
  image[x + 12, y + 1] := 'O';
  image[x + 17, y + 1] := 'O';
  image[x + 18, y + 1] := 'O';
  image[x + 19, y + 1] := 'O';
  // row 2
  image[x + 1, y + 2] := 'O';
  image[x + 4, y + 2] := 'O';
  image[x + 7, y + 2] := 'O';
  image[x + 10, y + 2] := 'O';
  image[x + 13, y + 2] := 'O';
  image[x + 16, y + 2] := 'O';
end function render-monster-at;

define function finalize-puzzle(solution :: <vector>)
  let tile-dimension = size(solution[0][0].contents[0]);
  let tile-count = size(solution[0]);

  let puzzle-dimension = (tile-dimension - 2) * tile-count;
  format-out("tile-dimension = %d\n", tile-dimension);
  format-out("puzzle-dimension = %d\n", puzzle-dimension);
  force-out();

  let puzzle-image = make(<array>, dimensions: list(puzzle-dimension, puzzle-dimension), fill: '.');

  for (tile-row-i from 0 to size(solution) - 1)
    for (tile-col-i from 0 to size(solution[tile-row-i]) - 1)
      let tile = solution[tile-row-i][tile-col-i];

      let tile-start-x = tile-col-i * (tile-dimension - 2);
      let tile-y = tile-row-i * (tile-dimension - 2);
      let tile-x = tile-start-x;

      format-out("putting tile at %d,%d\n", tile-x, tile-y);
      force-out();
      for (content-row in copy-sequence(tile.contents, start: 1, end: size(tile.contents) - 1))
        for (content-char in copy-sequence(content-row, start: 1, end: size(content-row) - 1))
          puzzle-image[tile-x, tile-y] := content-char;
          tile-x := tile-x + 1;
        end for;
        tile-y := tile-y + 1;
        tile-x := tile-start-x;
      end for;
    end for;
  end for;

  puzzle-image
end function finalize-puzzle;

define function attempt-solve-from
    (corner-tile, orientable-tiles-by-id, corner-tiles, edge-tiles, middle-tiles, failed)
  let dimension = floor/(size(edge-tiles.key-sequence), 4) + 2;

  let puzzle-rows = make(<vector>);
  let puzzle-row = make(<vector>);

  let seen-tiles = make(<table>);

  seen-tiles[corner-tile.id] := #t;
  let last-tile = corner-tile;
  // format-out("tile %d flipped %s, rotated %d times\n", corner-tile.id, corner-tile.flipped, corner-tile.rotations-cw);
  // force-out();
  puzzle-row := add(puzzle-row, last-tile);

  // first row is special, in that we only have a east-west constraint
  let num-edge-tiles = floor/(size(edge-tiles.key-sequence), 4);
  for (i from 1 to dimension - 2)
    let looking-for = last-tile.edges[*east*];
    last-tile := find-tile-with-western-edge(edge-tiles, orientable-tiles-by-id, seen-tiles, looking-for);
    if (last-tile = #f)
      format-out("couldn't find match for western side = %s\n", looking-for);
      force-out();
      failed();
    end if;
    puzzle-row := add(puzzle-row, last-tile);
  end for;

  // now let's find the final corner piece
  let looking-for = last-tile.edges[*east*];
  last-tile := find-tile-with-western-edge(corner-tiles, orientable-tiles-by-id, seen-tiles, looking-for);
  if (last-tile = #f)
    format-out("couldn't find match for western side = %s\n", looking-for);
    force-out();
    failed();
  end if;
  puzzle-row := add(puzzle-row, last-tile);

  puzzle-rows := add(puzzle-rows, puzzle-row);
  
  dump-puzzle(puzzle-rows);

  for (row from 1 to dimension - 2)
    format-out("doing row %d\n", row);
    force-out();

    puzzle-rows := add(puzzle-rows, build-row(edge-tiles, middle-tiles, edge-tiles, orientable-tiles-by-id, seen-tiles, dimension, last(puzzle-rows), failed));
  end for;

  puzzle-rows := add(puzzle-rows, build-row(corner-tiles, edge-tiles, corner-tiles, orientable-tiles-by-id, seen-tiles, dimension, last(puzzle-rows), failed));

  puzzle-rows
end function attempt-solve-from;

define function dump-puzzle(rows)
  for (row in rows)
    for (tile in row)
      format-out("%d ", tile.id)
    end for;
    format-out("\n");
  end for;

  for (row in rows)
    for (content-row from 0 to 9)
      for (tile in row)
        format-out("%s ", tile.contents[content-row]);
      end for;
      format-out("\n");
    end for;
    format-out("\n");
    force-out();
  end for;
end function dump-puzzle;

define function build-row(first-column-tiles, middle-column-tiles, last-column-tiles, orientable-tiles-by-id, seen-tiles, dimension, last-puzzle-row, failed)
    let puzzle-row = make(<vector>);
    // build north/south constraints from previous row
    let north-edges = map(
      method (tile)
        tile.edges[*south*]
      end method,
      last-puzzle-row);

    print-object(north-edges, *standard-output*);
    format-out("\n");
    force-out();
    let last-tile = find-tile-with-northern-edge(first-column-tiles, orientable-tiles-by-id, seen-tiles, north-edges[0]);
    if (last-tile = #f)
      format-out("couldn't find match for northern side = %s\n", north-edges[0]);
      force-out();
      failed();
    end if;
    puzzle-row := add(puzzle-row, last-tile);

    for (i from 1 to dimension - 2)
      last-tile := find-tile-with-western-and-northern-edges(middle-column-tiles, orientable-tiles-by-id, seen-tiles, last-tile.edges[*east*], north-edges[i]);
      if (last-tile = #f)
        format-out("couldn't find match for northern side = %s\n", north-edges[i]);
        force-out();
        failed();
      end if;
      puzzle-row := add(puzzle-row, last-tile);
    end for;

    last-tile := find-tile-with-western-and-northern-edges(last-column-tiles, orientable-tiles-by-id, seen-tiles, last-tile.edges[*east*], last(north-edges));
    if (last-tile = #f)
      format-out("couldn't find match for northern side = %s\n", last(north-edges));
      force-out();
      failed();
    end if;
    puzzle-row := add(puzzle-row, last-tile);

    puzzle-row
end function build-row;

define function find-tile-with-western-edge
    (tiles :: <table>, orientable-tiles-by-id :: <table>, seen-tiles :: <table>, western-edge :: <string>)
  let rv = block(found)
    for (id in tiles.key-sequence)
      block(continue)
        if (element(seen-tiles, id, default: #f))
          continue();
        end if;
        for (tile in orientable-tiles-by-id[id])
          if (tile.edges[*west*] = western-edge)
            // format-out("tile %d flipped %s rotated %d times\n", id, tile.flipped, tile.rotations-cw);
            // force-out();
            seen-tiles[id] := #t;
            found(tile)
          end if;
        end for;
      end block;
    end for;
  end block;
  rv
end function find-tile-with-western-edge;

define function find-tile-with-northern-edge
    (tiles :: <table>, orientable-tiles-by-id :: <table>, seen-tiles :: <table>, northern-edge :: <string>)
  block(found)
    for (id in tiles.key-sequence)
      block(continue)
        if (element(seen-tiles, id, default: #f))
          continue();
        end if;
        for (tile in orientable-tiles-by-id[id])
          if (tile.edges[*north*] = northern-edge)
            format-out("found tile with northern edge %d flipped %s rotated %d times\n", id, tile.flipped, tile.rotations-cw);
            force-out();
            seen-tiles[id] := #t;
            found(tile)
          end if;
        end for;
      end block;
    end for;
  end block;
end function find-tile-with-northern-edge;

define function find-tile-with-western-and-northern-edges
    (tiles :: <table>, orientable-tiles-by-id :: <table>, seen-tiles :: <table>, western-edge :: <string>, northern-edge :: <string>)
  let rv = block(found)
    for (id in tiles.key-sequence)
      block(continue)
        if (element(seen-tiles, id, default: #f))
          continue();
        end if;
        for (tile in orientable-tiles-by-id[id])
          if (tile.edges[*west*] = western-edge & tile.edges[*north*] = northern-edge)
            format-out("tile %d flipped %s rotated %d times\n", id, tile.flipped, tile.rotations-cw);
            force-out();
            seen-tiles[id] := #t;
            found(tile)
          end if;
        end for;
      end block;
    end for;
  end block;
  rv
end function find-tile-with-western-and-northern-edges;

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
