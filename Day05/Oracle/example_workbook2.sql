-- last workbook was getting big
-- in a recursive view, the second part can only reference the view once
-- this works well as a single move but can't be recursed...
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
-- so maybe analytics will save the day...

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







-- last workbook was getting big
-- in a recursive view, the second part can only reference the view once
-- this works well as a single move but can't be recursed...
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
-- so maybe analytics will save the day...

with stacks as (
            select 1 s, 'AB' payload from dual
  union all select 2,   'CD'         from dual
)
, moves as (
            select 1 move, 1 fm, 2 tt from dual
  union all select 2     , 2     , 1    from dual
)
select s.s, s.payload, m.move, m.fm, m.tt
  , case
      when s.s = m.fm
        then substr(s.payload,2)
      when s.s = m.tt
        then (select substr(x.payload,1,1) from stacks x where x.s = m.fm) || s.payload
      else s.payload
    end new_payload
from stacks s, moves m
;


with stacks as (
            select 1 stack, 'AB' payload from dual
  union all select 2,       'CD'         from dual
  union all select 3,       'EF'         from dual
)
, moves as (
            select 1 move, 1 fm, 2 tt from dual
  union all select 2     , 2     , 1  from dual
)
, stack_states (stack, payload, move, fm, tt, new_payload) as (
  select s.stack, s.payload, 0,0,0,s.payload
  from stacks s

  union all

  select ss.stack, ss.new_payload, ss.move+1, m.fm, m.tt
    , case
        when ss.stack = m.fm
          then substr(ss.new_payload,2)
        when ss.stack = m.tt
          then ss.new_payload || ss.new_payload
--          then 'a'
        else ss.payload
      end new_payload
  from stack_states ss, moves m
  where ss.move+1=m.move
)
select *
from stack_states
;
select * from table(dbms_xplan.display_cursor());














-- because oracle defines it as varchar2(2), I believe
with stacks as (
            select 1 stack, cast('AB' as varchar2(4000)) payload from dual
  union all select 2,       'CD'         from dual
  union all select 3,       'EF'         from dual
)
, moves as (
            select 1 move, 1 fm, 2 tt from dual
  union all select 2     , 2     , 1  from dual
)
, stack_states (stack, payload, move, fm, tt, new_payload) as (
  select s.stack, s.payload, 0,0,0,s.payload
  from stacks s

  union all

  select ss.stack, ss.new_payload, ss.move+1, m.fm, m.tt
    , case
        when ss.stack = m.fm
          then substr(ss.new_payload,2)
        when ss.stack = m.tt
          then ss.new_payload || ss.new_payload
        else ss.payload
      end new_payload
  from stack_states ss, moves m
  where ss.move+1=m.move
)
select *
from stack_states
;
select * from table(dbms_xplan.display_cursor());

-- maybe?
with stacks as (
            select 1 stack, cast('AB' as varchar2(4000)) payload from dual
  union all select 2,       'CD'         from dual
  union all select 3,       'EF'         from dual
)
, moves as (
            select 1 move, 1 fm, 2 tt from dual
  union all select 2     , 2     , 1  from dual
)
, stack_states (stack, payload, move, fm, tt, new_payload) as (
  select s.stack, s.payload, 0,0,0,s.payload
  from stacks s

  union all

  select ss.stack, ss.new_payload, ss.move+1, m.fm, m.tt
    , case
        when ss.stack = m.fm
          then substr(ss.new_payload,2)
        when ss.stack = m.tt and ss.stack > m.fm
--          then lag(ss.new_payload,abs(ss.stack-m.fm)) over (order by ss.stack) || ss.new_payload
          then substr(lag(ss.new_payload,abs(ss.stack-m.fm)) over (order by ss.stack),1,1) || ss.new_payload
        when ss.stack = m.tt and ss.stack < m.fm
--          then lead(ss.new_payload,abs(ss.stack-m.fm)) over (order by ss.stack) || ss.new_payload
          then substr(lead(ss.new_payload,abs(ss.stack-m.fm)) over (order by ss.stack),1,1) || ss.new_payload
        else ss.payload
      end new_payload
  from stack_states ss, moves m
  where ss.move+1=m.move
)
select *
from stack_states
;







with stacks as (
            select 1 stack, cast('AB' as varchar2(4000)) payload from dual
  union all select 2,       'CD'         from dual
  union all select 3,       'EF'         from dual
)
, moves as (
            select 1 move, 1 fm, 2 tt from dual
  union all select 2     , 2     , 1  from dual
  union all select 3     , 2     , 1  from dual
)
, stack_states (stack, payload, move, fm, tt, new_payload) as (
  select s.stack, s.payload, 0,0,0,s.payload
  from stacks s

  union all

  select ss.stack, ss.new_payload, ss.move+1, m.fm, m.tt
    , case
        when ss.stack = m.fm
          then substr(ss.new_payload,2)
        when ss.stack = m.tt and ss.stack > m.fm
          then substr(lag(ss.new_payload,abs(ss.stack-m.fm)) over (order by ss.stack),1,1) || ss.new_payload
        when ss.stack = m.tt and ss.stack < m.fm
          then substr(lead(ss.new_payload,abs(ss.stack-m.fm)) over (order by ss.stack),1,1) || ss.new_payload
        else ss.payload
      end new_payload
  from stack_states ss, moves m
  where ss.move+1=m.move
)
select *
from stack_states
;




-- halfway there!
with stacks as (
            select 1 stack, cast('NZ' as varchar2(4000)) payload from dual
  union all select 2,       'DCM'         from dual
  union all select 3,       'P'         from dual
)
, moves_parsed (lineno, ct, fm, tt) as (
    select
      lineno
      ,to_number(REGEXP_SUBSTR(linevalue,'\d+',1,1)) ct
      ,to_number(REGEXP_SUBSTR(linevalue,'\d+',1,2)) fm
      ,to_number(REGEXP_SUBSTR(linevalue,'\d+',1,3)) tt
    from group1
    union all
    select lineno, ct-1,fm,tt from moves_parsed
    where ct > 1
)
, moves as (
  select row_number() over (order by lineno) move
    ,fm, tt
  from moves_parsed
)
, stack_states (stack, payload, move, fm, tt, new_payload) as (
  select s.stack, s.payload, 0,0,0,s.payload
  from stacks s

  union all

  select ss.stack, ss.new_payload, ss.move+1, m.fm, m.tt
    , case
        when ss.stack = m.fm
          then substr(ss.new_payload,2)
        when ss.stack = m.tt and ss.stack > m.fm
--          then lag(ss.new_payload,abs(ss.stack-m.fm)) over (order by ss.stack) || ss.new_payload
          then substr(lag(ss.new_payload,abs(ss.stack-m.fm)) over (order by ss.stack),1,1) || ss.new_payload
        when ss.stack = m.tt and ss.stack < m.fm
--          then lead(ss.new_payload,abs(ss.stack-m.fm)) over (order by ss.stack) || ss.new_payload
          then substr(lead(ss.new_payload,abs(ss.stack-m.fm)) over (order by ss.stack),1,1) || ss.new_payload
        else ss.new_payload
      end new_payload
  from stack_states ss, moves m
  where ss.move+1=m.move
)
select *
from stack_states
order by move, stack
;


