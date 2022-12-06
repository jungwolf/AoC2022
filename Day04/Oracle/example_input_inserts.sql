drop sequence line_number_sq;
create sequence line_number_sq;

drop table   day04_example;
create table day04_example (lineno number, linevalue varchar2(4000));

create or replace synonym input_data for day04_example;

--insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'
--');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'2-4,6-8');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'2-3,4-5');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'5-7,7-9');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'2-8,3-7');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'6-6,4-6');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'2-6,4-8');

commit;
