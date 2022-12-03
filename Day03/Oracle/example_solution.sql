create or replace synonym input_data for day03_example;

/*
Find the item type that appears in both compartments of each rucksack.
What is the sum of the priorities of those item types?

Lowercase item types a through z have priorities 1 through 26.
Uppercase item types A through Z have priorities 27 through 52.

Each line has two compartments of equal size. Always even number.
We want existance of a shared item type. No weight to the number of items of those shared types.

So far, assume:
  there at least one shared item type between the compartments
  
*/

-- length is probably important
select linevalue rucksack_contents, length(linevalue) rucksack_length
from input_data
/

-- split them up
with rucksacks as (
    select linevalue rucksack_contents, length(linevalue) rucksack_size, length(linevalue)/2 container_size
    from input_data
  )
select rucksack_contents, rucksack_size, container_size, substr(rucksack_contents,1,container_size) container1
  , substr(rucksack_contents,container_size+1) container2
from rucksacks
/

/*
substring manipulation or set operation? Maybe, for once, I can use the INTERSECT operator.

Okay, I know of three ways to split a string into multiple rows.
  CONNECT BY -- a finicky, to me, recursive query structure
  recursive view -- basically CONNECT BY with reasonable syntax
  function and object type -- create a type of varchar2 table, split the line in the function and output a table

I've used the first two multiple times. It is tedious. I don't want to slog through it again.
Pretend I sql'ed. I'm going to use my string2row function instead.

There may be a fourth way, sql macros. I will investigate them later.

*/

with rucksacks as (
    select linevalue rucksack_contents
      , length(linevalue) rucksack_size
      , length(linevalue)/2 container_size
    from input_data
  )
, containers as (
    select container_size
      , substr(rucksack_contents,1,container_size) container1
      , substr(rucksack_contents,container_size+1) container2
    from rucksacks
  )
select * 
from containers
/

with rucksacks as (
    select linevalue rucksack_contents
      , length(linevalue) rucksack_size
      , length(linevalue)/2 container_size
    from input_data
  )
, containers as (
    select container_size
      , substr(rucksack_contents,1,container_size) container1
      , substr(rucksack_contents,container_size+1) container2
    from rucksacks
  )
select * 
from containers c
  ,lateral(select * from table(string2rows(c.container1))) n;
/

/*
CONTAINER_SIZE	CONTAINER1	CONTAINER2	COLUMN_VALUE
12	vJrwpWtwJgWr	hcsFMMfFFhFp	v
12	vJrwpWtwJgWr	hcsFMMfFFhFp	J
12	vJrwpWtwJgWr	hcsFMMfFFhFp	r
12	vJrwpWtwJgWr	hcsFMMfFFhFp	w
12	vJrwpWtwJgWr	hcsFMMfFFhFp	p
12	vJrwpWtwJgWr	hcsFMMfFFhFp	W
12	vJrwpWtwJgWr	hcsFMMfFFhFp	t
...
*/

-- need a rucksack_id
-- how about div(container_size) to get container_id
with rucksacks as (
    select
      lineno container_id
      , linevalue rucksack_contents
      , length(linevalue)/2 container_size
    from input_data
  )
select * from rucksacks
/

with rucksacks as (
    select
      lineno container_id
      , linevalue rucksack_contents
      , length(linevalue)/2 container_size
    from input_data
  )
select * 
from rucksacks r
  ,lateral(select rownum, i.column_value from table(string2rows(r.rucksack_contents))) i;
/
-- wow, I did not expect that to work.

with rucksacks as (
    select
      lineno rucksack_id
      , linevalue rucksack_contents
      , length(linevalue)/2 container_size
    from input_data
  )
select r.rucksack_id, i.item_id, i.item_type
from rucksacks r
  ,lateral(select rownum item_id, column_value item_type from table(string2rows(r.rucksack_contents))) i;
/

-- don't need item_id, need container_id
with rucksacks as (
    select
      lineno rucksack_id
      , linevalue rucksack_contents
      , length(linevalue)/2 container_size
    from input_data
  )
select r.rucksack_id, trunc((i.item_id-1)/r.container_size) container_id, i.item_type
from rucksacks r
  ,lateral(select rownum item_id, column_value item_type from table(string2rows(r.rucksack_contents))) i;
/
/*
RUCKSACK_ID	CONTAINER_ID	ITEM_TYPE
1	0	v
1	0	J
1	0	r
1	0	w
1	0	p
1	0	W
1	0	t
1	0	w
1	0	J
1	0	g
1	0	W
1	0	r
1	1	h
1	1	c
1	1	s
1	1	F
1	1	M
1	1	M
1	1	f
1	1	F
1	1	F
...
*/

-- huh. intersect works on the values for all the columns. can you do complex sql in the lateral clause?
-- never mind. onward!

-- validate new form
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
select * from items
/

-- so, what item_types in container_id 0 exist in container_id 1?
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
select * 
from items
where container_id = 0
  and (rucksack_id, item_type) not in (
    select rucksack_id, item_type
	from items
	where container_id = 1
  )
/

-- remove dups
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
select unique rucksack_id, container_id, item_type
from items
where container_id = 0
  and (rucksack_id, item_type) not in (
    select rucksack_id, item_type
	from items
	where container_id = 1
  )
/

-- hmm, find priority values
select ascii('A') from dual;
--65
select ascii('a') "a",ascii('z') "z",ascii('A') "A",ascii('Z') "Z" from dual;
--a	z	A	Z
--97	122	65	90
select case when 'C' > 'Z' then ascii('C') - ascii('a') else ascii('C') - ascii('A') end
from dual;

-- oh so ugly
-- for off-by-1, could be case...end + 1, but that seems more error prone
with test_char as (select 'C' testvalue from dual)
select 
  case when lower(testvalue) = testvalue
    then ascii(testvalue) - ascii('a') + 1
    else ascii(testvalue) - ascii('A') + 1 + 26
  end
from dual, test_char;


-- so add the priority calculation...
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
select 
  rucksack_id
  , case when lower(item_type) = item_type
      then ascii(item_type) - ascii('a') + 1
      else ascii(item_type) - ascii('A') + 1 + 26
    end priority
from types_in_both_containers
/
/*
RUCKSACK_ID	PRIORITY
5	20
1	16
2	38
3	42
6	19
4	22
*/


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