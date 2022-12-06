-- Sample
create or replace synonym input_data for day04_part1;

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
select count(
   case when
            (elf1section1 > elf2section2) -- ..elf2..elf1..
        or  (elf1section2 < elf2section1) -- ..elf1..elf2..
     then null  -- no overlap, so don't count
     else 1
   end)
from assignment_pairs
/
