Module: day15
Synopsis: 
Author: 
Copyright: 

define function what-to-speak(uses, last-spoken)
  block(return)
    let use-list = element(uses, last-spoken, default: #f);
    if (use-list = #f)
      // we have no list for this number, so it's the first time we've seen it
      return(0);
    end if;

    if (use-list[1] = -1)
      // we have only 1 use, so it's 0
      return(0);
    end if;

    use-list[size(use-list) - 1] - use-list[size(use-list) - 2]
  end block;
end function;

define function speak
    (uses :: <table>, turn :: <integer>, spoken :: <integer>)
  if (element(uses, spoken, default: #f) = #f)
    uses[spoken] := make(<vector>, of: <integer>, size: 2, fill: -1);
  end if;

  let use-list = uses[spoken];
  if (use-list[0] = -1)
    use-list[0] := turn;
  elseif (use-list[1] = -1)
    use-list[1] := turn;
  else
    use-list[0] := use-list[1];
    use-list[1] := turn;
  end if;
end function;

define function what-to-speak2(uses :: <vector>, last-spoken :: <integer>)
  block(return)
    if (head(uses[last-spoken]) = -1 | tail(uses[last-spoken]) = -1)
      return(0);
    end if;

    tail(uses[last-spoken]) - head(uses[last-spoken])
  end block;
end function;

define function speak2
    (uses :: <vector>, turn :: <integer>, spoken :: <integer>)
  head(uses[spoken]) := tail(uses[spoken]);
  tail(uses[spoken]) := turn;
end function;

define function part2
    (numbers :: <vector>)

  let uses = make(<vector>, of: <pair>, size: 30000000);

  replace-elements! (
    uses,
    method (el)
      #t
    end method,
    method (el)
      #(-1, -1)
    end method);

  for(i :: <integer> from 0 to size(numbers) - 1)
    let num = numbers[i];
    speak(uses, i + 1, num);
  end for;

  let last-spoken = numbers[size(numbers) - 1];
  for(i :: <integer> from size(numbers) + 1 to 30000000)
    // if (modulo(i, 100000) = 0)
    //   format-out("   turn %d\n", i);
    //   force-out();
    // end if;
    // format-out("turn %d:\n", i);
    let age = what-to-speak(uses, last-spoken);

    // format-out("   speak %d\n", age);
    // force-out();

    speak(uses, i, age);

    last-spoken := age;
  end for;

  format-out("part2: %d\n", last-spoken);
end function part2;

define function part1
    (numbers :: <vector>)

  let uses = make(<vector>, of: <pair>, size: 2020);
  replace-elements! (
    uses,
    method (el)
      #t
    end method,
    method (el)
      #(-1, -1)
    end method);

  for(i :: <integer> from 0 to size(numbers) - 1)
    let num = numbers[i];
    speak2(uses, i + 1, num);
  end for;

  let last-spoken = numbers[size(numbers) - 1];
  for(i :: <integer> from size(numbers) + 1 to 2020)
    format-out("turn %d:\n", i);
    let age = what-to-speak2(uses, last-spoken);

    format-out("   speak %d\n", age);
    force-out();

    speak2(uses, i, age);

    last-spoken := age;
  end for;

  format-out("part1: %d\n", last-spoken);
end function part1;

define function main
    (name :: <string>, arguments :: <vector>)

  let lines = make(<vector>, of: <string>);
  until(stream-at-end?(*standard-input*))
    let line = read-line(*standard-input*);
    lines := add(lines, line);
  end until;

  let number-str = split(lines[0], ",");
  let numbers = make(<vector>, of: <integer>);
  for (num-str in number-str)
    numbers := add(numbers, string-to-integer(num-str))
  end for;

  part1(numbers);
  // part2(numbers);

  exit-application(0);
end function main;

main(application-name(), application-arguments());
