drop sequence line_number_sq;
create sequence line_number_sq;

drop table   day??_part1;
create table day??_part1 (lineno number, linevalue varchar2(4000));

create or replace synonym input_data for day??_part1;

--insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'
--');

commit;
