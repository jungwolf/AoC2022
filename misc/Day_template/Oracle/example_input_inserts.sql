drop sequence line_number_sq;
create sequence line_number_sq;

drop table   dayXX_example;
create table dayXX_example (lineno number, linevalue varchar2(4000));

drop synonym input_data; 
create synonym input_data for dayXX_example;

--insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'
--');

commit;
