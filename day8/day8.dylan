Module: day8
Synopsis: 
Author: 
Copyright: 

define constant *acc* = 0;
define constant *jmp* = 1;
define constant *nop* = 2;

define class instruction(<object>)
  slot opcode :: <integer>, required-init-keyword: opcode:;
  slot operand :: <integer>, required-init-keyword: operand:;
end class instruction;

define function string-to-opcode
    (opcode :: <string>)
  block (finished)
  if(opcode = "jmp")
    finished(*jmp*);
  end if;
  if(opcode = "acc")
    finished(*acc*);
  end if;
  *nop*
  end block;
end function string-to-opcode;


define function execute
    (instructions :: <vector>)

  let counts = make(<vector>, of: <integer>);
  for(i :: <integer> from 0 to size(instructions) - 1)
    counts := add(counts, 0);
  end for;

  let ip = 0;
  let acc = 0;

  while(ip >= 0 & ip < size(instructions) & counts[ip] = 0)
    block(continue)
      counts[ip] := counts[ip] + 1;
      let instr = instructions[ip];

      select(instr.opcode)
        *acc* =>
              acc := acc + instr.operand;
              ip := ip + 1;
              continue();

        *jmp* =>
              ip := ip + instr.operand;
              continue();

        *nop* =>
              ip := ip + 1;
              continue();
      end select;

    end block;
  end while;

  values(acc, ip)
end function execute;

define function part2
    (instructions :: <vector>)

  let acc =
  block(finished)
    for (instr in instructions)

      select(instr.opcode)
        *jmp* =>
              instr.opcode := *nop*;
              let (acc_, ip_) = execute(instructions);
              instr.opcode := *jmp*;
              if(ip_ = size(instructions))
                finished(acc_);
              end if;

        *nop* =>
              instr.opcode := *jmp*;
              let (acc_, ip_) = execute(instructions);
              instr.opcode := *nop*;
              if(ip_ = size(instructions))
                finished(acc_);
              end if;

        *acc* => // nothing to do for acc instructions
      end select;
    end for;
  end block;

  format-out("part2: acc = %d\n", acc);
end function part2;

define function part1
    (instructions :: <vector>)

  let (acc, ip) = execute(instructions);

  format-out("part1: acc = %d\n", acc);
end function part1;

define function main
    (name :: <string>, arguments :: <vector>)

  let instructions = make(<vector>, of: instruction);

  until(stream-at-end?(*standard-input*))
    let line = read-line(*standard-input*);

    let s = split(line, " ");

    let opcode = string-to-opcode(s[0]);
    let operand = string-to-integer(s[1]);

    instructions := add(instructions, make(instruction, opcode: opcode, operand: operand))
  end until;

  part1(instructions);
  part2(instructions);

  exit-application(0);
end function main;

main(application-name(), application-arguments());
