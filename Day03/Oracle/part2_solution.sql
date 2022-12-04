-- Sample
create or replace synonym input_data for day03_part1;

with rucksacks as (
    select
      mod(lineno,3) rucksack_id
      , trunc((lineno-1)/3) rucksack_group
      , linevalue rucksack_contents
    from input_data
  )
, items as (
    select r.rucksack_id, r.rucksack_group, i.item_type
    from rucksacks r
      ,lateral(select column_value item_type from table(string2rows(r.rucksack_contents))) i
  )
, types_in_container_groups as (
    select unique i1.rucksack_group, i1.item_type
    from items i1
    where i1.rucksack_id = 0
      and (i1.rucksack_group, i1.item_type) in (
        select i2.rucksack_group, i2.item_type
        from items i2
        where i2.rucksack_id = 1
          and (i2.rucksack_group, i2.item_type) in (
            select i3.rucksack_group, i3.item_type
            from items i3
            where rucksack_id = 2
          )
      )
  )
, group_priorities as (
    select 
      rucksack_group
      , case when lower(item_type) = item_type
          then ascii(item_type) - ascii('a') + 1
          else ascii(item_type) - ascii('A') + 1 + 26
        end priority
    from types_in_container_groups
  )
select sum(priority) from group_priorities
/
