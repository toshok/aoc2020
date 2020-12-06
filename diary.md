
# day1

* Why did I pick dylan?  I can't get anything to work. lots of files, long command names.  tonight we dine in Makefile hell.
* I should really figure out if vscode has support for dylan.  not enjoying the vim life.
* re: dylan, weird separation of code from imports.  `use` things inside library.dylan?  I'm not building a library.  why are there two sets of use there?
  there's no clear signal that I've seen for what needs to be `use`d to make symbols accessible.  docs feel like I have to read prose to figure
  it out.  speaking of docs, don't get me started.
* ok _finally_ landed on a formulation of parsing the input file that worked, after beating my head against `with-open-file` for hours.  after that it was easy:
    1. figure out how to convert a string to integer.  `string-to-integer`, duh.
    2. write the doubly nested loop


# day2

* okay, _much_ faster tonight than last.  last night was 2+ hours for part 1.  tonight was 15 minutes of not 100% attention.
* Some twitter answers from Carl about `library.dylan` cleared a _whole_ bunch up wrt how to add libraries/modules.  Added one for this problem (library/module = strings/strings) when I was writing the code, not after furiously googling when something didn't work.
* used vscode.  Massive improvement over vi.  That said, emacs might be better.  then I have `M-x compile` and can build/test without leaving the editor.
* this was a pretty quick problem but I wonder if I'm not taking the time to figure out the most dylan way to go about writing it up..
  * read problem description and it boiled down to two things (spoilers ahead?):
    "how do I split a line at a character?" and "how do I iterate/access characters in a string?"
  * used `split` and `count-substrings`
  * going to chalk this up as an attempt to be reasonably fast (not top of leaderboard but wayyyyy faster) and to shake out major fundamental problems.

# day3

* tried getting fancy with a `block()` but ultimately didn't need it.  shame, I like the signal when reading code "WHOA THERE'S AN EARLY RETURN IN HERE".
* frustrated by compiler error for this code:
```dylan
  for (i :: <integer> from 0 to size(lines) - 1 by down)
    let line = lines[i];
    if(line[x] == '#')
      trees := trees + 1;
    end fi;
    x := x + right;
    x := modulo(x, size(line));
  end for;
```

The error was:

```
/Users/toshok/src/aoc2020/day3/day3.dylan:12.5-17.32: Serious warning - Invalid syntax for fbody in for macro call.
          --------------------
  12      let line = lines[i];
  13      if(line[x] == '#')
  14        trees := trees + 1;
  15      end fi;
  16      x := x + right;
  17      x := modulo(x, size(line));
      -------------------------------
```

Which... not the most helpful.  Anyway, it's that line 15 there.  `end fi;` should be `end if;`  Found the usual way:  comment out everything and introduce bits at a time.
* new dylan learned:
  * `modulo` is a function.  `x % y` === `modulo(x, y)`.
  * `by <value>` in for loops.  e.g. `for (i :: <integer> from 0 to size(lines) - 1 by down)` ~= `for (let i = 0; i <= sizeof(lines) - 1; i += down)`

# day6

* finally figured out that I can replace
```dylan
  for (i :: <integer> from 0 to size(group) - 1)
    let line = group[i];
```

with

```dylan
  for (line in group)
```

rejoice.

* can't find any documentation on how to subclass `<table>`.  time to grovel in opendylan source.
* also can't figure out if there's an easy way to convert a `<character>` to a `<string>`.  I presume there is, but...
* I would _kill_ for backtraces to include line numbers:

```
{<string-table>: size 0} is not of type {<class>: <string>}
Backtrace:
  invoke-debugger:internal:dylan##1 + 0x29
  default-handler:dylan:dylan##1 + 0x12
  default-last-handler:common-dylan-internals:common-dylan##0 + 0x2a3
  error:dylan:dylan##0 + 0x26
  type-check-error:internal:dylan + 0x6d
  gethash:internal:dylan + 0x11c
  count-all-yes:day6:day6 + 0x1cb
  map-as-one:internal:dylan##5 + 0x5e
  part2:day6:day6 + 0x4a
  main:day6:day6 + 0xeb
  main + 0x19
```

maybe I'm missing compiler args? (debug info?)
