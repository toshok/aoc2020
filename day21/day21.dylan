Module: day21
Synopsis: 
Author: 
Copyright: 

define function part2
    (ingredients-by-allergens :: <string-table>)

  block(finished)
    while(#t)
      block(start-over)
        let changed = #f;
        for (allergen in ingredients-by-allergens.key-sequence)
          if (size(ingredients-by-allergens[allergen]) = 1)
            let ingredient-to-remove = first(ingredients-by-allergens[allergen].key-sequence);
            for (allergen2 in ingredients-by-allergens.key-sequence)
              block(continue)
                if (allergen = allergen2)
                  format-out("skipping, since %s = %s\n", allergen, allergen2);
                  force-out();
                  continue();
                end if;
                format-out("ensuring %s isn't listed in ingredients for allergen %s\n", ingredient-to-remove, allergen2);
                force-out();
                changed := changed | remove-key!(ingredients-by-allergens[allergen2], ingredient-to-remove);
              end block;          
            end for;
          end if;
        end for;

        if (changed)
          start-over();
        else
          finished();
        end if;
      end block;
    end while;
  end block;

  // since we're here, we know that the lists should be 1 element only.
  for (allergen in ingredients-by-allergens.key-sequence)
    format-out("the following ingredients DO contain %s:", allergen);
    for (ingredient in ingredients-by-allergens[allergen].key-sequence)
      format-out(" %s", ingredient)
    end for;
    format-out("\n");
  end for;

  let sorted-order = sort(ingredients-by-allergens.key-sequence);
  format-out("part2: %s\n", join(
      map(
        method (allergen)
          first(ingredients-by-allergens[allergen].key-sequence)
        end method,
        sorted-order),
      ","));
end function part2;

define function part1
    (lines :: <vector>)

  let ingredients-by-allergens = make(<string-table>); // string -> another table.  those ingredients that may contain allergens
  let ingredient-names = make(<string-table>); // string -> #t, just to dedup ingredient names

  for (line in lines)
    let s1 = split(line, " (contains ");
    let allergens = #[];
    if (size(s1) > 1)
      allergens := split(s1[1], ", ");
      allergens[size(allergens) - 1] := copy-sequence(last(allergens), start: 0, end: size(last(allergens)) - 1);
    end if;

    let ingredients = split(s1[0], " ");

    // ensure we have names for all ingredients
    for (ingredient in ingredients)
      ingredient-names[ingredient] := #t;
    end for;

    for (a in allergens)
      // ensure we have a table for that allergen.
      if (~element(ingredients-by-allergens, a, default: #f))
        // if we didn't previously have a table, make one and fill in our allergens
        ingredients-by-allergens[a] := make(<string-table>);
        for (ingredient in ingredients)
          ingredients-by-allergens[a][ingredient] := #t;
        end for;
      else
        ingredients-by-allergens[a] := intersect-ingredients(ingredients-by-allergens[a], ingredients);
      end if;
    end for;
  end for;

  format-out("done parsing/intersections\n");

  for (allergen in ingredients-by-allergens.key-sequence)
    format-out("the following ingredients MAY contain %s:", allergen);
    for (ingredient in ingredients-by-allergens[allergen].key-sequence)
      format-out(" %s", ingredient)
    end for;
    format-out("\n");
  end for;

  let can-never-contain-allergen = make(<string-table>);
  format-out("the following ingredients can never contain allergens:\n");
  force-out();
  for (ingredient in ingredient-names.key-sequence)
    block(continue)
      for (allergen in ingredients-by-allergens.key-sequence)
        if (element(ingredients-by-allergens[allergen], ingredient, default: #f))
          continue();
        end if;
      end for;

      format-out("  %s\n", ingredient);
      can-never-contain-allergen[ingredient] := #t;
    end block;
  end for;

  // do another pass over the lines and count those can-never-contain-allergen's
  let count = 0;
  for (line in lines)
    let s1 = split(line, " (contains ");
    let ingredients = split(s1[0], " ");
    for (ingredient in ingredients)
      if (element(can-never-contain-allergen, ingredient, default: #f))
        count := count + 1;
      end if;
    end for;
  end for;

  format-out("part1: %d\n", count);
  ingredients-by-allergens
end function part1;

define function intersect-ingredients(ingredients-table, ingredients)
  let rv = make(<string-table>);
  for (ingredient in ingredients)
    if (element(ingredients-table, ingredient, default: #f))
      rv[ingredient] := #t;
    end if;
  end for;
  rv
end function intersect-ingredients;

define function main
    (name :: <string>, arguments :: <vector>)

  let lines = make(<vector>, of: <string>);
  until(stream-at-end?(*standard-input*))
    let line = read-line(*standard-input*);
    lines := add(lines, line);
  end until;

  let ingredients-by-allergen = part1(lines);
  part2(ingredients-by-allergen);

  exit-application(0);
end function main;

main(application-name(), application-arguments());
