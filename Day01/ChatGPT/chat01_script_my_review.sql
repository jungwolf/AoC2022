-- troubleshooting
select * from input_data;
-- good, correctly created table

    SELECT
        linenumber,
        linetext,
        SUM(CASE WHEN TRIM(linetext) IS NULL OR TRIM(linetext) = '' THEN 1 ELSE 0 END)
            OVER (ORDER BY linenumber) AS Elf_Group
    FROM input_data
/
-- grouping looks good, the null lines are the start of a group

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
--    WHERE TRIM(linetext) IS NOT NULL AND TRIM(linetext) <> ''
    WHERE 1=1
--      and TRIM(linetext) IS NOT NULL
      AND TRIM(linetext) <> ''
    GROUP BY Elf_Group
)
select * from SummedCalories;
/*
The problem is with SummedCalories.
The where clause isn't needed, sum() ignores nulls
However, if added, TRIM(linetext) IS NOT NULL doesn't change the results
This does change the results: TRIM(linetext) <> ''
Oracle treats the empty string '' as a null, so this line is always null
*/

-- fixed code
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
--    WHERE TRIM(linetext) IS NOT NULL AND TRIM(linetext) <> ''
    GROUP BY Elf_Group
)
SELECT Elf_Group, Total_Calories
FROM SummedCalories
ORDER BY Total_Calories DESC
FETCH FIRST 1 ROW ONLY;
/*
ELF_GROUP	TOTAL_CALORIES
3	24000
*/
-- output is correct for the example
