-- renamed synonym to part 1 data
create or replace synonym input_data for day02_part1;

-- same query as example_solution
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



