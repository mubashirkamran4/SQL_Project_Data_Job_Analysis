-- CASTING TO ANOTHER TYPE VIA ::
SELECT '2022-03-14'::DATE,
        '123'::INTEGER,
        '3.14'::REAL,
        'TRUE'::BOOLEAN;

-- EXTRACT() FUNCTION
SELECT job_title_short AS title,
        job_location AS location,
        job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST' AS date_time,
        EXTRACT(MONTH FROM job_posted_date) AS date_month,
        EXTRACT(YEAR FROM job_posted_date) AS date_year
FROM job_postings_fact LIMIT 5;

-- COUNT OF JOB POSTINGS
SELECT  COUNT(job_id) AS no_of_job_postings,
        EXTRACT(MONTH FROM job_posted_date) as month
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst'
GROUP BY month
ORDER BY no_of_job_postings DESC;

-- USING EXTRACT FUNCITON

CREATE TABLE january_jobs AS
    SELECT * FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1;


CREATE TABLE february_jobs AS
    SELECT * FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 2;


CREATE TABLE march_jobs AS
    SELECT * FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 3;

SELECT job_posted_date FROM march_jobs;


SELECT 
       COUNT(job_id) AS number_of_job_postings,
       CASE WHEN job_location = 'Anywhere' THEN 'Remote'
            WHEN job_location = 'New York, NY' THEN 'Local'
            ELSE 'Onsite'
       END AS location_category
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst'
GROUP BY location_category;

--SUBQUERIES AND CTES
SELECT * FROM (
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1
) AS january_jobs;

-- GET ALL COMPANIES NAMES AND IDS WHERE DEGREE IS NOT REQUIRED

SELECT 
    company_id,
    name AS company_name
FROM company_dim
WHERE company_id IN (
    SELECT company_id
    FROM job_postings_fact
    WHERE job_no_degree_mention = true
    ORDER BY company_id
);

-- GET ALL COMPANIES WITH MOST JOB OPENINGS

WITH company_job_count AS (
    SELECT company_id,
            COUNT(*) AS total_jobs
    FROM job_postings_fact
    GROUP BY company_id
)
SELECT company_dim.name, company_job_count.total_jobs 
        FROM company_dim 
        LEFT JOIN company_job_count ON  company_job_count.company_id = company_dim.company_id
        ORDER BY company_job_count.total_jobs DESC;

-- NUMBER OF REMOTE JOB OPERNINGS PER SKILL 
    -- TOP 5 MOST JOB SKILLS, INCLUDE SKILL ID, NAME AND NUMBER OF THEIR JOB POSTINGS

WITH remote_job_skills AS (
    SELECT skill_id,
            COUNT(*) AS skill_count
    FROM skills_job_dim AS skills_to_job
    INNER JOIN job_postings_fact ON job_postings_fact.job_id = skills_to_job.job_id
    WHERE job_postings_fact.job_work_from_home = TRUE
    AND job_postings_fact.job_title_short = 'Data Analyst'
    GROUP BY skill_id
)

SELECT skills.skill_id,
       skills AS skill_name,
       remote_job_skills.skill_count  FROM remote_job_skills
INNER JOIN skills_dim AS skills ON skills.skill_id = remote_job_skills.skill_id
ORDER BY skill_count DESC
LIMIT 5

-- UNION OPERATOR
SELECT job_title_short,
        company_id,
        job_location
FROM january_jobs

UNION ALL
SELECT job_title_short,
        company_id,
        job_location
FROM february_jobs
UNION ALL
SELECT job_title_short,
        company_id,
        job_location
FROM march_jobs


-- FIND JOB POSTINGS IN Q1 THAT HAVE A SALARY > $70K
    -- COMBINE JOB POSTING TABLES FROM FIRST QUARTER OF 2023  
    -- GET JOB POSTINGS WITH AVERAGE YEARLY SALARY > $70K

SELECT * FROM (SELECT job_title_short,
        company_id,
        job_location,
        salary_year_avg
FROM january_jobs

UNION
SELECT job_title_short,
        company_id,
        job_location,
        salary_year_avg
FROM february_jobs
UNION
SELECT job_title_short,
        company_id,
        job_location,
        salary_year_avg

FROM march_jobs) AS job_postings_q1
WHERE job_postings_q1.salary_year_avg > 70000
AND job_postings_q1.job_title_short = 'Data Analyst'
ORDER BY job_postings_q1.salary_year_avg DESC

-- PRACTICE POBLEMS DURING COURSE

