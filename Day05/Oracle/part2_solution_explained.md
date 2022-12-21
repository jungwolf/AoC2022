# Moving stacks
I assume you have a medium experience with sql. Previous years I explained at a more basic level.
## Problem
Today we're moving boxes between stacks. The input has two parts, the stack and then the instructions. In part one we moved boxes one by one. In part two, here, we'll move boxes in groups.
## Input
This is the example input, since it is smaller. I load the data into a table, `input_data (lineno number, linevalue varchar2(4000))`. 
```
    [D]    
[N] [C]    
[Z] [M] [P]
 1   2   3 

move 1 from 2 to 1
move 3 from 1 to 3
move 2 from 2 to 1
move 1 from 1 to 2
```
Parsing the moves is straightforward. The stacks are something else. Let's see how it goes.
## Approach
I split the input into two groups, the stacks and the moves. I do this with an analytic function to detect the null linevalue.

Parse stacks:
- break down the stacks to individual characters
- reassemble the columns as strings.
- filter out the junk characters, parse the stack number and payload

Parse moves:
- simple parse into three columns

Move stacks:
- use a recursive cte (common table expression) to apply moves to the stacks
- in a move, take the existing stack and use lag/lead to find the new stack
  - `substr(..,2)` to pop
  - `lag(substr(..,1,1)) ||` to push

## sql

```sql
with group0 as (
  select lineno, linevalue from (
    select lineno,linevalue
      , sum(nvl2(linevalue,0,1)) over (order by lineno) grouping
    from input_data
  ) where grouping = 0
)
, group1 as (
  select lineno, linevalue from (
    select lineno,linevalue
      , sum(nvl2(linevalue,0,1)) over (order by lineno) grouping
    from input_data
  ) where grouping = 1 and linevalue is not null
)
```
The `nvl2()` let's me assign number 1 to a null line and 0 to not null. From there, `sum() over (order by lineno)` has a row sum up the number of null lines before it.

Three notes:
- I made two views because in the workbook I consentrated on one section at a time. 
```sql
, elements as (
select g.lineno, g.linevalue, i.pos, i.column_value
from group0 g
  , lateral(select rownum pos, column_value from table(string2rows(linevalue))) i
where column_value not in (' ','[',']')
)
, pivoted as (
select listagg(column_value) within group (order by lineno) almoststack
from elements
group by pos
)
, stacks as (
select to_number(REGEXP_SUBSTR(almoststack,'\d+')) stack
, REGEXP_SUBSTR(almoststack,'\D+') payload
from pivoted
)
, moves as (
    select
      row_number() over (order by lineno) move
      ,to_number(REGEXP_SUBSTR(linevalue,'\d+',1,1)) ct
      ,to_number(REGEXP_SUBSTR(linevalue,'\d+',1,2)) fm
      ,to_number(REGEXP_SUBSTR(linevalue,'\d+',1,3)) tt
    from group1
)
, stack_states (stack, payload, move, ct, fm, tt, new_payload) as (
  select s.stack, s.payload, 0,0,0,0,s.payload
  from stacks s

  union all

  select ss.stack, ss.new_payload, ss.move+1, m.ct, m.fm, m.tt
    , case
        when ss.stack = m.fm
          then substr(ss.new_payload,m.ct+1)
        when ss.stack = m.tt and ss.stack > m.fm
--          then lag(ss.new_payload,abs(ss.stack-m.fm)) over (order by ss.stack) || ss.new_payload
          then substr(lag(ss.new_payload,abs(ss.stack-m.fm)) over (order by ss.stack),1,m.ct) || ss.new_payload
        when ss.stack = m.tt and ss.stack < m.fm
--          then lead(ss.new_payload,abs(ss.stack-m.fm)) over (order by ss.stack) || ss.new_payload
          then substr(lead(ss.new_payload,abs(ss.stack-m.fm)) over (order by ss.stack),1,m.ct) || ss.new_payload
        else ss.new_payload
      end new_payload
  from stack_states ss, moves m
  where ss.move+1=m.move
)
--select * from stack_states
select listagg(substr(new_payload,1,1)) within group (order by stack)
from stack_states
group by move
order by move desc fetch first 1 row only
;
```