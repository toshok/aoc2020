Module: day4
Synopsis: 
Author: 
Copyright: 

define constant $haircolor-re :: <regex> = compile-regex("^#[0-9a-f]{6}$");
define constant $passportid-re :: <regex> = compile-regex("^[0-9]{9}$");

define function always-valid(val :: <string>) #t end function always-valid;
define function never-valid(val :: <string>) #f end function never-valid;


define function validate-is-integer-between(lower :: <integer>, upper :: <integer>)
  method(str :: <string>)
    block (finished)
      if(size(str) = 0)
        finished(#f)
      end if;
      let val = string-to-integer(str);
      if(val < lower | val > upper)
        finished(#f)
      end if;
      #t
    end block
  end method
end function validate-is-integer-between;

define function validate-height()
  method(str :: <string>)
    block (finished)
      if(size(str) = 0)
        finished(#f)
      end if;

      let val = string-to-integer(str);
      if(ends-with?(str, "cm"))
        finished(val >= 150 & val <= 193);
      end if;
      if(ends-with?(str, "in"))
        finished(val >= 59 & val <= 87);
      end if;
      #f
    end block
  end method
end function validate-height;

define function validate-eyecolor()
  method(str :: <string>)
    str = "amb" |
    str = "blu" |
    str = "brn" |
    str = "gry" |
    str = "grn" |
    str = "hzl" |
    str = "oth"
  end method
end function validate-eyecolor;

define function validate-matches-regex(re :: <regex>)
  method(str :: <string>)
    let match :: false-or(<regex-match>) = regex-search(re, str);
    if(match == #f)
      #f
    else
      #t
    end if
  end method
end function validate-matches-regex;


define function validate-passport-field
    (field :: <string>, value :: <string>, validators :: <string-table>)

  let validator = element(validators, field, default: never-valid);
  validator(value)
end function validate-passport-field;


define function validate-passport-block
    (passport-block :: <vector>, validators :: <string-table>)

    // this assumes fields aren't repeated...
    let valid-fields = 0;
    for (i :: <integer> from 0 to size(passport-block) - 1)
      let line = passport-block[i];
      let kvs = split(line, " ");
      for(kvi :: <integer> from 0 to size(kvs) - 1)
        
        let kv = split(kvs[kvi], ":");
        // we ignore cid here, since it doesn't contribute to the valid field count requirement
        if (kv[0] ~= "cid" & validate-passport-field(kv[0], kv[1], validators))
          valid-fields := valid-fields + 1;
        end if;
      end for;
    end for;

    valid-fields = 7;
end validate-passport-block;

define function split-passport-blocks
    (lines :: <vector>)

  let blocks = make(<vector>, of: <vector>);

  let start-idx = 0;
  for (i :: <integer> from 0 to size(lines) - 1)
    if(size(lines[i]) == 0)
      let passport-block = copy-sequence(lines, start: start-idx, end: i);
      blocks := add(blocks, passport-block);
      start-idx := i + 1;
    end if;
  end for;

  let passport-block = copy-sequence(lines, start: start-idx);
  blocks := add(blocks, passport-block);
  blocks
end function split-passport-blocks;

define function count-valid(seq)
  reduce(
    method(acc, valid) 
      if (valid)
        acc + 1
      else
        acc
      end if;
    end method,
    0,
    seq)
end function count-valid;

define constant *part1-validators* = block()
  let validators = make(<string-table>);
  validators["byr"] := always-valid;
  validators["iyr"] := always-valid;
  validators["eyr"] := always-valid;
  validators["hgt"] := always-valid;
  validators["hcl"] := always-valid;
  validators["ecl"] := always-valid;
  validators["pid"] := always-valid;
  validators["cid"] := always-valid;
  validators
end block;

define constant *part2-validators* = block()
  let validators = make(<string-table>);
  validators["byr"] := validate-is-integer-between(1920, 2002);
  validators["iyr"] := validate-is-integer-between(2010, 2020);
  validators["eyr"] := validate-is-integer-between(2020, 2030);
  validators["hgt"] := validate-height();
  validators["hcl"] := validate-matches-regex($haircolor-re);
  validators["ecl"] := validate-eyecolor();
  validators["pid"] := validate-matches-regex($passportid-re);
  validators["cid"] := always-valid;
  validators
end block;

define function validate-passport-blocks
    (passport-blocks :: <vector>, validators :: <string-table>)

    let valid-block = method(passport-block)
        validate-passport-block(passport-block, validators)
      end method;

  count-valid(map(valid-block, passport-blocks));
end validate-passport-blocks;

define function part1
    (passport-blocks :: <vector>)
  format-out("part1: %d valid\n", validate-passport-blocks(passport-blocks, *part1-validators*));
end function part1;

define function part2
    (passport-blocks :: <vector>)
  format-out("part2: %d valid\n", validate-passport-blocks(passport-blocks, *part2-validators*));
end function part2;

define function main
    (name :: <string>, arguments :: <vector>)

  let lines = make(<vector>, of: <string>);

  until(stream-at-end?(*standard-input*))
    let line = read-line(*standard-input*);
    lines := add(lines, line)
  end until;

  let passports-blocks = split-passport-blocks(lines);
  part1(passports-blocks);
  part2(passports-blocks);

  exit-application(0);
end function main;

main(application-name(), application-arguments());
