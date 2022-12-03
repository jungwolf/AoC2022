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

with rucksacks as (
    select linevalue rucksack_contents, length(linevalue) rucksack_size, length(linevalue)/2 container_size
    from input_data
  )
select rucksack_contents, rucksack_size, container_size, substr(rucksack_contents,1,container_size) container1
  substr(rucksack_contents,container_size+1) container2
from rucksacks
/
