-- scratchpad for creating the solution
create or replace synonym input_data for day05_example;

select * from input_data;

-- quick group to separate data from instructions
with g as (
  select lineno,linevalue
    , sum(nvl2(linevalue,0,1)) over (order by lineno) grouping
  from input_data
)
select *
from g;

/*
    [D]
[N] [C]
[Z] [M] [P]
 1   2   3

what if we flip it? something like:
[...
1ZN
[...
[...
2MCD
[...
[...
3P
[...

how to do that?
*/
-- create a view so I can focus on the idea
create or replace view group0 as
select lineno, linevalue from (
  select lineno,linevalue
    , sum(nvl2(linevalue,0,1)) over (order by lineno) grouping
  from input_data
) where grouping = 0
/
select * from group0 order by lineno desc;

create or replace view group1 as
select lineno, linevalue from (
  select lineno,linevalue
    , sum(nvl2(linevalue,0,1)) over (order by lineno) grouping
  from input_data
) where grouping = 1 and linevalue is not null
/
select * from group1 order by lineno;

--let's parse it out to move, from, to
-- find from then take the next number
select
REGEXP_SUBSTR(linevalue,'.*from\s+\K\S+') a
,REGEXP_SUBSTR(linevalue,'.*from\K.*') a
,REGEXP_SUBSTR(linevalue,'from') a
,REGEXP_SUBSTR(linevalue,'^from') a
,REGEXP_SUBSTR(linevalue,'(^from).*to*') a
,REGEXP_SUBSTR(linevalue,'(^from).*to*') a
,REGEXP_SUBSTR(linevalue,'[0-9]+') a
,REGEXP_SUBSTR(linevalue,'(?<=f)\d') a
,REGEXP_SUBSTR(linevalue,'\d+') a
,REGEXP_SUBSTR(linevalue,'\D') a
from group1;
-- hmm, that didn't work, okay how about this
select REGEXP_SUBSTR(' het 777 boo 41 ','\d+') from dual;
select REGEXP_SUBSTR(' het 777 boo 41 ','\d+',1,2) from dual;

-- for ct times move from fm to tt
-- count, from, and to are keywords...
select
REGEXP_SUBSTR(linevalue,'\d+',1,1) ct
,REGEXP_SUBSTR(linevalue,'\d+',1,2) fm
,REGEXP_SUBSTR(linevalue,'\d+',1,3) tt
from group1;
-- I want to unroll the commands
with moves (ct, fm, tt) as (
  select 3 ct, 1 fm, 2 tt from dual
  union all
  select ct-1,fm,tt from moves
  where ct > 1
)
select * from moves;

with moves (lineno, ct, fm, tt) as (
    select
      lineno
      ,to_number(REGEXP_SUBSTR(linevalue,'\d+',1,1)) ct
      ,to_number(REGEXP_SUBSTR(linevalue,'\d+',1,2)) fm
      ,to_number(REGEXP_SUBSTR(linevalue,'\d+',1,3)) tt
    from group1
    union all
    select lineno, ct-1,fm,tt from moves
    where ct > 1
)
select * from moves order by lineno;

-- so how to do this?
-- say I have two stacks, 1:AB and 2:CD
-- I want to move 1 to 2
with stacks as (
  select 1 s, 'AB' payload from dual
  union all select 2, 'CD' from dual
)
, moves as (
  select 1 fm, 2 tt from dual
)
select * from stacks, moves;

-- one idea is to use a recursive sql to return the state after the effects of each move
-- hmm, let's say the stack top is on the left. everything happens with position 1

-- first, do the pop
with stacks as (
  select 1 s, 'AB' payload from dual
  union all select 2, 'CD' from dual
)
, moves as (
  select 1 fm, 2 tt from dual
)
select s.s, s.payload, m.fm, m.tt
  , case
      when s.s = m.fm
        then substr(s.payload,2)
      else s.payload
    end new_payload
from stacks s, moves m;

-- but what about the push?
with stacks as (
  select 1 s, 'AB' payload from dual
  union all select 2, 'CD' from dual
)
, moves as (
  select 1 fm, 2 tt from dual
)
select s.s, s.payload, m.fm, m.tt
  , case
      when s.s = m.fm
        then substr(s.payload,2)
      when s.s = m.tt
        then (select substr(x.payload,1,1) from stacks x where x.s = m.fm) || s.payload
      else s.payload
    end new_payload
from stacks s, moves m;

-- okay, but now what?
with moves as (
  select 1 move, 1 fm, 2 tt from dual
  union all select 2, 2, 1 from dual
)
, stacks as (
  select 1 s, 'AB' payload from dual
  union all select 2, 'CD' from dual
)
select * from moves, stacks;

-- so basic recursion something...
with moves as (
  select 1 move, 1 fm, 2 tt from dual
  union all select 2, 2, 1 from dual
)
, stacks as (
  select 1 s, 'AB' payload from dual
  union all select 2, 'CD' from dual
)
, stacks_at_move (move, stack, payload, new_payload) as (
    select 0 move, s.s stack, s.payload, null new_payload
    from stacks s
    union all
    select 0,0,'a','a' from dual where 0=1
)
select * from stacks_at_move;

-- put some logic in it...
with moves as (
  select 1 move, 1 fm, 2 tt from dual
  union all select 2, 2, 1 from dual
)
, stacks as (
  select 1 s, 'AB' payload from dual
  union all select 2, 'CD' from dual
)
, stacks_at_move (move, stack, payload, new_payload) as (
    select 0 move, s.s stack, s.payload, null new_payload
    from stacks s
    union all
    select m.move, s1.stack ,s1.new_payload
      , case when 1=1 then 'a' else 'b' end
    from moves m, stacks_at_move s1
    where m.move = s1.move+1

)
select * from stacks_at_move;


-- um, this might do it?
with moves as (
  select 1 move, 1 fm, 2 tt from dual
  union all select 2, 2, 1 from dual
)
, stacks as (
  select 1 s, 'AB' payload from dual
  union all select 2, 'CD' from dual
)
, stacks_at_move (move, stack, payload, new_payload) as (
    select 0 move, s.s stack, s.payload, null new_payload
    from stacks s

    union all

    select m.move, s1.stack ,s1.new_payload
      ,case
        when s1.stack = m.fm
          then substr(s1.payload,2)
        when s1.stack = m.tt
          then (select substr(x.payload,1,1) from stacks_at_move x where x.stack = m.fm) || s1.payload
        else s1.payload
      end new_payload
    from moves m, stacks_at_move s1
    where m.move = s1.move+1

)
select * from stacks_at_move;

-- ORA-32042: recursive WITH clause must reference itself directly in one of the UNION ALL branches
-- or maybe not