/* DATABASES USED IN THE FOLLOWING PRACTICE PROBLEMS:
-- https://lukeb.co/sql_jobs_db
-- https://lukeb.co/sql_invoices_db

/*
PRACTICE PROBLEM 1

In the job_postings_fact table get the columns job_id, job_title_short ,
 job_location , and job_via columns. 
 And order it in ascending order by job_location.
*/

SELECT job_id,
        job_title_short,
        job_location,
        job_via
FROM
        job_postings_fact
ORDER BY
        job_location;


/*
PRACTICE PROBLEM 2

In the job_postings_fact table get the columns job_id, 
job_title_short , job_location , and job_via columns. 
And order it in descending order by job_title_short.
*/

SELECT job_id,
        job_title_short,
        job_location,
        job_via
FROM job_postings_fact
ORDER BY
      job_title_short DESC;

/*
PRACTICE PROBLEM 3

Look at only the first 10 entries for a query in the job_postings_fact table
that returns job_id, job_title_short, job_location, job_via columns. 
Order by the job_location in ascending order.
*/

SELECT job_id,
        job_title_short,
        job_location,
        job_via
FROM job_postings_fact
ORDER BY
        job_location DESC
LIMIT 10;

/*
PRACTICE PROBLEM 4

Problem Statement
Get the unique job locations in the job_postings_fact table. Return the results in alphabetical order.

Hint
To get unique job locations use DISTINCT.
To get the results in alphabetical order use ORDER BY.
*/

SELECT DISTINCT job_location
FROM job_postings_fact
ORDER BY job_location;

/*
PRACTICE PROBLEM 5

Problem Statement
In the job_postings_fact table get the columns job_id, job_title_short , 
job_location , job_via , and salary_year_avg columns. 
Order by job_id in ascending order. 
And only look at rows where job_title_short is ‘Data Engineer’.
*/

SELECT job_id,
        job_title_short,
        job_location,
        job_via,
        salary_year_avg
FROM
        job_postings_fact
WHERE
        job_title_short = 'Data Engineer'
ORDER BY
        job_id;

--DATABASE USED IN THE FOLLOWING PROBLEMS IS FROM THE SAME PROJECT DB AS CREATED IN SQL LOAD

/*
**COMPARISON: PRACTICE PROBLEM 1** 

- Get job details for BOTH 'Data Analyst' or 'Business Analyst' positions
    - For ‘Data Analyst,’ I want jobs only > $100k
    - For ‘Business Analyst,’ I only want jobs > $70K
- Only include jobs located in EITHER:
    - 'Boston, MA'
    - 'Anywhere' (i.e., Remote jobs)
- Query Notes: Include job title abbreviation, location, posting source, and average yearly salary
*/

SELECT job_title_short,
	job_location,
    job_via,
    salary_year_avg
FROM job_postings_fact
WHERE (
  		(
          (job_title_short='Data Analyst' AND salary_year_avg>100000) OR (job_title_short='Business Analyst' AND salary_year_avg>70000)
        )
      	AND (job_location IN ('Boston, MA', 'Anywhere'))
);


/*
COMPARISONS

Problem Statement
In the job_postings_fact table get the job_id, job_title_short, job_location, job_via, and salary_year_avg columns.
 Order by job_id in ascending order. Only return rows where the job location is in ‘Tampa, FL’.
*/
SELECT job_id, job_title_short, job_location, job_via, salary_year_avg
FROM job_postings_fact
WHERE job_location='Tampa, FL'
ORDER BY job_id

/*
In the job_postings_fact table get the job_id, job_title_short, job_location, job_via, salary_year_avg, and job_schedule_type columns. 
Order by job_id in ascending order. Only return ‘Full-time’ jobs.
*/
SELECT job_id, job_title_short, job_location, job_via, salary_year_avg, job_schedule_type
FROM job_postings_fact
WHERE job_schedule_type='Full-time'
ORDER BY job_id


/*
In the job_postings_fact table get the job_id, job_title_short, job_location, job_via,  job_schedule_type, and salary_year_avg columns. 
Order by job_id in ascending order. Only look at jobs that are not ‘Part-time’ jobs.
*/

SELECT job_id, job_title_short, job_location, job_via, salary_year_avg, job_schedule_type
FROM job_postings_fact
WHERE job_schedule_type <> 'Full-time'
ORDER BY job_id

/*
In the job_postings_fact table get the job_id, job_title_short, job_location, job_via, and salary_year_avg columns. 
Order by job_id in ascending order. Only look at jobs that are not posted ‘via LinkedIn’.
*/

