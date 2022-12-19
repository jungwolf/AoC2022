exec drop_object_if_exists('line_number_sq','sequence');
create sequence line_number_sq;

exec drop_object_if_exists('day18_example','table');
create table day18_example (lineno number, linevalue varchar2(4000));

create or replace synonym input_data for day18_example;

--insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'
--');

insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'2,2,2');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'1,2,2');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'3,2,2');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'2,1,2');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'2,3,2');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'2,2,1');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'2,2,3');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'2,2,4');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'2,2,6');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'1,2,5');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'3,2,5');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'2,1,5');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'2,3,5');

commit;
