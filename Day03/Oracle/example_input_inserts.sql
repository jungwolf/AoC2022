drop sequence line_number_sq;
create sequence line_number_sq;

drop table   day03_example;
create table day03_example (lineno number, linevalue varchar2(4000));

create or replace synonym input_data for day03_example;

--insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'
--');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'vJrwpWtwJgWrhcsFMMfFFhFp');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'PmmdzqPrVvPwwTWBwg');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'ttgJtRGJQctTZtZT');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'CrZsJsPPZsGzwwsLwLmpwMDw');

commit;
