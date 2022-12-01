drop sequence line_number_sq;
create sequence line_number_sq;

drop table day01_example;
create table day01_example (lineno number, linevalue varchar2(4000));
create synonym input_data for day01_example;

--insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'');

commit;
