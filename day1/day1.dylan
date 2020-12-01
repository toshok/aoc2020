Module: day1
Synopsis: 
Author: 
Copyright: 

define function part1
    (entries :: <vector>)

  for (i :: <integer> from 0 to size(entries) - 2)
    for (j :: <integer> from i + 1 to size(entries) - 1)
      if (entries[i] + entries[j] == 2020)
        format-out("%d + %d = 2020\n", entries[i], entries[j]);
        format-out("%d\n", entries[i] * entries[j]);
      end if;
    end for;
  end for;
end function part1;

define function part2
    (entries :: <vector>)

  for (i :: <integer> from 0 to size(entries) - 3)
    for (j :: <integer> from i + 1 to size(entries) - 2)
      for (k :: <integer> from j + 1 to size(entries) - 1)
        if (entries[i] + entries[j] + entries[k] == 2020)
          format-out("%d + %d + %d = 2020\n", entries[i], entries[j], entries[k]);
          format-out("%d\n", entries[i] * entries[j] * entries[k]);
        end if;
      end for;
    end for;
  end for;
end function part2;

define function main
    (name :: <string>, arguments :: <vector>)

  let entries = make(<vector>, of: <integer>);

  until(stream-at-end?(*standard-input*))
    let line = read-line(*standard-input*);
   
    entries := add(entries, string-to-integer(line)) 
  end until;

  part1(entries);
  part2(entries);

  exit-application(0);
end function main;

main(application-name(), application-arguments());
