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
- I made two views because in the workbook I consentrated on one section at a time. On a rewrite I'd probably do `groups(lineno,linevalue,groupnum)` and filter the group in the next sections.
- Some flavors of sql have a filter clause in the analytic function syntax, allowing it to ignore lines. In that case, `count(*) filter (linevalue is not null) over ()` might be easier to read the intent. Oracle doesn't have it.
- I used an in-line view because analytic functions are evaluated last, even after `having`. They can only appear in a select or order clause.
```sql
, elements as (
select g.lineno, g.linevalue, i.pos, i.column_value
from group0 g
  , lateral(select rownum pos, column_value from table(string2rows(linevalue))) i
where column_value not in (' ','[',']')
)
```
Let's break it down a little.
- `string2rows()` is a function I wrote to split strings into rows, by default every character is a new row. Big caveat, the output is actually a custom **datatype**, `table of varchar2`. Functions can return only a single object.
- But sql has `table()`, allowing you to treat collection datatypes as a row source. It has a single column, by default named column_value. The order of the rows returned is deterministic-- not going into the particulars.

Quick example:
```sql
select rownum pos, column_value 
from table(string2rows('abc'))
```
Results in
|pos|column_value|
|---|---|
|1|a|
|2|b|
|3|c|


- A regular join is (table1) to (table2). A lateral join is (table1) to (table1 row,table2), which is to say a correlated join. The `lateral()` in-line view can reference the columns of the parent table and get the value for the matched row.

So, every row in group0 becomes multiple rows, one for each character in linevalue. Another example:

|lineno|linevalue|
|---|---|
|3|ZMP|
|4|123|

Becomes:

|lineno|linevalue|pos|column_value|
|---|---|---|---|
|3|ZMP|1|Z|
|3|ZMP|2|M|
|3|ZMP|3|P|
|4|123|1|1|
|5|123|2|2|
|6|123|3|3|

 In practice, linevalue is displayed for debugging only.
 
 Finally, filter out any column values that are not useful.

```sql
, pivoted as (
select listagg(column_value) within group (order by lineno) almoststack
from elements
group by pos
)
```
Flip it all on the diagonal. Group by character position, order by line number. We're left with rows like 'Z1' and 'P3'. The original input format means the `order by lineno` put the top of the stacks at position 1 and the number of the stack at the end. Almost there!

```sql
, stacks as (
select to_number(REGEXP_SUBSTR(almoststack,'\d+')) stack
, REGEXP_SUBSTR(almoststack,'\D+') payload
from pivoted
)
```
Parse out the number from the characters. Now we have stacks, with numbers.

```sql
, moves as (
    select
      row_number() over (order by lineno) move
      ,to_number(REGEXP_SUBSTR(linevalue,'\d+',1,1)) ct
      ,to_number(REGEXP_SUBSTR(linevalue,'\d+',1,2)) fm
      ,to_number(REGEXP_SUBSTR(linevalue,'\d+',1,3)) tt
    from group1
)
```
`row_number()` restarts the numbering at 1. Handy for the recursive CTE. The move text is always in the same order, so just grab the first, second, and third numbers.

Note for future: Oracle regex is limited. Searching for a pattern and then returning the next pattern isn't support. For example, searching for 'from' then selecting the next number. I suspect it'll be ugly.


```sql
, stack_states (stack, payload, move, ct, fm, tt, new_payload) as (
  select s.stack, s.payload, 0,0,0,0,s.payload
  from stacks s

  union all

  select ss.stack, ss.new_payload, ss.move+1, m.ct, m.fm, m.tt
    , case
        when ss.stack = m.fm
          then substr(ss.new_payload,m.ct+1)
        when ss.stack = m.tt and ss.stack > m.fm
          then substr(lag(ss.new_payload,abs(ss.stack-m.fm)) over (order by ss.stack),1,m.ct) || ss.new_payload
        when ss.stack = m.tt and ss.stack < m.fm
          then substr(lead(ss.new_payload,abs(ss.stack-m.fm)) over (order by ss.stack),1,m.ct) || ss.new_payload
        else ss.new_payload
      end new_payload
  from stack_states ss, moves m
  where ss.move+1=m.move
)
```
As a reminder, a recursive CTE has an anchor member and a recursive member. The anchor member generates the first set of rows. The recursive member uses the first set to generate the next set. That set is used to generate the next set. Etc. The current call to the recursive member cannot reference rows from previous sets. In particular, analytic functions are limited to the current set of rows.

I'm treating the CTE as a state machine. I need to keep track of the stacks and the move number. The moves themselves is a static list, so I'll join to it instead of trying to pass a "move state".

I displayed the move details for debugging, they are not needed. I'll ignore them and remove from the code below...

```sql
, stack_states (stack, payload, move) as (
  select s.stack, s.payload, 0
  from stacks s
```
Simple anchor. Rows of stacks and their content, with a new "move" column indicating they are generated at move 0.

For the next step, I need to join to the next move. The previous move was ss.move, so I need move+1. Easy enough. When there are no more moves to join, the join returns 0 rows, and the recursive member is done.
```sql
  from stack_states ss, moves m
  where ss.move+1=m.move
```
The output is going to be the stacks, their modified payloads, and the move applied. The case statement does all the work.
```sql
  select ss.stack
    , case
...
      end payload
    , m.move
```
Let's get into it.
- fm = move crates from this stack
- tt = move crates to this stack
- ct = move this number of crates
- lag() and lead(), used to look up column values from other rows
```sql
    , case
        when ss.stack = m.fm
        when ss.stack = m.tt and ss.stack > m.fm
        when ss.stack = m.tt and ss.stack < m.fm
        else ss.payload
      end payload
```
Check the stack number. If it is part of the move (fm or tt), do something, otherwise ignore it. The two `when` tests for ``ss.stack = m.tt`` are there because lag()/lead() only take positive numbers. They do the same thing but in opposite directions. 
```sql
        when ss.stack = m.fm
          then substr(ss.new_payload,m.ct+1)
```
We're removing the first "ct" crates, so take the substring starting at "ct" plus one.
```sql
        when ss.stack = m.tt and ss.stack > m.fm
          then substr(lag(ss.new_payload,abs(ss.stack-m.fm)) over (order by ss.stack),1,m.ct) || ss.new_payload
```
If ss.stack > m.fm, then the crates are coming from a stack **before** this one. We can access that row using lag.
```sql
lag(ss.new_payload,[offset]) over (order by ss.stack)
abs(ss.stack-m.fm)
substr(...,1,m.ct)
... || ss.new_payload
```
- lag() lets us access a previous row, but we have to define an ordering for "previous" to mean anything. We want a stack that is lower number than this one, so we order by the stack. By default lag() goes back one row from the current row, but [offset] can set the number to go back.
- [offset] can only be positive, throwing an error otherwise. A quirk of the language, you have to call different functions (lead()/lag()) instead of using signed integers.
- The ```when``` condition isn't short circuiting the evaluation. Oracle was giving an error for the when branch not taken. The abs() call prevents that.
- substr() is used to get the needed crates from the other row.
- Finally, we concatinate the existing value, pushing them further down the stack.
```
select listagg(substr(new_payload,1,1)) within group (order by stack)
from stack_states
group by move
order by move desc fetch first 1 row only
;
```
We've pushed and popped crates to the elves' delight. By design, the first letter in each stack is the top. The ```listagg()``` call let's me list them in order.

Fin.