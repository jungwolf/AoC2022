-- scratchpad for creating the solution
create or replace synonym input_data for day04_example;

select * from input_data;

/*
Hmm, we'll want to turn the input into numeric values, at the least.
Old school string manipulation or split the lines into rows.
Old school. Wouldn't be surprised if we have to go the other way for part 2.
*/

-- simple example
select '2-4,6-8' from dual;

with input as (select '2-4,6-8' data from dual)
select instr(data,'-'), instr(data,','), instr(data,'-',1,2)
from input
/

with delimitor_positions as (
    select instr(linevalue,'-') dash1
      ,instr(linevalue,',') comma
      ,instr(linevalue,'-',1,2) dash2
      ,linevalue
    from input_data
  )
select * from delimitor_positions;


-- split into sections
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
select * from assignment_pairs;

-- now just find if one is contained in the other
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
select *
from assignment_pairs
where ( (elf1section1 >= elf2section1) and (elf1section2 <= elf2section2) )
  or  ( (elf1section1 <= elf2section1) and (elf1section2 >= elf2section2) )
/


-- count!
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
--2
