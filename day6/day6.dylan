Module: day6
Synopsis: 
Author: 
Copyright: 

define function split-into-groups
    (lines :: <vector>)

  let groups = make(<vector>, of: <vector>);

  let start-idx = 0;
  for (i :: <integer> from 0 to size(lines) - 1)
    if(size(lines[i]) == 0)
      let group = copy-sequence(lines, start: start-idx, end: i);
      groups := add(groups, group);
      start-idx := i + 1;
    end if;
  end for;

  let group = copy-sequence(lines, start: start-idx);
  groups := add(groups, group);
  groups
end function split-into-groups;


define function count-any-yes
    (group :: <vector>)

  let questions = make(<string-table>);

  for (line in group)
    for (j :: <integer> from 0 to size(line) - 1)
      questions[copy-sequence(line, start: j, end: j + 1)] := #t;
    end for;
  end for;

  let count = 0;
  for (key in questions.key-sequence)
    count := count + 1;
  end;
  count
end function count-any-yes;

define function count-all-yes
    (group :: <vector>)

  let questions = make(<string-table>);

  for (line in group)
    for (j :: <integer> from 0 to size(line) - 1)
      let question = copy-sequence(line, start: j, end: j + 1);
      questions[question] := element(questions, question, default: 0) + 1;
    end for;
  end for;

  let count = 0;
  for (value in questions)
    if(value == size(group))
      count := count + 1;
    end if;
  end;
  count
end function count-all-yes;


define function accumulate-groups
    (groups :: <vector>, map-fn)

    let counts = map(map-fn, groups);

    reduce1(\+, counts)
end function accumulate-groups;

define function part1
    (groups :: <vector>)

  format-out("part1: %d\n", accumulate-groups(groups, count-any-yes))
end function part1;

define function part2
    (groups :: <vector>)

  format-out("part2: %d\n", accumulate-groups(groups, count-all-yes))
end function part2;

define function main
    (name :: <string>, arguments :: <vector>)

  let lines = make(<vector>, of: <string>);

  until(stream-at-end?(*standard-input*))
    let line = read-line(*standard-input*);
    lines := add(lines, line)
  end until;

  let groups = split-into-groups(lines);
  part1(groups);
  part2(groups);

  exit-application(0);
end function main;


main(application-name(), application-arguments());
