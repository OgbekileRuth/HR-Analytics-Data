
   CREATE TABLE hr_data (
    id VARCHAR(20) PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    birthdate DATE,
    gender VARCHAR(20),
    race VARCHAR(50),
    department VARCHAR(100),
    jobtitle VARCHAR(100),
    location VARCHAR(50),
    hire_date DATE,
    termdate DATE,
    location_city VARCHAR(50),
    location_state VARCHAR(50)
); 

--Checking for Duplicate
SELECT id, COUNT(*)
FROM dbo.[HR Data]
GROUP BY id
HAVING COUNT(*) > 1;

--checking missing values
UPDATE dbo.[HR Data]
SET gender =
CASE
    WHEN gender IN ('M','Male') THEN 'Male'
    WHEN gender IN ('F','Female') THEN 'Female'
    ELSE gender
END;

--Check missing Values
SELECT *
FROM dbo.[HR Data]
WHERE first_name IS NULL
   OR last_name IS NULL
   OR department IS NULL
   OR hire_date IS NULL;

--Standardize Gender
UPDATE dbo.[HR Data]
SET gender =
CASE
    WHEN gender IN ('M','Male') THEN 'Male'
    WHEN gender IN ('F','Female') THEN 'Female'
    ELSE gender
END;

--Standardize Department
UPDATE dbo.[HR Data]
SET department = TRIM(department);

--Remove Extra Space
UPDATE dbo.[HR Data]
SET
first_name = TRIM(first_name),
last_name = TRIM(last_name),
jobtitle = TRIM(jobtitle),
race = TRIM(race);

--Total Employees
SELECT COUNT(*) AS TotalEmployees
FROM dbo.[HR Data]

--Active Employees
SELECT COUNT(*) AS ActiveEmployees
FROM dbo.[HR Data]
WHERE termdate IS NULL;

--Employee by Gender
SELECT gender,
COUNT(*) AS Total
FROM dbo.[HR Data]
GROUP BY gender;

--Employee by Races
SELECT gender,
COUNT(*) AS Total
FROM dbo.[HR Data]
GROUP BY gender;

--Employee by Department
SELECT department,
COUNT(*) AS Employees
FROM dbo.[HR Data]
GROUP BY department
ORDER BY Employees DESC;

--Employee by State
SELECT location_state,
COUNT(*) Employees
FROM dbo.[HR Data]
GROUP BY location_state
ORDER BY Employees DESC;

--Employee Performance Analysis
SELECT jobtitle,
COUNT(*) Employees
FROM dbo.[HR Data]
GROUP BY jobtitle
ORDER BY Employees DESC;

--Employee in each department and Job
SELECT department,
jobtitle,
COUNT(*) Employees
FROM dbo.[HR Data]
GROUP BY department, jobtitle
ORDER BY department;

---Retention Analysis

SELECT COUNT(*) AS EmployeesLeft
FROM dbo.[HR Data]
WHERE termdate IS NOT NULL;

--Retention By Department

SELECT
department,
COUNT(*) TotalEmployees,
SUM(CASE WHEN termdate IS NOT NULL THEN 1 ELSE 0 END) LeftCompany
FROM dbo.[HR Data]
GROUP BY department;

--Retention By Rate

SELECT
department,

ROUND(
100.0 *
SUM(CASE WHEN termdate IS NULL THEN 1 ELSE 0 END)
/ COUNT(*),2
) AS RetentionRate

FROM dbo.[HR Data]
GROUP BY department;

SELECT
YEAR(hire_date) HiringYear,
COUNT(*) EmployeesHired
FROM dbo. [HR Data]
GROUP BY YEAR(hire_date)
ORDER BY HiringYear;

--Age Distribution
SELECT
    CASE
        WHEN DATEDIFF(YEAR, birthdate, GETDATE()) < 30 THEN 'Under 30'
        WHEN DATEDIFF(YEAR, birthdate, GETDATE()) BETWEEN 30 AND 39 THEN '30-39'
        WHEN DATEDIFF(YEAR, birthdate, GETDATE()) BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50+'
    END AS AgeGroup,
    COUNT(*) AS Employees
FROM dbo.[HR Data]
GROUP BY
    CASE
        WHEN DATEDIFF(YEAR, birthdate, GETDATE()) < 30 THEN 'Under 30'
        WHEN DATEDIFF(YEAR, birthdate, GETDATE()) BETWEEN 30 AND 39 THEN '30-39'
        WHEN DATEDIFF(YEAR, birthdate, GETDATE()) BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50+'
    END;
--CTE Reports
WITH EmployeeSummary AS
(
    SELECT
        department,
        COUNT(*) AS TotalEmployees,
        SUM(CASE WHEN termdate IS NULL THEN 1 ELSE 0 END) AS ActiveEmployees,
        SUM(CASE WHEN termdate IS NOT NULL THEN 1 ELSE 0 END) AS FormerEmployees
    FROM dbo.[HR Data]
    GROUP BY department
)
SELECT *
FROM EmployeeSummary;

---Window Function
--Rank Department
SELECT

department,

COUNT(*) Employees,

RANK() OVER(
ORDER BY COUNT(*) DESC
) DepartmentRank

FROM dbo.[HR Data]

GROUP BY department;

--Dense Rank
SELECT
    location_state,
    COUNT(*) AS Employees,
    DENSE_RANK() OVER (
        ORDER BY COUNT(*) DESC
    ) AS RankState
FROM dbo.[HR Data]
GROUP BY location_state
ORDER BY RankState;

--Join
ALTER VIEW DepartmentSummary AS
SELECT
    department,
    COUNT(*) AS Employees
FROM dbo.[HR Data]
GROUP BY department;

--To see the data
---Run
SELECT *
FROM DepartmentSummary;


--Final Executive Report (CTE + Join + Window Function)
WITH DeptStats AS
(
SELECT

department,

COUNT(*) TotalEmployees,

SUM(CASE WHEN termdate IS NULL THEN 1 ELSE 0 END) ActiveEmployees

FROM dbo.[HR Data]

GROUP BY department
)

SELECT

d.department,

d.TotalEmployees,

d.ActiveEmployees,

ROUND(d.ActiveEmployees*100.0/d.TotalEmployees,2) AS RetentionRate,

RANK() OVER(ORDER BY d.TotalEmployees DESC) AS DepartmentRank

FROM DeptStats d

ORDER BY DepartmentRank;