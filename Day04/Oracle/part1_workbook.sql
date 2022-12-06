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
-- didn't like it, too high

-- look at the raw output
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
      ,linevalue
    from delimitor_positions
  )
select a.*, case when ( (elf1section1 >= elf2section1) and (elf1section2 <= elf2section2) ) or  ( (elf1section1 <= elf2section1) and (elf1section2 >= elf2section2) )
            then 'TRUE'
            else 'FALSE'
            end tf
from assignment_pairs a
order by tf
/

-- look at the raw output
-- this one doesn't look right
with delimitor_positions as (
    select instr(linevalue,'-') dash1
      ,instr(linevalue,',') comma
      ,instr(linevalue,'-',1,2) dash2
      ,linevalue
    from input_data where linevalue = '11-15,7-10'
  )
, assignment_pairs as (
    select
      substr(linevalue,1,dash1-1) elf1section1
      ,substr(linevalue,dash1+1,comma-dash1-1) elf1section2
      ,substr(linevalue,comma+1,dash2-comma-1) elf2section1
      ,substr(linevalue,dash2+1) elf2section2
      ,linevalue
    from delimitor_positions
  )
select a.*, case
              when (( (elf1section1 >= elf2section1) and (elf1section2 <= elf2section2) )
               or   ( (elf1section1 <= elf2section1) and (elf1section2 >= elf2section2) ))
              then 'TRUE'
              else 'FALSE'
            end tf
from assignment_pairs a
order by tf
/
/*
when ( (elf1section1 >= elf2section1) and (elf1section2 <= elf2section2) )
 or  ( (elf1section1 <= elf2section1) and (elf1section2 >= elf2section2) )

when ( (11 >= 7) and (15 <= 10) ) .. TRUE  . FALSE
 or  ( (11 <= 7) and (15 >= 10) ) .. FALSE . TRUE
*/

select
   case when (11 >= 7) then 'T' else 'F' end
  ,case when (15 <= 10) then 'T' else 'F' end
  ,case when (11 <= 7) then 'T' else 'F' end
  ,case when (15 >= 10) then 'T' else 'F' end
from dual;

select
   case when ((11 >= 7) and (15 <= 10)) then 'T' else 'F' end
  ,case when ((11 <= 7) and (15 >= 10)) then 'T' else 'F' end
from dual;

select
   case when ((11 >= 7) and (15 <= 10)) or ((11 <= 7) and (15 >= 10)) then 'T' else 'F' end
from dual;

-- oh! silly types
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
