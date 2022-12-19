drop sequence line_number_sq;
create sequence line_number_sq;

drop table   day06_example;
create table day06_example (lineno number, linevalue varchar2(4000));

create or replace synonym input_data for day06_example;

--insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'
--');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'mjqjpqmgbljsphdztnvjfqwrcgsmlb');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'bvwbjplbgvbhsrlpgdmjqwftvncz');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'nppdvjthqldpwncqszvftbrmjlhg');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg');
insert into input_data (lineno, linevalue) values (line_number_sq.nextval,'zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw');

commit;
