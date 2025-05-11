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
    -- TOP 5 MOST , INCLUDE SKILL ID, NAME AND NUMBER OF THEIR JOB POSTINGS

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
