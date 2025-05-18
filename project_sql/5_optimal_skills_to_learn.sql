/*
**QUESTION: What are the top skills based on salary?** 

- Look at the average salary associated with each skill for Data Analyst positions.
- Focuses on roles with specified salaries, regardless of location.
- Why? It reveals how different skills impact salary levels for Data Analysts and helps identify the most financially rewarding skills to acquire or improve.
*/

WITH in_demand_skills AS
        (SELECT skills AS skill_name,
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
            skills_dim.skill_id), 
    most_payed_skills AS
        (
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
        )
SELECT in_demand_skills.skill_id,
        in_demand_skills.type,
        in_demand_skills.skill_name,
        in_demand_skills.number_of_job_postings,
        most_payed_skills.highest_yearly_avg_salary
FROM
        in_demand_skills
INNER JOIN most_payed_skills ON in_demand_skills.skill_id = most_payed_skills.skill_id

