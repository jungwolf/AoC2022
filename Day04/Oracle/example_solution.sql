-- Sample
create or replace synonym input_data for day04_example;

with delimitor_positions as (
    select instr(linevalue,'-') dash1
      ,instr(linevalue,',') comma
      ,instr(linevalue,'-',1,2) dash2
      ,linevalue
    from input_data
  )
, assignment_pairs as (
    select
      substr(linevalue,1,dash1-1) elf1section1
      ,substr(linevalue,dash1+1,comma-dash1-1) elf1section2
      ,substr(linevalue,comma+1,dash2-comma-1) elf2section1
      ,substr(linevalue,dash2+1) elf2section2
    from delimitor_positions
  )
select count(*)
from assignment_pairs
where ( (elf1section1 >= elf2section1) and (elf1section2 <= elf2section2) )
  or  ( (elf1section1 <= elf2section1) and (elf1section2 >= elf2section2) )
/
