-- scratchpad for creating the solution
-- assign an elf to each group of calories
select * from input_data;

-- maybe use null to increment the count by 1
-- check lag, if it is null, add one else add 0
select 
  lineno
  ,linevalue
  ,lag(linevalue,1) over (order by lineno)
from input_data
/

-- give 0 if previous is null, 1 if previous is not null
select 
  lineno
  ,linevalue
  ,lag(linevalue,1) over (order by lineno) a1
  ,nvl2(lag(linevalue,1) over (order by lineno),0,1) a2
from input_data
/

-- create a running sum
select
  lineno
  , linevalue
  , sum(a2) over (order by lineno rows UNBOUNDED PRECEDING) part
from
  (select 
    lineno
    ,linevalue
    ,lag(linevalue,1) over (order by lineno) a1
    ,0 + nvl2(lag(linevalue,1) over (order by lineno),0,1) a2
   from input_data
  )
/

-- remove null lines
select
  lineno
  , linevalue
  , sum(a2) over (order by lineno rows UNBOUNDED PRECEDING) part
from
  (select 
    lineno
    ,linevalue
    ,lag(linevalue,1) over (order by lineno) a1
    ,0 + nvl2(lag(linevalue,1) over (order by lineno),0,1) a2
   from input_data
  )
where linevalue is not null
/

-------------------------------------------------------------------------------------------
-- final form
create view calories_by_elf as
select
  sum(a2) over (order by lineno rows UNBOUNDED PRECEDING) elf
  , linevalue calories
from
  (select 
    lineno
    ,linevalue
    ,lag(linevalue,1) over (order by lineno) a1
    ,0 + nvl2(lag(linevalue,1) over (order by lineno),0,1) a2
   from input_data
  )
where linevalue is not null
/
select * from calories_by_elf;
/*
elf	calories
1	1000
1	2000
1	3000
2	4000
3	5000
3	6000
4	7000
4	8000
4	9000
5	10000
*/
-------------------------------------------------------------------------------------------

