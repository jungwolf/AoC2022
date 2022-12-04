-- Sample
create or replace synonym input_data for day03_part1;

-- before I had to break each rucksack into 2 compartments
-- now I have basically 1 rucksack with 3 compartments

-- start with the old
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

-- don't need container size, do need rucksack group
with rucksacks as (
    select
      lineno rucksack_id
      , trunc((lineno-1)/3) rucksack_group
      , linevalue rucksack_contents
    from input_data
  )
select * from rucksacks
/

with rucksacks as (
    select
      lineno rucksack_id
      , trunc((lineno-1)/3) rucksack_group
      , linevalue rucksack_contents
    from input_data
  )
, items as (
    select r.rucksack_id, r.rucksack_group, i.item_type
    from rucksacks r
      ,lateral(select column_value item_type from table(string2rows(r.rucksack_contents))) i
  )
select * from items
/


-- hmm, nope, in shortcut didn't work
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
      and (i1.rucksack_id, i1.item_type) in (
        select i2.rucksack_id, i2.item_type
        from items i2
        where i2.rucksack_id = 1
          and (i2.rucksack_id, i2.item_type) in (
            select i3.rucksack_id, i3.item_type
            from items i3
            where rucksack_id = 2
          )
      )
  )
select * from types_in_container_groups
/



-- 
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
select * from types_in_container_groups
/
-- maybe? test on example input
create or replace synonym input_data for day03_example;
-- yep!

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

--select sum(priority) from group_priorities
