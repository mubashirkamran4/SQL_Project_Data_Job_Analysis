/*
**QUESTION: What are the most in-demand skills for data analysts?**

- Identify the top 5 in-demand skills for a data analyst.
- Focus on all job postings.
- Why? Retrieves the top 5 skills with the highest demand in the job market, providing insights into the most valuable skills for job seekers.
*/
SELECT skills AS skill_name,
       skills_dim.skill_id,
       count(skills_job_dim.job_id) AS number_of_job_postings,
       skills_dim.type
FROM skills_dim
INNER JOIN
    skills_job_dim ON skills_dim.skill_id = skills_job_dim.skill_id
INNER JOIN
    job_postings_fact ON job_postings_fact.job_id = skills_job_dim.job_id
WHERE
    job_title_short='Data Analyst'
GROUP BY
    skills_dim.skill_id
ORDER BY
    number_of_job_postings DESC
LIMIT 5
