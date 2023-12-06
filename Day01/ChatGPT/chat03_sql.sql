-- after reminding it '' is considered null
WITH ElfGroups AS (
    SELECT 
        linenumber, 
        linetext,
        SUM(CASE WHEN linetext IS NULL THEN 1 ELSE 0 END) 
            OVER (ORDER BY linenumber ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Elf_Group
    FROM input_data
),
SummedCalories AS (
    SELECT 
        Elf_Group, 
        SUM(CASE WHEN linetext IS NOT NULL THEN TO_NUMBER(linetext) ELSE 0 END) AS Total_Calories
    FROM ElfGroups
    GROUP BY Elf_Group
)
SELECT Elf_Group, Total_Calories
FROM SummedCalories
WHERE Total_Calories > 0
ORDER BY Total_Calories DESC
FETCH FIRST 1 ROW ONLY;

-- after telling it to review sum()
WITH ElfGroups AS (
    SELECT 
        linenumber, 
        linetext,
        SUM(CASE WHEN linetext IS NULL THEN 1 ELSE 0 END) 
            OVER (ORDER BY linenumber ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Elf_Group
    FROM input_data
),
SummedCalories AS (
    SELECT 
        Elf_Group, 
        SUM(TO_NUMBER(linetext)) AS Total_Calories
    FROM ElfGroups
    WHERE linetext IS NOT NULL
    GROUP BY Elf_Group
)
SELECT Elf_Group, Total_Calories
FROM SummedCalories
ORDER BY Total_Calories DESC
FETCH FIRST 1 ROW ONLY;