SELECT job_id, job_title_short, job_location, job_via, salary_year_avg, job_schedule_type
FROM job_postings_fact
WHERE job_via != 'via Linkedin'
ORDER BY job_id

/*
In the job_postings_fact table only get jobs that have an average yearly salary of $65,000 or greater. 
Also get the job_id, job_title_short, job_location, job_via, and salary_year_avg columns. Order by job_id in ascending order.
*/

SELECT job_id, job_title_short, job_location, job_via, salary_year_avg
FROM job_postings_fact
WHERE salary_year_avg >= 65000
ORDER BY job_id

/*
Only return jobs with a salary between (inclusive) $50,000 and $70,000 from the job_postings_fact table. 
And get the job_id, job_title_short, job_location, job_via and salary_year_avg columns. Order by job_id in ascending order.
*/
SELECT job_id, job_title_short, job_location, job_via, salary_year_avg
FROM job_postings_fact
WHERE salary_year_avg BETWEEN 50000 AND 70000
ORDER BY job_id

/*
Return job_title_short that are ‘Data Analyst’, ‘Data Scientist’ or ‘Business Analyst’ roles from the job_postings_fact table using the IN operator. 
Also, return the job_id, job_title_short, job_location, job_via and salary_year_avg columns. Order by job_id in ascending order.
*/
SELECT job_id, job_title_short, job_location, job_via, salary_year_avg
FROM job_postings_fact
WHERE job_title_short IN ('Data Analyst', 'Data Scientist', 'Business Analyst')
ORDER BY job_id

/*
In the job_postings_fact table look at Data Analyst jobs whose average yearly salary range is between $50,000 and $75,000.
 Return the job_id, job_title_short, job_location and salary_year_avg. Order by job_id in ascending order.
*/

SELECT job_id, job_title_short, job_location, salary_year_avg
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst'
AND salary_year_avg BETWEEN 50000 AND 75000
ORDER BY job_id

/*
In the job_postings_fact table, look at Data Analyst and Business Analyst jobs whose average yearly salary range is greater than $75,000. 
Return the job_id, job_title_short, job_location, salary_year_avg, and job_schedule_type. Order by job_id in ascending order.
*/

SELECT job_id, job_title_short, job_location, salary_year_avg, job_schedule_type
FROM job_postings_fact
WHERE job_title_short IN ('Data Analyst', 'Business Analyst')
AND salary_year_avg > 75000
ORDER BY job_id


-- WILDCARDS

/*
In the company_dim table, find all company names that include ‘Tech’ immediately followed by any single character. (e.g., "Lego Techs" or "Mario SuperTech.")
Return only the name column and return it in ascending order by the company name.
*/
SELECT name
FROM company_dim
WHERE name LIKE '%Tech_'

/*
Find all job postings in the job_postings_fact where the job_title includes "Engineer" in it with ONLY one character followed after the term. 
Get the job_id , job_title, and job_posted_date. Order by job_id in ascending order.
*/
SELECT job_id, job_title, job_posted_date
FROM job_postings_fact
WHERE job_title LIKE '%Engineer_'
ORDER BY job_id

/*
Identify job postings in the job_postings_fact table where the job_title contains the pattern "a_a" anywhere in the title. 
Return the job_id and job_title columns. Order by job_id in ascending order.
*/
SELECT job_id, job_title
FROM job_postings_fact
WHERE job_title LIKE '%a_a%'
ORDER BY job_id

-- OPERATIONS



/*
In the invoices_fact table, suppose each project has a fixed budget cap. You’re told the budget cap is $100,000 for every activity.

Subtract the actual cost of the activity (calculated as hours_spent * hours_rate) from the budget cap to find how much budget is left.
Name this new column remaining_budget.

Return the activity_id and remaining_budget, and order the results by activity_id in ascending order.
*/

SELECT activity_id,
        100000 - (hours_spent*hours_rate) AS remaining_budget
FROM invoices_fact
ORDER BY activity_id

/*
In the invoices_fact table, each activity has a base cost calculated as hours_spent * hours_rate. Assume a flat travel fee of $150 is charged per activity.

Add this flat fee to the base cost, and name the resulting column total_cost_with_travel.
Return the activity_id and total_cost_with_travel, ordered by activity_id in ascending order.
*/

SELECT activity_id,
        150 + (hours_spent*hours_rate) AS total_cost_with_travel
FROM invoices_fact
ORDER BY activity_id

/*
In the job_postings_fact table count the total number of job postings that offer health insurance.
*/
SELECT 
	COUNT(*) AS jobs_with_health_insurance
