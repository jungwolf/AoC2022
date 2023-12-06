How well can ChatGPT answer the problem in Oracle sql?

chat01.txt: Output of first chat
chat01_script.sql: I formatted it's sql statements and ran them. Output wasn't correct.
chat02.txt: I gave feedback and asked for corrected statements.
chat02_code.sql: New code here. I didn't fix the issue.
chat01_script_my_review.sql: I debug the first answer.
chat03.txt: I tell it '' is null and also to review sum().
chat03_sql.sql: Revised answers that give correct result.

I say it did a good job. The answer first wasn't correct but close. Finding the issue wasn't hard, and telling it to take that into account resulted in a correct sql.

I first told it to act like an Oracle Sql Developer and solve the problem using sql. It assumed the data was already in a table with the right grouping. The sql looks like it would work with the presumed table.

I said the data was originally in a text file and had I loaded it into a table with linenumbers. I didn't give it the create table statement or insert statements. It generated sql that correctly assumed the details of the table. Finally, I asked it to write the statements to create the table and insert the data. I ran the statements, but the output wasn't correct.

In chat02 I told it the output was incorrect and to review it's code. The new sql didn't work either.

In chat01_script_my_review.sql I debug the original code. In Oracle, the empty string '' is considered NULL. That is, ('' = '') is false and ('' is NULL) is true. I don't know if other databases have the same rule. In any case, ChatGPT didn't handle '' correctly.

Then, I realized I can just tell it about the empty string. Chat03 has the results. The final sql worked.
