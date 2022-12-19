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
