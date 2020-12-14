Module: day14
Synopsis: 
Author: 
Copyright: 


define function parse-mask
    (mask :: <string>)

    let mask-1 = 0;
    let mask-0 = 0;
    for (i :: <integer> from size(mask) - 1 to 0 by -1)
      let bit = 2^(size(mask) - 1 - i);

      select(mask[i])
        '1' => mask-1 := logior(mask-1, bit);
        '0' => mask-0 := logior(mask-0, bit);
        otherwise =>
            // do nothing
      end select;
    end for;

    values(mask-1, mask-0);
end function parse-mask;

define function part1
    (lines :: <vector>)


  let mem = make(<table>);
  let mask = #f;

  let mask-1 = 0;
  let mask-0 = 0;

  for (line in lines)
    if (find-substring(line, "mask") == 0)
      let (new-mask-1, new-mask-0) = parse-mask(copy-sequence(line, start: size("mask = ")));
      mask-1 := new-mask-1;
      mask-0 := new-mask-0;
    else
      let address = string-to-integer(copy-sequence(line, start: size("mem[")));
      let equal-sign = find-substring(line, "= ");
      let value = string-to-integer(copy-sequence(line, start: equal-sign + 2));

      value := logior(value, mask-1);
      value := logand(value, lognot(mask-0));

      mem[address] := value;
    end if;
  end for;

  // now sum up all the values in memory
  let sum = 0;
  for (value keyed-by key in mem)
    sum := sum + value;
  end;

  format-out("part1: %d\n", sum);
end function part1;

define function set-addresses
    (mask :: <string>, address :: <integer>, mem :: <table>, value :: <integer>)

  // first count the X's
  let X-count = 0;
  let or-mask = 0;
  for (i :: <integer> from size(mask) - 1 to 0 by -1)
    if (mask[i] = 'X')
      X-count := X-count + 1;
    end if;
    if (mask[i] = '1')
      or-mask := logior(or-mask, 2^(size(mask) - 1 - i));
    end if;
  end for;
  let max-x-value = 2 ^ X-count - 1;

  // format-out("address = %d\n", address);
  // format-out("mask = '%s'\n", mask);
  // format-out("X-count = %d, max-x-value = %d\n", X-count, max-x-value);
  address := logior(address, or-mask);
  // format-out("address after or-mask = %d\n", address);

  for(mask-x-value :: <integer> from 0 to max-x-value)
    let addr = address;
    let mask-bit = 0;
    // format-out("mask-x-value = %d\n", mask-x-value);
    for (i :: <integer> from size(mask) - 1 to 0 by -1)
      if (mask[i] = 'X')
        let bit-value = logand(mask-x-value, 2 ^ mask-bit);
        if (bit-value = 0)
          // format-out("clearing bit %d\n",size(mask) - 1 - i);
          addr := logand(addr, lognot(2^(size(mask) - 1 - i)));
          // format-out(" addr after = %d\n", addr);
        else
          // format-out("setting bit %d\n",size(mask) - 1 - i);
          addr := logior(addr, 2^(size(mask) - 1 - i));
          // format-out(" addr after = %d\n", addr);
        end if;
        mask-bit := mask-bit + 1;
      end if;
    end for;

    // format-out("setting mem[%d] = %d\n", addr, value);
    mem[addr] := value;
  end for;

end function set-addresses;

define function part2
    (lines :: <vector>)


  let mem = make(<table>);
  let mask = #f;

  for (line in lines)
    if (find-substring(line, "mask") == 0)
      mask := copy-sequence(line, start: size("mask = "));
    else
      let address = string-to-integer(copy-sequence(line, start: size("mem[")));
      let equal-sign = find-substring(line, "= ");
      let value = string-to-integer(copy-sequence(line, start: equal-sign + 2));

      set-addresses(mask, address, mem, value);
    end if;
  end for;

  // now sum up all the values in memory
  let sum = 0;
  for (value keyed-by key in mem)
    sum := sum + value;
  end;

  format-out("part2: %d\n", sum);
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
