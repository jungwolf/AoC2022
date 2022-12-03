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