-- part2 uses same data
create or replace synonym input_data for day02_part1;

-- start with first solution
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



-- change game rules to use RPS
--   change win/tie/loss to WTL
-- add a tranlate function for elf moves and my goals
-- change final logic to join the correct fiels
--   use translated elf move as first_move and my goal to find my move
with rps_games(elf_move,my_move) as (
    select substr(linevalue,1,1) elf_move, substr(linevalue,3,1) my_move
    from input_data
  )
, rps_games_translated (elf_revealed, my_goal)as (
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

