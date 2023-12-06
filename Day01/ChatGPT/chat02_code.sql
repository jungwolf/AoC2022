WITH ElfGroups AS (
    SELECT
        linenumber,
        linetext,
        SUM(CASE WHEN linetext IS NULL OR TRIM(linetext) = '' THEN 1 ELSE 0 END)
            OVER (ORDER BY linenumber ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Elf_Group
    FROM input_data
),
SummedCalories AS (
    SELECT
        Elf_Group,
        SUM(CASE WHEN linetext IS NOT NULL AND TRIM(linetext) <> '' THEN TO_NUMBER(linetext) ELSE 0 END) AS Total_Calories
    FROM ElfGroups
    GROUP BY Elf_Group
)
SELECT Elf_Group, Total_Calories
FROM SummedCalories
WHERE Total_Calories > 0
ORDER BY Total_Calories DESC
FETCH FIRST 1 ROW ONLY;
-- same problem
