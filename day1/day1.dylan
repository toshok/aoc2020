Module: day1
Synopsis: 
Author: 
Copyright: 

define function main
    (name :: <string>, arguments :: <vector>)

  let entries = make(<vector>, of: <integer>);

  until(stream-at-end?(*standard-input*))
    let line = read-line(*standard-input*);
   
    entries := add(entries, string-to-integer(line)) 
  end until;

  for (i :: <integer> from 0 to size(entries) - 2)
    for (j :: <integer> from i + 1 to size(entries) - 1)
      if (entries[i] + entries[j] == 2020)
        format-out("%d + %d = %d\n", entries[i], entries[j], entries[i] + entries[j]);
        format-out("%d\n", entries[i] * entries[j]);
      end if;
    end for;
  end for;

  exit-application(0);
end function main;

main(application-name(), application-arguments());
