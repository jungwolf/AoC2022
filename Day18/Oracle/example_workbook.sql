-- scratchpad for creating the solution
create or replace synonym input_data for day18_example;

select * from input_data;

-- Sample
    select instr(linevalue,',') comma1
      ,instr(linevalue,',',1,2) comma2
      ,linevalue
    from input_data
/

with delimitor_positions as (
    select instr(linevalue,',') comma1
      ,instr(linevalue,',',1,2) comma2
      ,linevalue
    from input_data
  )
, lava as (
    select
       to_number(substr(linevalue,1,comma1-1))             x
      ,to_number(substr(linevalue,comma1+1,comma2-comma1-1)) y
      ,to_number(substr(linevalue,comma2+1)) z
    from delimitor_positions
  )
select * from lava;

-- mark if "same" from previous value in "direction"
with delimitor_positions as (
    select instr(linevalue,',') comma1
      ,instr(linevalue,',',1,2) comma2
      ,linevalue
    from input_data
  )
, lava as (
    select
       to_number(substr(linevalue,1,comma1-1))             x
      ,to_number(substr(linevalue,comma1+1,comma2-comma1-1)) y
      ,to_number(substr(linevalue,comma2+1)) z
    from delimitor_positions
  )
select x,y,z
  , case 
      when lag(x) over (partition by y,z order by x) is null then 'N' 
      when x-1 = lag(x) over (partition by y,z order by x) then 'Y' 
      else 'N'
    end sequenctial_x
from lava
order by y,z,x;

-- mark if "same" from previous value in "direction"
with delimitor_positions as (
    select instr(linevalue,',') comma1
      ,instr(linevalue,',',1,2) comma2
      ,linevalue
    from input_data
  )
, lava as (
    select
       to_number(substr(linevalue,1,comma1-1))             x
      ,to_number(substr(linevalue,comma1+1,comma2-comma1-1)) y
      ,to_number(substr(linevalue,comma2+1)) z
    from delimitor_positions
  )
select x,y,z
  , case 
      when lag(x) over (partition by y,z order by x) is null then 'N' 
      when x-1 = lag(x) over (partition by y,z order by x) then 'Y' 
      else 'N'
    end sequenctial_x
  , case 
      when lag(y) over (partition by x,z order by y) is null then 'N' 
      when y-1 = lag(y) over (partition by x,z order by y) then 'Y' 
      else 'N'
    end sequenctial_y
  , case 
      when lag(z) over (partition by x,y order by z) is null then 'N' 
      when z-1 = lag(z) over (partition by x,y order by z) then 'Y' 
      else 'N'
    end sequenctial_z
from lava
order by x,y,z;
-- so, basically, when counting ignore Y
-- and double, because going in two directions


with delimitor_positions as (
    select instr(linevalue,',') comma1
      ,instr(linevalue,',',1,2) comma2
      ,linevalue
    from input_data
  )
, lava as (
    select
       to_number(substr(linevalue,1,comma1-1))             x
      ,to_number(substr(linevalue,comma1+1,comma2-comma1-1)) y
      ,to_number(substr(linevalue,comma2+1)) z
    from delimitor_positions
  )
, direction_blobs as (select x,y,z
  , case 
      when lag(x) over (partition by y,z order by x) is null then 'N' 
      when x-1 = lag(x) over (partition by y,z order by x) then 'Y' 
      else 'N'
    end sequenctial_x
  , case 
      when lag(y) over (partition by x,z order by y) is null then 'N' 
      when y-1 = lag(y) over (partition by x,z order by y) then 'Y' 
      else 'N'
    end sequenctial_y
  , case 
      when lag(z) over (partition by x,y order by z) is null then 'N' 
      when z-1 = lag(z) over (partition by x,y order by z) then 'Y' 
      else 'N'
    end sequenctial_z
from lava
)
select * from direction_blobs;


with delimitor_positions as (
    select instr(linevalue,',') comma1
      ,instr(linevalue,',',1,2) comma2
      ,linevalue
    from input_data
  )
, lava as (
    select
       to_number(substr(linevalue,1,comma1-1))             x
      ,to_number(substr(linevalue,comma1+1,comma2-comma1-1)) y
      ,to_number(substr(linevalue,comma2+1)) z
    from delimitor_positions
  )
, direction_blobs as (select x,y,z
  , case 
      when lag(x) over (partition by y,z order by x) is null then 'N' 
      when x-1 = lag(x) over (partition by y,z order by x) then 'Y' 
      else 'N'
    end sequential_x
  , case 
      when lag(y) over (partition by x,z order by y) is null then 'N' 
      when y-1 = lag(y) over (partition by x,z order by y) then 'Y' 
      else 'N'
    end sequential_y
  , case 
      when lag(z) over (partition by x,y order by z) is null then 'N' 
      when z-1 = lag(z) over (partition by x,y order by z) then 'Y' 
      else 'N'
    end sequential_z
from lava
)
select sum(decode(sequential_x,'N',1,0))*2 xs
  ,sum(decode(sequential_y,'N',1,0))*2 ys
  ,sum(decode(sequential_z,'N',1,0))*2 xs
from direction_blobs;
-- 22,22,20



with delimitor_positions as (
    select instr(linevalue,',') comma1
      ,instr(linevalue,',',1,2) comma2
      ,linevalue
    from input_data
  )
, lava as (
    select
       to_number(substr(linevalue,1,comma1-1))             x
      ,to_number(substr(linevalue,comma1+1,comma2-comma1-1)) y
      ,to_number(substr(linevalue,comma2+1)) z
    from delimitor_positions
  )
, direction_blobs as (select x,y,z
  , case 
      when lag(x) over (partition by y,z order by x) is null then 'N' 
      when x-1 = lag(x) over (partition by y,z order by x) then 'Y' 
      else 'N'
    end sequential_x
  , case 
      when lag(y) over (partition by x,z order by y) is null then 'N' 
      when y-1 = lag(y) over (partition by x,z order by y) then 'Y' 
      else 'N'
    end sequential_y
  , case 
      when lag(z) over (partition by x,y order by z) is null then 'N' 
      when z-1 = lag(z) over (partition by x,y order by z) then 'Y' 
      else 'N'
    end sequential_z
from lava
)
select sum(decode(sequential_x,'N',1,0))*2 
  +sum(decode(sequential_y,'N',1,0))*2 
  +sum(decode(sequential_z,'N',1,0))*2 the_sum
from direction_blobs;
