Module: day18
Synopsis: 
Author: 
Copyright: 

define function parse-expression
    (str :: <string>)
  // this is going to suck because we don't split on (), but simply on spaces, but we're gonna roll with it!
  let tokens = split(str, " ");

  parse-expression-from-tokens(tokens);
end function parse-expression;

define function parse-expression-from-tokens
    (tokens :: <sequence>)
  let tree = make(<deque>);
  let idx = 0;
  while (idx < size(tokens))
    if(tokens[idx][0] == '(')
      let (subtree, next-idx) = parse-subexpression(tokens, idx);
      tree := push-last(tree, subtree);
      idx := next-idx;
    else
      tree := push-last(tree, tokens[idx]);
      idx := idx + 1;
    end if;
  end while;

  tree;
end function parse-expression-from-tokens;

define function parse-subexpression
    (tokens :: <sequence>, idx :: <integer>)
  format-out("parse-subexpression, rest = %s!\n", join(copy-sequence(tokens, start: idx), " "));
  force-out();
  let depth = 0;
  let end-term = block(break)
    for (i :: <integer> from idx to size(tokens) - 1)
      let tok = tokens[i];
      if (tok[0] = '(')
        for (ti from 0 to size(tok) - 1)
          if (tok[ti] = '(')
            depth := depth + 1;
          end if;
        end for;
      end if;
      if (tok[size(tok) - 1] = ')')
        for (ti from 0 to size(tok) - 1)
          if (tok[ti] = ')')
            depth := depth - 1;
            if (depth = 0)
              break(i);
            end if;
          end if;
        end for;
      end if;
    end for;
  end block;

  let sub-token-list = copy-sequence(tokens, start: idx, end: end-term + 1);
  let first-token = sub-token-list[0];
  let last-token = sub-token-list[size(sub-token-list) - 1];


  sub-token-list[0] := copy-sequence(first-token, start: 1);
  sub-token-list[size(sub-token-list) - 1] := copy-sequence(last-token, start: 0, end: size(last-token) - 1);

  format-out("subexpression tokens = %s\n", join(sub-token-list, " "));
  force-out();


  values(parse-expression-from-tokens(sub-token-list), end-term + 1);
end function parse-subexpression;

define function eval-expression-part1
    (tree :: <deque>)

  while (size(tree) > 1)
    let lhs = eval-term(pop(tree), eval-expression-part1);
    let operator = pop(tree);
    let rhs = eval-term(pop(tree), eval-expression-part1);

    let v = select(operator[0])
      '+' => lhs + rhs;
      '*' => lhs * rhs;
    end select;

    push(tree, v);
  end while;

  tree[0]
end function eval-expression-part1;

define function find-first-op-index
    (tree :: <deque>)
  let earliest-mult = #f;
  block(finished)
    for (i from 0 to size(tree) - 1)
      if (tree[i] = "*" & earliest-mult = #f)
        earliest-mult := i;
      end if;
      if (tree[i] = "+")
        finished(i);
      end if;
    end for;
    earliest-mult;
  end block;
end function find-first-op-index;

define function eval-expression-part2
    (tree :: <deque>)

  while (size(tree) > 1)
    print-object(tree, *standard-output*);
    force-out();

    let op-idx = find-first-op-index(tree);
    let lhs = eval-term(tree[op-idx - 1], eval-expression-part2);
    let operator = tree[op-idx];
    let rhs = eval-term(tree[op-idx + 1], eval-expression-part2);

    let v = select(operator[0])
      '+' => lhs + rhs;
      '*' => lhs * rhs; 
    end select;

    tree := replace-subsequence!(tree, list(v), start: op-idx - 1, end: op-idx + 2);
  end while;

  tree[0]
end function eval-expression-part2;

define function eval-term(term, tree-evaluator)
  if (instance?(term, <string>))
    string-to-integer(term);
  elseif (instance?(term, <integer>))
    term
  else
    tree-evaluator(term)
  end if;
end function eval-term;

define function part1
    (lines :: <vector>)

  let sum = 0;
  for (line in lines)
    let v = eval-expression-part1(parse-expression(line));
    sum := sum + v;
  end for;

  format-out("part1: %d\n", sum);
end function part1;

define function part2
    (lines :: <vector>)

  let sum = 0;
  for (line in lines)
    let v = eval-expression-part2(parse-expression(line));
    sum := sum + v;
  end for;

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
