-- building on view created during sample solution
--  calories_by_elf

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
