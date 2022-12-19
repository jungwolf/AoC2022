-- scratchpad for creating the solution
create or replace synonym input_data for day06_example;

select * from input_data;

-- input is only one line, the input data is multiple examples
-- so starting with one line
select 'mjqjpqmgbljsphdztnvjfqwrcgsmlb' from dual;

-- find the first substring of 4 with unique letters
