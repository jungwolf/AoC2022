-- review elves
select
  elf
  ,sum(calories) total_calories
from calories_by_elf
group by elf
/

-- find three elves!
select
  elf
  ,sum(calories) total_calories
from calories_by_elf
group by elf
order by total_calories desc
  fetch first 3 rows only
/

-- are we not prepared?
select sum(total_calories) total_calories from (
  select
    elf
    ,sum(calories) total_calories
  from calories_by_elf
  group by elf
  order by total_calories desc
    fetch first 3 rows only
)
/