FROM 
	job_postings_fact
WHERE 
	job_health_insurance = TRUE;

/*
In the job_postings_fact table count the number of job postings available for each country. 
Return job_country and the job count. Order by job_country in ascending order.
*/

SELECT count(*) AS number_of_job_postings,
        job_country
FROM job_postings_fact
GROUP BY job_country
ORDER BY job_country

/*
In the job_postings_fact table calculate the total sum of the average yearly salary (salary_year_avg) for all job postings that are marked as fully remote 
and divide it by the total count of salary_year_avg. 


To get the total average yearly salary for fully remote jobs. Ensure to only include job postings where a yearly salary is specified (salary_year_avg IS NOT NULL).
*/

SELECT SUM(salary_year_avg)/COUNT(salary_year_avg) as summed_yearly_avg_salary
FROM job_postings_fact
WHERE job_work_from_home = TRUE
AND salary_year_avg IS NOT NULL

/*
In the job_postings_fact table, find the minimum and maximum yearly salaries (salary_year_avg) offered for job postings in locations that include ‘San Francisco’ 
in the location title. The query should return two columns: one for the minimum yearly salary and one for the maximum yearly salary, 
considering only job postings that specify a yearly salary (salary_year_avg IS NOT NULL).
*/

SELECT MIN(salary_year_avg) as minimum_yearly_salary,
        MAX(salary_year_avg) as maximum_yearly_salary
FROM job_postings_fact
WHERE job_location = '%San Francisco%'
AND salary_year_avg IS NOT NULL

/*
In the job_postings_fact table, determine the average yearly salaries (salary_year_avg) for ‘Data Scientist’ job postings, using the job_title_short column. 
Your query should return one column for the average yearly salary. Only include jobs that have a yearly salary (salary_year_avg IS NOT NULL).
*/

SELECT AVG(salary_year_avg) as average_yearly_salary
FROM job_postings_fact
WHERE job_title_short = 'Data Scientist'
AND salary_year_avg IS NOT NULL

/*

Using the job_postings_fact table, find the average, minimum, and maximum salary range for each job_title_short. 
Only include job titles with more than 1,000 job postings and group data by job_title_short . Order by job_title_short in ascending order.
*/

SELECT AVG(salary_year_avg) as average_yearly_salary
FROM job_postings_fact
WHERE job_title_short = 'Data Scientist'
AND salary_year_avg IS NOT NULL

/*
Using the job_postings_fact table, find the average, minimum, and maximum salary range for each job_title_short. 
Only include job titles with more than 1,000 job postings and group data by job_title_short . Order by job_title_short in ascending order.
*/

SELECT MAX(salary_year_avg) AS maximum_yearly_salary,
        MIN(salary_year_avg) AS minimum_yearly_salary,
        AVG(salary_year_avg) AS average_yearly_salary,
        job_title_short,
        job_title
FROM
        job_postings_fact
GROUP BY
        job_title_short
HAVING
        count(job_title) > 1000
ORDER BY
        job_title_short

/*
In the job_postings_fact table list countries along with their average yearly salary (salary_year_avg) for job postings,
where the average yearly salary exceeds $100,000. Group the results by job_country. 
Only get job postings where there is an average yearly salary included (salary_year_avg IS NOT NULL).
*/
SELECT job_country,
        AVG(salary_year_avg) AS average_yearly_salary
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
GROUP BY job_country
HAVING average_yearly_salary > 100000

/*
In the job_postings_fact table count the number of job postings for each location (job_location) that do NOT offer remote work. 
Display the location and the count of non-remote job postings, and order the results by the count in descending order. 
Show locations where the average salary for non-remote jobs is above $70,000.
*/
SELECT job_location,
        COUNT(job_id) AS number_of_non_remote_job_postings,
        AVG(salary_year_avg) AS average_yearly_salary
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL AND job_location IS NOT NULL AND job_work_from_home = FALSE
GROUP BY job_location
HAVING average_yearly_salary > 70000
ORDER BY number_of_non_remote_job_postings DESC

-- DATE FUNCTIONS

