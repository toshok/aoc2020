Module: day4
Synopsis: 
Author: 
Copyright: 

define constant <passport> = <string-table>;

define function is-valid-part1? (p :: <passport> ) => (boolean)
  element(p, "byr", default: "") ~= "" & // (Birth Year)
  element(p, "iyr", default: "") ~= "" & // (Issue Year)
  element(p, "eyr", default: "") ~= "" & // (Expiration Year)
  element(p, "hgt", default: "") ~= "" & // (Height)
  element(p, "hcl", default: "") ~= "" & // (Hair Color)
  element(p, "ecl", default: "") ~= "" & // (Eye Color)
  element(p, "pid", default: "") ~= "" & // (Passport ID)
  #t //element(p, "cid", default: "") ~= ""   // (Country ID)
end function is-valid-part1?;

define function is-integer-between(str :: <string>, lower :: <integer>, upper :: <integer>) => (boolean)
  block (finished)
    if(size(str) = 0)
      finished(#f)
    end if;
    let val = string-to-integer(str);
    if(val < lower | val > upper)
      finished(#f)
    end if;
    #t
  end
end function is-integer-between;

define function is-valid-height(str :: <string>) => (boolean)
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
  end
end function is-valid-height;

define function is-valid-eyecolor(str :: <string>) => (boolean)
  str = "amb" |
  str = "blu" |
  str = "brn" |
  str = "gry" |
  str = "grn" |
  str = "hzl" |
  str = "oth"
end function is-valid-eyecolor;

define constant $haircolor-re :: <regex> = compile-regex("^#[0-9a-f]{6}$");
define constant $passportid-re :: <regex> = compile-regex("^[0-9]{9}$");

define function matches-regex(str :: <string>, re :: <regex>) => (boolean)
  let match :: false-or(<regex-match>) = regex-search(re, str);
  if(match == #f)
    #f
  else
    #t
  end if
end function matches-regex;

define function is-valid-part2? (p :: <passport> ) => (boolean)
  block (finished)
    is-integer-between(element(p, "byr", default: ""), 1920, 2002) &
    is-integer-between(element(p, "iyr", default: ""), 2010, 2020) &
    is-integer-between(element(p, "eyr", default: ""), 2020, 2030) &
    is-valid-height(element(p, "hgt", default: "")) &
    matches-regex(element(p, "hcl", default: ""), $haircolor-re) &
    is-valid-eyecolor(element(p, "ecl", default: "")) &
    matches-regex(element(p, "pid", default: ""), $passportid-re) &
    #t //element(p, "cid", default: "") ~= ""   // (Country ID)
  end
end function is-valid-part2?;


define function parse-passports
    (lines :: <vector>)

  let passports = make(<vector>, of: <passport>);

  let p = make(<passport>);

  for (i :: <integer> from 0 to size(lines) - 1)
    let l = lines[i];
    if(size(lines[i]) == 0)
      passports := add(passports, p);
      p := make(<passport>);
    else

      let kvs = split(l, " ");
      for(kvi :: <integer> from 0 to size(kvs) - 1)
        let kv = split(kvs[kvi], ":");
        element-setter(kv[1], p, kv[0]);
      end for;
    end if;
  end for;

  passports := add(passports, p);

  passports
end function parse-passports;

define function part1
    (passports :: <vector>)

  let valid = 0;
  let invalid = 0;

  for (i :: <integer> from 0 to size(passports) - 1)
    if(is-valid-part1?(passports[i]))
      valid := valid + 1;
    else
      invalid := invalid + 1;
    end if;
  end for;

  format-out("part1: %d valid, %d invalid\n", valid, invalid)
end function part1;

define function part2
    (passports :: <vector>)

  let valid = 0;
  let invalid = 0;

  for (i :: <integer> from 0 to size(passports) - 1)
    if(is-valid-part2?(passports[i]))
      valid := valid + 1;
    else
      invalid := invalid + 1;
    end if;
  end for;

  format-out("part2: %d valid, %d invalid\n", valid, invalid)
end function part2;

define function main
    (name :: <string>, arguments :: <vector>)

  let lines = make(<vector>, of: <string>);

  until(stream-at-end?(*standard-input*))
    let line = read-line(*standard-input*);
    lines := add(lines, line)
  end until;

  let passports = parse-passports(lines);

  part1(passports);
  part2(passports);

  exit-application(0);
end function main;

main(application-name(), application-arguments());
