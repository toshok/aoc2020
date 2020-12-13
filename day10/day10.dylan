Module: day10
Synopsis: 
Author: 
Copyright: 

define class node(<object>)
  slot value :: <integer>, required-init-keyword: value:;
  slot edges-to :: <vector>, required-init-keyword: edges-to:;
end class node;

define function dump-dag(joltages :: <vector>, nodes :: <vector>)
  for (joltage in joltages)
    format-out("node %d\n", joltage);
    for (edge in nodes[joltage].edges-to)
      format-out("  edge-to: %d\n", edge.value);
    end for;
  end for;
end function dump-dag;

define function build-dag
  (joltages :: <vector>)

  format-out("making dag of size %d\n", joltages[size(joltages) - 1]);
  let nodes = make(<vector>, of: node, size: joltages[size(joltages) - 1] + 1);

  // create all our nodes ahead of time
  for (joltage in joltages)
    nodes[joltage] := make(node, value: joltage, edges-to: make(<vector>, of: node));
  end for;

  // now add edges

  for(idx :: <integer> from 0 to size(joltages) - 2)
    let from-joltage = joltages[idx];
    block(continue-outer)
      for(to-idx :: <integer> from idx + 1 to size(joltages) - 1)
        let to-joltage = joltages[to-idx];
        if(to-joltage - from-joltage > 3)
          continue-outer();
        end if;
        nodes[from-joltage].edges-to := add(nodes[from-joltage].edges-to, nodes[to-joltage]);
      end for;
    end block;
  end for;

  format-out("built dag!\n");

  // dump-dag(joltages, nodes);

  nodes
end function build-dag;

define function number-of-paths(
  joltages :: <vector>, nodes :: <vector>
)
  let paths-to-destination = make(<vector>, of: <integer>, size: size(nodes) + 1, fill: 0);

  paths-to-destination[joltages[size(joltages) - 1]] := 1;

  for (i :: <integer> from size(joltages) - 1 to 0  by -1)
    let node = nodes[joltages[i]];
    for (dest-node in node.edges-to)
      paths-to-destination[node.value] := paths-to-destination[node.value] + paths-to-destination[dest-node.value]
    end for;
  end for;

  paths-to-destination[0]
end function number-of-paths;


define function number-of-paths2
    (joltages :: <vector>)

    // joltages is sorted, and contains the 0 and (device joltage)
    let paths-to-destination = make(<vector>, of: <integer>, size: size(joltages), fill: 0);
    paths-to-destination[size(joltages) - 1] := 1;

    for (i :: <integer> from size(joltages) - 1 to 1 by -1)
      block (continue-outer)
        for (j :: <integer> from i - 1 to 0 by -1)
          if(joltages[i] - joltages[j] > 3)
            continue-outer();
          end if;
          paths-to-destination[j] := paths-to-destination[j] + paths-to-destination[i];
        end for;
      end block;
    end for;

    paths-to-destination[0];
end function number-of-paths2;

define function part2
    (numbers :: <vector>)

  let joltages = sort(add(numbers, 0));
  joltages := add(joltages, joltages[size(joltages) - 1] + 3);

  let nodes = build-dag(joltages);

  format-out("num paths = %d\n", number-of-paths(joltages, nodes));
  format-out("num paths = %d\n", number-of-paths2(joltages));
end function part2;

define function part1
    (numbers :: <vector>)

  let joltages = sort(numbers);

  let jolt1 = 1; // to count the outlet
  let jolt3 = 1; // to count my device

  for(i :: <integer> from 0 to size(joltages) - 2)
    if(joltages[i] + 1 = joltages[i + 1])
      jolt1 := jolt1 + 1
    end if;
    if(joltages[i] + 3 = joltages[i + 1])
      jolt3 := jolt3 + 1
    end if;
  end for;

  format-out("part1:  device-joltage = %d, 1-jolt = %d, 3-jolt = %d, answer = %d\n", joltages[size(joltages) - 1] + 3, jolt1, jolt3, jolt1 * jolt3)
end function part1;

define function main
    (name :: <string>, arguments :: <vector>)

  let numbers = make(<vector>, of: <number>);

  until(stream-at-end?(*standard-input*))
    let line = read-line(*standard-input*);
    numbers := add(numbers, string-to-integer(line));
  end until;

  part1(numbers);
  part2(numbers);

  exit-application(0);
end function main;

main(application-name(), application-arguments());
