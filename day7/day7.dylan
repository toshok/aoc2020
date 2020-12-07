Module: day7
Synopsis: 
Author: 
Copyright: 

define class colored-bag (<object>)
  slot color :: <string>, required-init-keyword: color:;

  slot contains :: <vector>, required-init-keyword: contains:; // of counted-colored-bag
  slot contained-in :: <vector>, required-init-keyword: contained-in:; // of colored-bag
end class colored-bag;

define class counted-colored-bag(<object>)
  slot count :: <integer>;
  slot color :: <string>;
end class counted-colored-bag;


define function ensure-colored-bag
    (bags-by-color :: <string-table>, bag-color :: <string>)

  if(~element(bags-by-color, bag-color, default: #f))
    bags-by-color[bag-color] := make(colored-bag,
        color: bag-color,
        contains: make(<vector>, of: counted-colored-bag),
        contained-in: make(<vector>, of: colored-bag));
  end if;

  bags-by-color[bag-color]
end function ensure-colored-bag;

define function enumerate-container-paths
    (bag :: colored-bag, seen :: <string-table>)

  let paths-from-here = 0;
  for (container in bag.contained-in)
    if(~element(seen, container.color, default: #f))
      seen[container.color] := #t;
      paths-from-here := paths-from-here + 1 + enumerate-container-paths(container, seen);
    end if;
  end for;
  paths-from-here
end function enumerate-container-paths;

define function enumerate-contained-paths
    (bag :: colored-bag, bags-by-color :: <string-table>)

  let bags-contained-here = 0;
  for (contained in bag.contains)
    let contained-bag = bags-by-color[contained.color];
    bags-contained-here := bags-contained-here + contained.count * (1 + enumerate-contained-paths(contained-bag, bags-by-color));
  end for;
  bags-contained-here
end function enumerate-contained-paths;

define function part1
    (bags-by-color :: <string-table>)

  let seen = make(<string-table>);
  let num-paths = enumerate-container-paths(bags-by-color["shiny gold"], seen);
  format-out("part1: %d\n", num-paths);

end function part1;

define function part2
    (bags-by-color :: <string-table>)

  let seen = make(<string-table>);
  let num-bags = enumerate-contained-paths(bags-by-color["shiny gold"], bags-by-color);
  format-out("part2: %d\n", num-bags);

end function part2;

define function main
    (name :: <string>, arguments :: <vector>)

  let lines = make(<vector>, of: <string>);

  until(stream-at-end?(*standard-input*))
    let line = read-line(*standard-input*);
    lines := add(lines, line)
  end until;

  let bags-by-color = make(<string-table>);

  for (line in lines)
    let bag-split = split(line, " bags contain ");
    let bag-color = bag-split[0];
    let content-description = bag-split[1];

    let bag = ensure-colored-bag(bags-by-color, bag-color);

    if(content-description ~= "no other bags.")
      let split-contents = split(content-description, ", ");

      for (c in split-contents)
        // split again by " ", then [0] == count, [size] == "bag{s}.?" (and we can skip it)
        let s = split(c, " ");
        let count = string-to-integer(s[0]);
        let contained-color = join(copy-sequence(s, start: 1, end: size(s) - 1), " ");

        // ensure the color exists in our hash
        let contained-bag = ensure-colored-bag(bags-by-color, contained-color);
        let bag-with-count = make(counted-colored-bag);
        bag-with-count.count := count;
        bag-with-count.color := contained-color;

        bag.contains := add(bag.contains, bag-with-count);
        contained-bag.contained-in := add(contained-bag.contained-in, bag);
      end for;
    end if;


  end for;

  part1(bags-by-color);
  part2(bags-by-color);

  exit-application(0);
end function main;

main(application-name(), application-arguments());
