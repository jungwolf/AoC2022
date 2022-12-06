drop sequence line_number_sq;
create sequence line_number_sq;

drop table   day05_example;
create table day05_example (lineno number, linevalue varchar2(4000));

create or replace synonym input_data for day05_example;

--insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'
--');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'    [D]    ');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'[N] [C]    ');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'[Z] [M] [P]');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,' 1   2   3 ');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'move 1 from 2 to 1');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'move 3 from 1 to 3');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'move 2 from 2 to 1');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'move 1 from 1 to 2');

commit;
