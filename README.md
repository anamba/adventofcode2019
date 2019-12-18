# Advent of Code 2019

[Advent of Code 2019](https://adventofcode.com/2019) solutions (spoilers, obviously, if you're not caught up).

I'm trying [Elixir](https://elixir-lang.org/) this year ([last year](https://github.com/anamba/adventofcode2018) I used [Crystal](https://crystal-lang.org/)). It's a language I like a lot, but am not yet intimately familiar with. So some after-action thoughts follow.

## Day 1

* Decided to give doctests a try. Pretty great for TDD, which is how I do AoC. (I'll never place in the top 100, but when I'm done, I'm done, and I rarely submit wrong answers.) Especially great when paired with `mix_test_watch`.

## Day 3

* ~~Wish I'd known about MapSet! That probably would have made calculating intersections easier.~~ I'm still glad I learned about MapSet, but it doesn't allow duplicate values, which might make it a bad fit for this particular case.

## Day 4

* Was afraid my regex with backreferences might be slow, but the strings involved are so short it didn't matter.
* Forgot about the `:discard` option on `chunk_every`. Ack.
* Also forgot about `chunk_by(& &1)`/`group_by(& &1)`, even better.

## Day 6

* Knowing about `:digraph` would have made this a lot easier.

## Day 7

* Briefly considered going all in on processes and messages and all that, but ended up just making the fewest changes possible.
* Revised the following day to use processes, which turned out to require even fewer changes than avoiding processes! Ha.

## Day 11

* My program doesn't actually halt, but does give the right answer. Didn't have time to figure that out.

## Day 14

* Started to write something for Part 2, but ended up doing it manually.

## Day 15

* Did this one while watching TV. Turned in best rank yet. New strategy?

## Day 16

* Finished Part 1, but couldn't get Part 2. I basically failed linear algebra in college, but was saved by a pilot math program that averaged that grade out with a subject I grasped a little better. But that means I never did learn linear algebra.
* Finally assembled a solution for Part 2 a couple days later.

## Day 17

* Part 1 was very straightforward, but solved part 2 by hand. Kinda fun at first, but became tedious.
