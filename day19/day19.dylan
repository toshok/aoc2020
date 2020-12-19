Module: day19
Synopsis: 
Author: 
Copyright: 


define function parse-rule
    (rule-strings :: <table>, rules :: <table>, rule-idx :: <integer>)
  block(return)
    if (element(rules, rule-idx, default: #f))
      return(rules[rule-idx]);
    end if;

    if (find-substring(rule-strings[rule-idx], "\""))
      // it's a character rule.  the rule is just the contents of the quoted region.
      // split on quotes and the answer is split[1]
      rules[rule-idx] := split(rule-strings[rule-idx], "\"")[1];
      return(rules[rule-idx]);
    end if;

    // otherwise it's a range or alternation of ranges
    let rule-branches = map(
      method (range)
        join(
          map(
            method (rule-str)
              parse-rule(rule-strings, rules, string-to-integer(rule-str));
            end method,
            split(range, " ")),
          "")
      end method,
      split(rule-strings[rule-idx], " | "));

    // it was a single range.  that's the rule.
    if (size(rule-branches) = 1)
      rules[rule-idx] := rule-branches[0];
      return(rules[rule-idx]);
    end if;

    // it had an |, so we need to encode it as ((...)|(...))
    rules[rule-idx] := concatenate("(", join(map(
      method(branch)
        concatenate("(", branch, ")")
      end method,
      rule-branches),
      "|"), ")");
    return(rules[rule-idx]);
  end block;
end function parse-rule;

define function parse-rules
    (lines :: <vector>)

  // find the blank line separating the rules from the rest of the file.
  let blank-idx = block(break)
    for (l from 0 to size(lines) - 1)
      if (size(lines[l]) == 0)
        break(l);
      end if;
    end for;
  end block;

  let rule-strings = make(<table>);
  for (l from 0 to blank-idx - 1)
    let split-line = split(lines[l], ": ");
    rule-strings[string-to-integer(split-line[0])] := split-line[1];
  end for;

  let rules = make(<table>);
  parse-rule(rule-strings, rules, 0);

  values(rules, blank-idx + 1);
end function parse-rules;

define function part1
    (lines :: <vector>)

  let (rules, idx) = parse-rules(lines);

  // now that we have rules, count lines that match them
  let count = 0;
  let regex-str = concatenate("^", rules[0], "$");
  let rule-regex = compile-regex(regex-str);
  for (i :: <integer> from idx to size(lines) - 1)
    let match = regex-search(rule-regex, lines[i]);

    print-object(match, *standard-output*);
    force-out();

    if (match)
      format-out("line %d: %s matches\n", i, lines[i]);
      force-out();
      count := count + 1;
    end if;
  end for;

  format-out("part1: %d\n", count);
end function part1;

define function check-line(line, rule-42, rule-31)
  block(finished)
    for (i42 from 2 to 10)
      for (i31 from 1 to i42 - 1)
        let regex = compile-regex(
              concatenate("^((", rule-42, "){", integer-to-string(i42), "})",
                          "((", rule-31, "){", integer-to-string(i31), "})$"));
        if (regex-search(regex, line))
          finished(#t);
        end if;
      end for;
    end for;
    #f
  end block;
end function check-line;

define function part2
    (lines :: <vector>)

  let (rules, idx) = parse-rules(lines);

  // now that we have rules, count lines that match them
  let count = 0;

  // we know rule 0 is '8 11'
  // and are given the replacements:
  //
  // 8: 42 | 42 8
  // 11: 42 31 | 42 11 31

  // This means we have some number of 42s, followed by some other number of 31s.  the number
  // of 42s must be larger than the number of 31s, but that's it.

  for (i :: <integer> from idx to size(lines) - 1)
    format-out("line %d: checking\n", i - idx);
    force-out();

    let match = check-line(lines[i], rules[42], rules[31]);

    if (match)
      format-out("  match\n");
      count := count + 1;
    else
      format-out("  no match\n");
    end if;
  end for;

  format-out("part2: %d\n", count);
end function part2;


define function main
    (name :: <string>, arguments :: <vector>)

  let lines = make(<vector>, of: <string>);
  until(stream-at-end?(*standard-input*))
    let line = read-line(*standard-input*);
    lines := add(lines, line);
  end until;

  // part1(lines);
  part2(lines);

  exit-application(0);
end function main;

main(application-name(), application-arguments());
