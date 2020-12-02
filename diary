
day1:

* Why did I pick dylan?  I can't get anything to work. lots of files, long command names.  tonight we dine in Makefile hell.
* I should really figure out if vscode has support for dylan.  not enjoying the vim life.
* re: dylan, weird separation of code from imports.  "use" things inside library.dylan?  I'm not building a library.  why are there two sets of use there?
  there's no clear signal that I've seen for what needs to be "used" to make symbols accessible.  docs feel like I have to read prose to figure
  it out.  speaking of docs, don't get me started.
* ok _finally_ landed on a formulation of parsing the input file that worked, after beating my head against with-open-file for hours.  after that it was easy:
    1. figure out how to convert a string to integer.  string-to-integer, duh.
    2. write the doubly nested loop


day2:

* okay, _much_ faster tonight than last.  last night was 2+ hours for part 1.  tonight was 15 minutes of not 100% attention.
* Some twitter answers from Carl about library.dylan cleared a _whole_ bunch up wrt how to add libraries/modules.  Added one for this problem (library/module = strings/strings) when I was writing the code, not after furiously googling when something didn't work.
* used vscode.  Massive improvement over vi.  That said, emacs might be better.  then I have `M-x compile` and can build/test without leaving the editor.
* this was a pretty quick problem but I wonder if I'm not taking the time to figure out the most dylan way to go about writing it up..
  * read problem description and it boiled down to two things (spoilers ahead?):
    "how do I split a line at a character?" and "how do I iterate/access characters in a string?"
  * used `split` and `count-substrings`
  * going to chalk this up as an attempt to be reasonably fast (not top of leaderboard but wayyyyy faster) and to shake out major fundamental problems.
