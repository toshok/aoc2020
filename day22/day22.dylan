Module: day22
Synopsis: 
Author: 
Copyright: 

define function dump-decks
    (player1-deck :: <deque>, player2-deck :: <deque>)

  format-out("Player 1's deck: %s\n", join(map(integer-to-string, player1-deck), ", "));
  format-out("Player 2's deck: %s\n", join(map(integer-to-string, player2-deck), ", "));
end function dump-decks;

define function calc-score
    (deck :: <deque>)

  let score = 0;
  for (i from size(deck) - 1 to 0 by -1)
    score := score + deck[i] * (size(deck) - i);
  end for;
  score
end function calc-score;

define function part1
    (player1-deck :: <deque>, player2-deck :: <deque>)

  let round = 1;
  while (size(player1-deck) > 0 & size(player2-deck) > 0)
    format-out("-- Round %d --\n", round);
    dump-decks(player1-deck, player2-deck);

    let player1-top = pop(player1-deck);
    let player2-top = pop(player2-deck);

    format-out("Player 1 plays: %d\n", player1-top);
    format-out("Player 2 plays: %d\n", player2-top);

    if (player1-top > player2-top)
      format-out("Player 1 wins the round!\n");
      push-last(player1-deck, player1-top);
      push-last(player1-deck, player2-top);
    else
      format-out("Player 2 wins the round!\n");
      push-last(player2-deck, player2-top);
      push-last(player2-deck, player1-top);
    end if;

    round := round + 1;
  end while;

  format-out("== Post-game results ==\n");
  dump-decks(player1-deck, player2-deck);

  let score = if (size(player1-deck) > 0)
    calc-score(player1-deck);
  else
    calc-score(player2-deck);
  end if;

  format-out("part1: %d\n", score);
end function part1;


define function recursive-combat
    (player1-deck :: <deque>, player2-deck :: <deque>)

    let configurations-played = make(<string-table>);
    block(game-won)
      let round = 1;
      while (size(player1-deck) > 0 & size(player2-deck) > 0)
        // format-out("-- Round %d --\n", round);
        // dump-decks(player1-deck, player2-deck);

        // check if we're in a previous played config
        let player1-score = calc-score(player1-deck);
        let player2-score = calc-score(player2-deck);
        let config-key = concatenate(integer-to-string(player1-score), "-", integer-to-string(player2-score));

        if (element(configurations-played, config-key, default: #f))
          game-won("player1");
        end if;

        configurations-played[config-key] := #t;

        let player1-top = pop(player1-deck);
        let player2-top = pop(player2-deck);

        // format-out("Player 1 plays: %d\n", player1-top);
        // format-out("Player 2 plays: %d\n", player2-top);

        let who-won = "neither-you-idiot";
        if (size(player1-deck) >= player1-top & size(player2-deck) >= player2-top)
          // play a recursive game to see who wins
          // format-out("Playing a sub-game to determine the winner...\n");
          who-won := recursive-combat(copy-sequence(player1-deck, end: player1-top), copy-sequence(player2-deck, end: player2-top));
        else
          who-won := if (player1-top > player2-top)
            // format-out("Player 1 wins the round!\n");
            "player1";
          else
            // format-out("Player 2 wins the round!\n");
            "player2";
          end if;
        end if;

        if (who-won = "player1")
          push-last(player1-deck, player1-top);
          push-last(player1-deck, player2-top);
        else
          push-last(player2-deck, player2-top);
          push-last(player2-deck, player1-top);
        end if;

        round := round + 1;
      end while;

      if (size(player1-deck) = 0)
        // format-out("The winner of the game is player 2!\n");
        "player2"
      else
        // format-out("The winner of the game is player 1!\n");
        "player1"
      end if;
    end block;
end function recursive-combat;

define function part2
    (player1-deck :: <deque>, player2-deck :: <deque>)

  let who-won = recursive-combat(player1-deck, player2-deck);

  dump-decks(player1-deck, player2-deck);

  format-out("part2: %d\n",
      if (who-won = "player1")
        calc-score(player1-deck)
      else
        calc-score(player2-deck)
      end if);
end function part2;

define function main
    (name :: <string>, arguments :: <vector>)

  let lines = make(<vector>, of: <string>);
  until(stream-at-end?(*standard-input*))
    let line = read-line(*standard-input*);
    lines := add(lines, line);
  end until;

  let player1-deck = make(<deque>);
  let player2-deck = make(<deque>);
  let idx = 1; // skip the first line since it's "Player 1"
  while (size(lines[idx]) > 0)
    push-last(player1-deck, string-to-integer(lines[idx]));
    idx := idx + 1;
  end while;

  idx := idx + 2;
  while (idx < size(lines) & size(lines[idx]) > 0)
    push-last(player2-deck, string-to-integer(lines[idx]));
    idx := idx + 1;
  end while;

  part1(copy-sequence(player1-deck), copy-sequence(player2-deck));
  part2(copy-sequence(player1-deck), copy-sequence(player2-deck));

  exit-application(0);
end function main;

main(application-name(), application-arguments());
