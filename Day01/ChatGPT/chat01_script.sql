CREATE TABLE input_data (
    linenumber INT,
    linetext VARCHAR2(100)
);

INSERT INTO input_data (linenumber, linetext) VALUES (1, '1000');
INSERT INTO input_data (linenumber, linetext) VALUES (2, '2000');
INSERT INTO input_data (linenumber, linetext) VALUES (3, '3000');
INSERT INTO input_data (linenumber, linetext) VALUES (4, NULL); -- Blank line
INSERT INTO input_data (linenumber, linetext) VALUES (5, '4000');
INSERT INTO input_data (linenumber, linetext) VALUES (6, NULL); -- Blank line
INSERT INTO input_data (linenumber, linetext) VALUES (7, '5000');
INSERT INTO input_data (linenumber, linetext) VALUES (8, '6000');
INSERT INTO input_data (linenumber, linetext) VALUES (9, NULL); -- Blank line
INSERT INTO input_data (linenumber, linetext) VALUES (10, '7000');
INSERT INTO input_data (linenumber, linetext) VALUES (11, '8000');
INSERT INTO input_data (linenumber, linetext) VALUES (12, '9000');
INSERT INTO input_data (linenumber, linetext) VALUES (13, NULL); -- Blank line
INSERT INTO input_data (linenumber, linetext) VALUES (14, '10000');

-- my addition
commit;

WITH GroupedData AS (
    SELECT
        linenumber,
        linetext,
        SUM(CASE WHEN TRIM(linetext) IS NULL OR TRIM(linetext) = '' THEN 1 ELSE 0 END)
            OVER (ORDER BY linenumber) AS Elf_Group
    FROM input_data
),
SummedCalories AS (
    SELECT
        Elf_Group,
        SUM(TO_NUMBER(linetext)) AS Total_Calories
    FROM GroupedData
    WHERE TRIM(linetext) IS NOT NULL AND TRIM(linetext) <> ''
    GROUP BY Elf_Group
)
SELECT Elf_Group, Total_Calories
FROM SummedCalories
ORDER BY Total_Calories DESC
FETCH FIRST 1 ROW ONLY;

/* output
ELF_GROUP	TOTAL_CALORIES
** No Records **	
*/
-- didn't work, give feedback.
