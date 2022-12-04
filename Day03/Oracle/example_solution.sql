create or replace synonym input_data for day03_example;

with rucksacks as (
    select
      lineno rucksack_id
      , linevalue rucksack_contents
      , length(linevalue)/2 container_size
    from input_data
  )
, items as (
    select r.rucksack_id, trunc((i.item_id-1)/r.container_size) container_id, i.item_type
    from rucksacks r
      ,lateral(select rownum item_id, column_value item_type from table(string2rows(r.rucksack_contents))) i
  )
, types_in_both_containers as (
    select unique rucksack_id, container_id, item_type
    from items
    where container_id = 0
      and (rucksack_id, item_type) in (
        select rucksack_id, item_type
        from items
        where container_id = 1
      )
  )
, rucksacks_priorities as (
    select 
      rucksack_id
      , case when lower(item_type) = item_type
          then ascii(item_type) - ascii('a') + 1
          else ascii(item_type) - ascii('A') + 1 + 26
        end priority
    from types_in_both_containers
  )
select sum(priority) from rucksacks_priorities
/
-- 157