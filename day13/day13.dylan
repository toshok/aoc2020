Module: day13
Synopsis: 
Author: 
Copyright: 

define function part22
    (lines :: <vector>)
  let earliest-departure = string-to-integer(lines[0]);
  let bus-strings = split(lines[1], ",");

  let lines = make(<table>);

  for(i :: <integer> from 0 to size(bus-strings) - 1)
    block(continue)
      let bus-str = bus-strings[i];
      if(bus-str = "x")
        continue();
      end if;

      lines[string-to-integer(bus-str)] := i;
    end block;
  end for;

  let min-value = 0;
  let increment = 1;
  for (key in lines.key-sequence)
    // for each key/value, we've found a time that works for the keys/values that came before.  we also
    // know (via increment) the amount we need to increment by when checking for the 
    // current key/value.  increment is guaranteed to maintain mod = 0 for all previous keys/values.
    let value = lines[key];
    format-out("t + %d === 0 mod %d\n", value, key);
    while (modulo(min-value + value, key) ~= 0)
      // keep iterating until we find one that works.
      min-value := min-value + increment;
    end while;
    increment := increment * key;
  end;

  format-out("answer is %d\n", min-value);
end function part22;

define function part1
    (lines :: <vector>)

  let earliest-departure = string-to-integer(lines[0]);
  let buses = split(lines[1], ",");

  let best-bus = 0;
  let best-bus-time = 99999;

  for(bus-str in buses)
    block(continue)
      if(bus-str = "x")
        continue();
      end if;
      let bus = string-to-integer(bus-str);
      let before = floor/(earliest-departure, bus) * bus;
      let after = before + bus;

      if(after - earliest-departure < best-bus-time)
        format-out("choosing bus %d, since best-bus-time = %d\n", bus, after);
        best-bus := bus;
        best-bus-time := after - earliest-departure;
      end if;
    end block;
  end for;

  format-out("best bus = %d, answer = %d\n", best-bus, best-bus * best-bus-time);

end function part1;

define function main
    (name :: <string>, arguments :: <vector>)
  let lines = make(<vector>, of: <string>);
  until(stream-at-end?(*standard-input*))
    let line = read-line(*standard-input*);
    lines := add(lines, line);
  end until;

  // part1(lines);
  part22(lines);

  exit-application(0);
end function main;

main(application-name(), application-arguments());
