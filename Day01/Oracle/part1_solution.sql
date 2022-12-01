-- load input data like normal, including synonym change.
-- no change from example soution.

-- not needed, still exists from example solution
/*
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
*/

select elf from (
  select
    elf
    ,sum(calories) total_calories
  from calories_by_elf
  group by elf
  order by total_calories desc
    fetch first 1 rows only
)
/
--123
