select * from input_data;
select * from group0 order by lineno desc;

select g.lineno, g.linevalue, i.pos, i.column_value
from group0 g
  , lateral(select rownum pos, column_value from table(string2rows(linevalue))) i
where column_value not in (' ','[',']')
/


with elements as (
select g.lineno, g.linevalue, i.pos, i.column_value
from group0 g
  , lateral(select rownum pos, column_value from table(string2rows(linevalue))) i
where column_value not in (' ','[',']')
)
select listagg(column_value) within group (order by lineno)
from elements
group by pos
/

with elements as (
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
select to_number(REGEXP_SUBSTR(almoststack,'\d+')) stack
, REGEXP_SUBSTR(almoststack,'\D+') payload
from pivoted
/

------------------------------------------------------------------

with elements as (
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


----- oh my!
with elements as (
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
select listagg(substr(new_payload,1,1)) within group (order by stack)
from stack_states
group by move
order by move desc fetch first 1 row only
;


create or replace view group0 as
select lineno, linevalue from (
  select lineno,linevalue
    , sum(nvl2(linevalue,0,1)) over (order by lineno) grouping
  from input_data
) where grouping = 0
/

create or replace view group1 as
select lineno, linevalue from (
  select lineno,linevalue
    , sum(nvl2(linevalue,0,1)) over (order by lineno) grouping
  from input_data
) where grouping = 1 and linevalue is not null
/

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
select listagg(substr(new_payload,1,1)) within group (order by stack)
from stack_states
group by move
order by move desc fetch first 1 row only
;
