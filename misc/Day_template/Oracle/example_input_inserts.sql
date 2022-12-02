drop sequence line_number_sq;
create sequence line_number_sq;

drop table   day??_example;
create table day??_example (lineno number, linevalue varchar2(4000));

create or replace synonym input_data for day??_example;

--insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'
--');

commit;
