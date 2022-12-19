-- scratchpad for creating the solution
create or replace synonym input_data for day18_example;

select * from input_data;

/*
could just search for an adjacent cube, subtract one, repeat
or, group (x,y),(x,z),(y,z) and count number of non consecutive columns
eg at 5,5: 1,2 4 9 would be three groups, so three columns with 2 sides each
*/


