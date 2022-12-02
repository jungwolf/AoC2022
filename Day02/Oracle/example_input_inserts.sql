drop sequence line_number_sq;
create sequence line_number_sq;

drop table   day02_example;
create table day02_example (lineno number, linevalue varchar2(4000));

drop synonym input_data;
create synonym input_data for day02_example;

--insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'
--');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'A Y');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'B X');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'C Z');

commit;
