-- part2 uses same data
create or replace synonym input_data for day02_part1;

with rps_games(elf_move,my_move) as (
    select substr(linevalue,1,1) elf_move, substr(linevalue,3,1) my_move
    from input_data
  )
, rps_games_translated (elf_revealed, my_goal) as (
    select
      translate(elf_move,'ABC','RPS') elf_revealed
      , translate(my_move,'XYZ','LTW') my_goal
    from rps_games
  )
, move_points (move, points) as (
              select 'R', 1 from dual
    union all select 'P', 2 from dual
    union all select 'S', 3 from dual
  )
, game_rules (first_move, second_move, outcome) as (
              select 'R', 'R', 'T' from dual
    union all select 'P', 'R', 'L' from dual
    union all select 'S', 'R', 'W' from dual
    union all select 'R', 'P', 'W' from dual
    union all select 'P', 'P', 'T' from dual
    union all select 'S', 'P', 'L' from dual
    union all select 'R', 'S', 'L' from dual
    union all select 'P', 'S', 'W' from dual
    union all select 'S', 'S', 'T' from dual
  )
, outcome_points (outcome, points) as (
              select 'L', 0 from dual
    union all select 'T', 3 from dual
    union all select 'W', 6 from dual
  )
, game_session as (
  select g.elf_revealed, g.my_goal, r.second_move, s.points move_points, r.outcome, o.points outcome_points
  from rps_games_translated g
    , move_points s
    , game_rules r
    , outcome_points o
  where g.elf_revealed = r.first_move
    and g.my_goal = r.outcome
    and r.second_move = s.move
    and r.outcome = o.outcome
  )
select sum(gs.move_points+gs.outcome_points) total_points
from game_session gs
/

/* 
I basically refactored the part1 solution to use RTL and WTL notation.
The fiendly elf note is a code-- I need a translation view to find out the meaning.
For part1, the opposing elf instructions are 'ABC' for moves 'RPS'. My instractions are 'XYZ' to moves 'RPS'.

After the refactor, most of the work is changing the translator view and changing the joins.

rps_games:
  Splits input to two columns. For example:
  'A X' to ('A','X')

rps_games_translated:
  Lookup table. The first column translates into 'RPS' moves. The second column now represents the desired game outcome.

game_rules:
  Another lookup table. Elf plays this, I play that, here is the outcome.

outcome_points:
  Yet another lookup table.

move_points:
  Lookup table for how many points I get for using a shape.

game_session:
  Each input line is a "game" so the full thing is a game session. Does all the lookups.
  For each row in rps_games
    join original code to rps_games_translated to find the real message: elf move and my desired outcome.
      for example ('A','Y') -> ('R','T') or Elf makes a rock, I want a Tie.
    join elf move and desired outcome to the game_rules to find what move to make. ('R','T') -> need to play 'R'
    join my move to move_points to find how many points the shape earns
    join game outcome to outcome_points to find how many point the win/tie/loss earns

Final step, move_points+outcome_points= total points for the game.
Use aggregate sum() to get the final answer.

*/
