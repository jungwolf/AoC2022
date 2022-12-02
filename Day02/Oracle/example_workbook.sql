-- scratchpad for creating the solution
create or replace synonym input_data for day02_example;
select * from input_data;

/* old game of rock/paper/scissors
rock beats scissors, scissors beat paper, and paper beats rock

TheirMove MyMove
A Y
B X
C Z
A,X -> rock
B,Y -> paper
C,Z -> scissors

Scoring for game win
lose -> 0
draw -> 3
win  -> 6

Scoring for game move
X -> 1
Y -> 2
Z -> 3

Score for game = game win + game move

output matrix
A X -> R R -> tie
B X -> P R -> loss
C X -> S R -> win
A Y -> R P -> win
B Y -> P P -> tie
C Y -> S P -> loss
A Z -> R S -> loss
B Z -> P S -> win
C Z -> S S -> tie

hmm
R R -> tie
P R -> loss
S R -> win
R P -> win
P P -> tie
S P -> loss
R S -> loss
P S -> win
S S -> tie


*/
select substr(linevalue,1,1) elf_move, substr(linevalue,3,1) my_move
from input_data
/

/* going heavy on with clause */

-- checking syntax
with move_score (the_move, the_score) as (
            select 'X', 1 the_score from dual
  union all select 'Y', 2 the_score from dual
  union all select 'Z', 3 the_score from dual
)
select substr(linevalue,1,1) elf_move, substr(linevalue,3,1) my_move
from input_data
/

/*
-- whoops, forgot column aliases are not assigned until output...
-- rewrite
with move_score (the_move, the_score) as
  (select 'X', 1 the_score from dual
   union all select 'Y', 2 the_score from dual
   union all select 'Z', 3 the_score from dual
  )
select
  substr(i.linevalue,1,1) elf_move
  , substr(i.linevalue,3,1) my_move
  , m.the_score
from input_data i
  , move_score m
where i.my_move = m.the_move
/
*/

-- make base input a view
with rps_games(elf_move,my_move) as (
  select substr(linevalue,1,1) elf_move, substr(linevalue,3,1) my_move
  from input_data
)
select * from rps_games
/

-- add points received for a move, check syntax for game_rules
with rps_games(elf_move,my_move) as (
    select substr(linevalue,1,1) elf_move, substr(linevalue,3,1) my_move
    from input_data
  )
, move_points (move, points) as (
              select 'X', 1 from dual
    union all select 'Y', 2 from dual
    union all select 'Z', 3 from dual
  )
, game_rules (first_move, second_move, outcome) as (
              select 'A', 'X', 'TIE'  from dual
    union all select 'B', 'X', 'LOSS' from dual
    union all select 'C', 'X', 'WIN'  from dual
    union all select 'A', 'Y', 'WIN'  from dual
    union all select 'B', 'Y', 'TIE'  from dual
    union all select 'C', 'Y', 'LOSS' from dual
    union all select 'A', 'Z', 'LOSS' from dual
    union all select 'B', 'Z', 'WIN'  from dual
    union all select 'C', 'Z', 'TIE'  from dual
  )
select g.elf_move, g.my_move, s.points
from rps_games g
  , move_points s
where g.my_move = s.move
/

-- join with game rules
with rps_games(elf_move,my_move) as (
    select substr(linevalue,1,1) elf_move, substr(linevalue,3,1) my_move
    from input_data
  )
, move_points (move, points) as (
              select 'X', 1 from dual
    union all select 'Y', 2 from dual
    union all select 'Z', 3 from dual
  )
, game_rules (first_move, second_move, outcome) as (
              select 'A', 'X', 'TIE'  from dual
    union all select 'B', 'X', 'LOSS' from dual
    union all select 'C', 'X', 'WIN'  from dual
    union all select 'A', 'Y', 'WIN'  from dual
    union all select 'B', 'Y', 'TIE'  from dual
    union all select 'C', 'Y', 'LOSS' from dual
    union all select 'A', 'Z', 'LOSS' from dual
    union all select 'B', 'Z', 'WIN'  from dual
    union all select 'C', 'Z', 'TIE'  from dual
  )
select g.elf_move, g.my_move, s.points, r.outcome
from rps_games g
  , move_points s
  , game_rules r
where g.my_move = s.move
  and g.elf_move = r.first_move
  and g.my_move = r.second_move
/



