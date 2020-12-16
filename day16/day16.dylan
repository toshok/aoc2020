Module: day16
Synopsis: 
Author: 
Copyright: 

define function parse-range
    (range :: <string>)

  let s = split(range, "-");
  pair(string-to-integer(s[0]), string-to-integer(s[1]))
end function parse-range;

define function parse-rules
    (rule-lines :: <vector>)

  let rules = make(<table>);
  for (rule-line in rule-lines)
    let s1 = split(rule-line, ": ");
    let s2 = split(s1[1], " or ");
    let range1 = parse-range(s2[0]);
    let range2 = parse-range(s2[1]);

    rules[s1[0]] := pair(range1, range2);
  end for;
  rules
end function parse-rules;

define function valid-rule-value
    (rule, v :: <integer>)
  let range1 = head(rule);
  let range2 = tail(rule);
  (v >= head(range1) & v <= tail(range1)) | (v >= head(range2) & v <= tail(range2))
end function valid-rule-value;

define function valid-value
    (rules :: <table>, v :: <integer>)
  block(finished)
    for (key in rules.key-sequence)
      let ranges = rules[key];
      let range1 = head(ranges);
      let range2 = tail(ranges);
      if (v >= head(range1) & v <= tail(range1))
        finished(#t);
      end if;
      if (v >= head(range2) & v <= tail(range2))
        finished(#t);
      end if;
    end;
    #f
  end block;
end function valid-value;

define function part1
    (blocks :: <vector>)

  // blocks[0] is the rules
  let rules = parse-rules(blocks[0]);

  // blocks[1] is "your ticket"
  // ignore for now

  let valid-tickets = make(<vector>, of: <integer>);
  let sum = 0;
  // blocks[2] is "nearby tickets"
  for (i :: <integer> from 1 to size(blocks[2]) - 1)
    let values = map(string-to-integer, split(blocks[2][i], ","));
    let valid-ticket = #t;
    for (v in values)
      if (~valid-value(rules, v))
        sum := sum + v;
        valid-ticket := #f;
      end if;
    end for;
    if (valid-ticket)
      valid-tickets := add(valid-tickets, i);
    end if;
  end for;

  format-out("part1: %d\n", sum);
  valid-tickets
end function part1;

define function part2
    (blocks :: <vector>, valid-ticket-indices :: <vector>)

  let rules = parse-rules(blocks[0]);

  // first convert all our nearby tickets to integers
  let nearby-tickets = make(<vector>, of: <vector>);
  for (valid-ticket-idx in valid-ticket-indices)
    let values = map(string-to-integer, split(blocks[2][valid-ticket-idx], ","));
    nearby-tickets := add(nearby-tickets, values);
  end for;

  // initialize rules-left with all rules.  we loop until this table is empty
  let rules-left = make(<string-table>);
  for (key in rules.key-sequence)
    rules-left[key] := #t;
  end for;

  let field-assignments = make(<vector>, of: <string>, size: size(rules-left), fill: #f);
  
  while (size(rules-left.key-sequence) > 0)
    for (i :: <integer> from 0 to size(nearby-tickets[0]) - 1)
      if (field-assignments[i] = #f)
        // we haven't succeeded in assigning this field yet.  make a copy of rules-left
        // that we'll remove from as we go.
        let valid-rules = make(<string-table>);
        for (key in rules-left.key-sequence) 
          valid-rules[key] := #t;
        end for;

        for (nb :: <integer> from 0 to size(nearby-tickets) - 1)
          let nearby-ticket = nearby-tickets[nb];
          for (rule-key in valid-rules.key-sequence) 
            if (~valid-rule-value(rules[rule-key], nearby-ticket[i]))
              remove-key!(valid-rules, rule-key);
            end if;
          end for;
        end for;

        if (size(valid-rules.key-sequence) = 1)
          let matching-rule = valid-rules.key-sequence[0];
          field-assignments[i] := matching-rule;
          remove-key!(rules-left, matching-rule);
        end if;
      end if;
    end for;
  end while;

  let my-ticket-values = map(string-to-integer, split(blocks[1][1], ","));
  let product = 1;
  for (ai :: <integer> from 0 to size(field-assignments) - 1)
    if (find-substring(field-assignments[ai], "departure") = 0)
      product := product * my-ticket-values[ai];
    end if;
  end for;

  format-out("part2: %d\n", product);
end function part2;

define function main
    (name :: <string>, arguments :: <vector>)

  let blocks = make(<vector>, of: <vector>);
  let lines = make(<vector>, of: <string>);
  until(stream-at-end?(*standard-input*))
    let line = read-line(*standard-input*);
    if (size(line) = 0)
      blocks := add(blocks, lines);
      lines := make(<vector>, of: <string>);
    else
      lines := add(lines, line);
    end if;
  end until;

  if (size(lines) > 0)
    blocks := add(blocks, lines);
  end if;

  let valid-tickets = part1(blocks);
  part2(blocks, valid-tickets);

  exit-application(0);
end function main;

main(application-name(), application-arguments());
