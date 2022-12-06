-- scratchpad for creating the solution
create or replace synonym input_data for day05_example;

select * from input_data;

-- quick group to separate data from instructions
with g as (
  select lineno,linevalue
    , sum(nvl2(linevalue,0,1)) over (order by lineno) grouping
  from input_data
)
select *
from g;

/*
    [D]
[N] [C]
[Z] [M] [P]
 1   2   3

what if we flip it? something like:
[...
1ZN
[...
[...
2MCD
[...
[...
3P
[...

how to do that?
*/
-- create a view so I can focus on the idea
create or replace view group0 as
select lineno, linevalue from (
  select lineno,linevalue
    , sum(nvl2(linevalue,0,1)) over (order by lineno) grouping
  from input_data
) where grouping = 0
/
select * from group0 order by lineno desc;
