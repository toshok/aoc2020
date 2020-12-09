Module: day9
Synopsis: 
Author: 
Copyright: 

define function shift
    (numbers :: <vector>, number :: <integer>)

  let new-sequence = copy-sequence(numbers, start: 1);
  new-sequence := add(new-sequence, number);

  new-sequence
end function shift;

define function check-for-sum
    (haystack :: <vector>, needle :: <integer>)

  block(finished)
    for (i :: <integer> from 0 to size(haystack) - 2)
      for (j :: <integer> from i + 1 to size(haystack) - 1)
        if(haystack[i] + haystack[j] = needle)
          finished(#t)
        end if;
      end for;
    end for;
    #f
  end block;
end function check-for-sum;

define constant preamble-size = 25;

define function part2
    (haystack :: <vector>, needle :: <integer>)

  let seq = block(finished-loops)
    for (i :: <integer> from 0 to size(haystack) - 2)
      let sum = haystack[i];
      block(finished-i)
        for (j :: <integer> from i + 1 to size(haystack) - 1)
          sum := sum + haystack[j];
          if(sum > needle)
            finished-i();
          end if;

          if(sum == needle)
            finished-loops(copy-sequence(haystack, start: i, end: j));
          end if;
        end for;
      end block;
    end for;
  end block;

  let sorted = sort(seq);
  format-out("part2: %d\n", sorted[0] + sorted[size(sorted) - 1]);
end function part2;

define function part1
    (lines :: <vector>)

    let window = copy-sequence(lines, start: 0, end: preamble-size);
    let rest = copy-sequence(lines, start: preamble-size);

    let answer = block(finished)
      for (number in rest)
        if(~check-for-sum(window, number))
          finished(number);
        end if;

        window := shift(window, number);
      end for;
    end block;

    format-out("part1: %d\n", answer);
    answer
end function part1;

define function main
    (name :: <string>, arguments :: <vector>)


  let numbers = make(<vector>, of: <integer>);

  until(stream-at-end?(*standard-input*))
    let line = read-line(*standard-input*);
    numbers := add(numbers, string-to-integer(line))
  end until;

  let answer-from-part1 = part1(numbers);
  part2(numbers, answer-from-part1);

  exit-application(0);
end function main;

main(application-name(), application-arguments());
