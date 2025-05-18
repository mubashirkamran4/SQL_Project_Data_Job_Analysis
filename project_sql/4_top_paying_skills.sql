/*
**QUESTION: What are the top skills based on salary?** 

- Look at the average salary associated with each skill for Data Analyst positions.
- Focuses on roles with specified salaries, regardless of location.
- Why? It reveals how different skills impact salary levels for Data Analysts and helps identify the most financially rewarding skills to acquire or improve.
*/

SELECT skills AS skill_name,
        skills_dim.skill_id,
        ROUND(AVG(salary_year_avg), 2) AS highest_yearly_avg_salary,
        type
FROM
    skills_dim
INNER JOIN
    skills_job_dim ON skills_dim.skill_id = skills_job_dim.skill_id
INNER JOIN
    job_postings_fact ON skills_job_dim.job_id = job_postings_fact.job_id
WHERE
    job_title_short = 'Data Analyst'
    AND salary_year_avg IS NOT NULL
GROUP BY
    skills_dim.skill_id
ORDER BY
    highest_yearly_avg_salary DESC
LIMIT 5