-- add in win values
with rps_games(elf_move,my_move) as (
    select substr(linevalue,1,1) elf_move, substr(linevalue,3,1) my_move
    from input_data
  )
, move_points (move, points) as (
              select 'X', 1 from dual
    union all select 'Y', 2 from dual
    union all select 'Z', 3 from dual
  )
, game_rules (first_move, second_move, outcome) as (
              select 'A', 'X', 'TIE'  from dual
    union all select 'B', 'X', 'LOSS' from dual
    union all select 'C', 'X', 'WIN'  from dual
    union all select 'A', 'Y', 'WIN'  from dual
    union all select 'B', 'Y', 'TIE'  from dual
    union all select 'C', 'Y', 'LOSS' from dual
    union all select 'A', 'Z', 'LOSS' from dual
    union all select 'B', 'Z', 'WIN'  from dual
    union all select 'C', 'Z', 'TIE'  from dual
  )
, outcome_points (outcome, points) as (
              select 'LOSS', 0 from dual
    union all select 'TIE',  3 from dual
    union all select 'WIN',  6 from dual
  )
select g.elf_move, g.my_move, s.points, r.outcome, o.points
from rps_games g
  , move_points s
  , game_rules r
  , outcome_points o
where g.my_move = s.move
  and g.elf_move = r.first_move
  and g.my_move = r.second_move
  and r.outcome = o.outcome
/



-- make it a game session
with rps_games(elf_move,my_move) as (
    select substr(linevalue,1,1) elf_move, substr(linevalue,3,1) my_move
    from input_data
  )
, move_points (move, points) as (
              select 'X', 1 from dual
    union all select 'Y', 2 from dual
    union all select 'Z', 3 from dual
  )
, game_rules (first_move, second_move, outcome) as (
              select 'A', 'X', 'TIE'  from dual
    union all select 'B', 'X', 'LOSS' from dual
    union all select 'C', 'X', 'WIN'  from dual
    union all select 'A', 'Y', 'WIN'  from dual
    union all select 'B', 'Y', 'TIE'  from dual
    union all select 'C', 'Y', 'LOSS' from dual
    union all select 'A', 'Z', 'LOSS' from dual
    union all select 'B', 'Z', 'WIN'  from dual
    union all select 'C', 'Z', 'TIE'  from dual
  )
, outcome_points (outcome, points) as (
              select 'LOSS', 0 from dual
    union all select 'TIE',  3 from dual
    union all select 'WIN',  6 from dual
  )
, game_session as (
  select g.elf_move, g.my_move, s.points move_points, r.outcome, o.points outcome_points
  from rps_games g
    , move_points s
    , game_rules r
    , outcome_points o
  where g.my_move = s.move
    and g.elf_move = r.first_move
    and g.my_move = r.second_move
    and r.outcome = o.outcome
  )
select gs.* from game_session gs
/



-- find total points for game session
with rps_games(elf_move,my_move) as (
    select substr(linevalue,1,1) elf_move, substr(linevalue,3,1) my_move
    from input_data
  )
, move_points (move, points) as (
              select 'X', 1 from dual
    union all select 'Y', 2 from dual
    union all select 'Z', 3 from dual
  )
, game_rules (first_move, second_move, outcome) as (
              select 'A', 'X', 'TIE'  from dual
    union all select 'B', 'X', 'LOSS' from dual
    union all select 'C', 'X', 'WIN'  from dual
    union all select 'A', 'Y', 'WIN'  from dual
    union all select 'B', 'Y', 'TIE'  from dual
    union all select 'C', 'Y', 'LOSS' from dual
    union all select 'A', 'Z', 'LOSS' from dual
    union all select 'B', 'Z', 'WIN'  from dual
    union all select 'C', 'Z', 'TIE'  from dual
  )
, outcome_points (outcome, points) as (
              select 'LOSS', 0 from dual
    union all select 'TIE',  3 from dual
    union all select 'WIN',  6 from dual
  )
, game_session as (
  select g.elf_move, g.my_move, s.points move_points, r.outcome, o.points outcome_points
  from rps_games g
    , move_points s
    , game_rules r
    , outcome_points o
  where g.my_move = s.move
    and g.elf_move = r.first_move
    and g.my_move = r.second_move
    and r.outcome = o.outcome
  )
select sum(gs.move_points+gs.outcome_points) total_points
from game_session gs
/



