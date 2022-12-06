-- Sample
create or replace synonym input_data for day04_part1;

--In how many assignment pairs do the ranges overlap?

with delimitor_positions as (
    select instr(linevalue,'-') dash1
      ,instr(linevalue,',') comma
      ,instr(linevalue,'-',1,2) dash2
      ,linevalue
    from input_data
  )
, assignment_pairs as (
    select
       to_number(substr(linevalue,1,dash1-1))             elf1section1
      ,to_number(substr(linevalue,dash1+1,comma-dash1-1)) elf1section2
      ,to_number(substr(linevalue,comma+1,dash2-comma-1)) elf2section1
      ,to_number(substr(linevalue,dash2+1))               elf2section2
    from delimitor_positions
  )
select count(*)
from assignment_pairs
where ( (elf1section1 >= elf2section1) and (elf1section2 <= elf2section2) )
  or  ( (elf1section1 <= elf2section1) and (elf1section2 >= elf2section2) )
/
/*
cases
..a..b..
......yz

..a..b..
...y...z

..a..b..
...yz...

..a..b..
.y.....z

..a..b..
.y..z...

..a..b..
yz......

Ahh, no overlap if b<y or a>z
*/
-- oh, this is number that don't overlap
with delimitor_positions as (
    select instr(linevalue,'-') dash1
      ,instr(linevalue,',') comma
      ,instr(linevalue,'-',1,2) dash2
      ,linevalue
    from input_data
  )
, assignment_pairs as (
    select
       to_number(substr(linevalue,1,dash1-1))             elf1section1
      ,to_number(substr(linevalue,dash1+1,comma-dash1-1)) elf1section2
      ,to_number(substr(linevalue,comma+1,dash2-comma-1)) elf2section1
      ,to_number(substr(linevalue,dash2+1))               elf2section2
    from delimitor_positions
  )
select count(*)
from assignment_pairs
where (elf1section1 > elf2section2)
  or  (elf1section2 < elf2section1)
/

with delimitor_positions as (
    select instr(linevalue,'-') dash1
      ,instr(linevalue,',') comma
      ,instr(linevalue,'-',1,2) dash2
      ,linevalue
    from input_data
  )
, assignment_pairs as (
    select
       to_number(substr(linevalue,1,dash1-1))             elf1section1
      ,to_number(substr(linevalue,dash1+1,comma-dash1-1)) elf1section2
      ,to_number(substr(linevalue,comma+1,dash2-comma-1)) elf2section1
      ,to_number(substr(linevalue,dash2+1))               elf2section2
    from delimitor_positions
  )
select count( case when (elf1section1 > elf2section2) or  (elf1section2 < elf2section1) then null else 1 end)
from assignment_pairs
/
