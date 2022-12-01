drop sequence line_number_sq;
create sequence line_number_sq;

drop table day01_example;
create table day01_example (lineno number, linevalue varchar2(4000));

drop synonym input_data; 
create synonym input_data for day01_example;

--insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'
--');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'1000');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'2000');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'3000');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'4000');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'5000');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'6000');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'7000');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'8000');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'9000');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'10000');

commit;