/*
Count the number of job postings for each month in 2023, adjusting the job_posted_date to be in 'America/New_York' time zone before extracting the month.
Assume the job_posted_date is stored in UTC. Group by and order by the month.
*/
SELECT EXTRACT(MONTH FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York') AS job_posted_month,
       COUNT(*) AS number_of_job_postings
FROM
    job_postings_fact
GROUP BY
    job_posted_month
ORDER BY
    job_posted_month


-- CTES AND SUBQUERIES

/*
Find companies that offer an average salary above the overall average yearly salary of all job postings.
*/

SELECT company_dim.company_id,
        name
FROM company_dim
INNER JOIN (
        SELECT AVG(salary_year_avg) AS company_avg_salary,
                company_id
        FROM job_postings_fact
        GROUP BY company_id
) AS company_average_salaries
ON company_dim.company_id = company_average_salaries.company_id
WHERE
        company_average_salaries.company_avg_salary > (
                SELECT AVG(salary_year_avg) AS average_job_postings_salary FROM job_postings_fact
        )

/*
Explore job postings by listing job id, job titles, company names, and their average salary rates, 
while categorizing these salaries relative to the average in their respective countries. 
Include the month of the job posted date. Use CTEs, conditional logic, and date functions, to compare individual salaries with national averages.
*/
WITH country_average_salaries AS (
        SELECT AVG(salary_year_avg) AS country_average_salary,
                job_country
        FROM job_postings_fact
        GROUP BY job_country
)
SELECT job_id, job_title, company_dim.name, salary_year_avg, EXTRACT(MONTH FROM job_posted_date) AS job_posting_month,
CASE WHEN
        job_postings_fact.salary_year_avg > country_average_salaries.country_average_salary
THEN 'ABOVE AVERAGE'
ELSE 'BELOW AVERAGE' 
END AS salary_category
FROM job_postings_fact
INNER JOIN company_dim ON company_dim.company_id = job_postings_fact.company_id
INNER JOIN country_average_salaries ON country_average_salaries.job_country = job_postings_fact.job_country
ORDER BY job_posting_month DESC

/*
Calculate the number of unique skills required by each company. 
Aim to quantify the unique skills required per company and identify which of these companies offer the highest average salary for positions necessitating at least one skill.
For entities without skill-related job postings, list it as a zero skill requirement and a null salary. 
Use CTEs to separately assess the unique skill count and the maximum average salary offered by these companies.
*/

WITH distinct_skills_companies AS (
        SELECT COUNT(DISTINCT(skills_job_dim.skill_id)) AS unique_skills_required,
                company_dim.company_id
        FROM
                job_postings_fact
        LEFT JOIN company_dim
        ON company_dim.company_id = job_postings_fact.company_id
        LEFT JOIN skills_job_dim
        ON job_postings_fact.job_id = skills_job_dim.job_id
        GROUP BY company_dim.company_id
),
max_salary AS (
        SELECT MAX(salary_year_avg) AS highest_average_salary,
                company_id
        from
                job_postings_fact
        WHERE job_postings_fact.job_id IN (SELECT job_id from skills_job_dim)
        GROUP BY
                company_id
)
SELECT
    company_dim.name,
    distinct_skills_companies.unique_skills_required as unique_skills_required,
    max_salary.highest_average_salary
FROM
    company_dim
LEFT JOIN distinct_skills_companies ON company_dim.company_id = distinct_skills_companies.company_id
LEFT JOIN max_salary ON company_dim.company_id = max_salary.company_id
ORDER BY
    company_dim.name;


/*
Analyze the monthly demand for skills by counting the number of job postings for each skill in the first quarter (January to March), 
utilizing data from separate tables for each month. Ensure to include skills from all job postings across these months. 
The tables for the first quarter job postings were created in Practice Problem 6.
*/

WITH first_quarter_jobs as (
        SELECT job_id, 
                company_id,
                job_title_short,
                job_posted_date
        FROM january_jobs
        UNION ALL
        SELECT job_id, 
                company_id,
                job_title_short,
                job_posted_date
        FROM february_jobs
        UNION ALL
        SELECT job_id, 
                company_id,
                job_title_short,
                job_posted_date
        FROM march_jobs
)
SELECT skills,
        skills_dim.skill_id,
        count(first_quarter_jobs.job_id) AS number_of_job_postings,
        EXTRACT(MONTH FROM first_quarter_jobs.job_posted_date) AS job_posting_month,
        EXTRACT(YEAR FROM first_quarter_jobs.job_posted_date) AS job_posting_year
        
FROM
        skills_dim
        INNER JOIN skills_job_dim
        ON skills_dim.skill_id = skills_job_dim.skill_id
        INNER JOIN first_quarter_jobs
        ON first_quarter_jobs.job_id = skills_job_dim.job_id
GROUP BY
        skills_dim.skill_id,
        job_posting_month,
        job_posting_year
ORDER BY skills