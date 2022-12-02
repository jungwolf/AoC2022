-- generate rows from string using delimiter
-- if null delimiter (default), outputs each character on its own line
-- delimiters can be multicharacter

-- uses a user defined type
-- notice it can only handle inputs up to 4000 characters.
create or replace type varchar2_tbl as table of varchar2(4000);
/

create or replace function string2rows (p_string varchar2, p_delimiter varchar2 default null) return varchar2_tbl as
  l_vtab varchar2_tbl := varchar2_tbl();
  l_delimiter_length number;
  l_delimiter_position number;
begin

  l_vtab.extend;

  if p_string is null then
    return l_vtab;
  end if;

  if p_delimiter is null then
    l_vtab(1):=substr(p_string,1,1);
    if length(p_string) > 1 then
      l_vtab := l_vtab multiset union all string2rows(substr(p_string,2),p_delimiter);
    end if;
  else
    l_delimiter_length:=length(p_delimiter); -- null if d is null
    l_delimiter_position:= instr(p_string,p_delimiter); -- null if d is null, 0 if d isn't in p
    if l_delimiter_position = 0 then
      l_vtab(1):=p_string;
    else
      l_vtab(1):=substr(p_string,1,l_delimiter_position-1);
      l_vtab := l_vtab multiset union all string2rows(substr(p_string,l_delimiter_position+l_delimiter_length),p_delimiter);
    end if;
  end if;
  return l_vtab;
  
end;
/
select * from table(string2rows('a,b,c,d,e',','));
select * from table(string2rows('a,b,c,,e',','));
select * from table(string2rows(',a,b,c,,,e',','));
select * from table(string2rows(',a,b,c,,e,',','));
-- has final null row
select * from table(string2rows(null,','));
-- null row (I think I want that behavior)
select * from table(string2rows(',a,b,c,,,e,',null));


-- column name from a table() operation is column_value
-- example joining the new table output to the row of a source table
-- table has rows with 'xx -> y' values
select e.linevalue, '.', n.column_value
from day14_example e
  ,lateral(select * from table( string2rows(e.linevalue,' -> ') )) n;
/*
CH -> B	.	CH
CH -> B	.	B
HH -> N	.	HH
HH -> N	.	N
*/


