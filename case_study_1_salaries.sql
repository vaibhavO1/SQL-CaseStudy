USE 5_sql_casestudy;

/* 
You're a Compensation analyst employed by a multinational corporation. 
Your Assignment is to Pinpoint Countries who give work fully remotely, for the title 'managers’ Paying salaries Exceeding $90,000 USD
*/
SELECT DISTINCT company_location FROM salaries 
WHERE job_title LIKE '%Manager%' AND salary_in_usd > 90000 AND remote_ratio = 100;

/*
AS a remote work advocate Working for a progressive HR tech startup who place their freshers’ clients IN large tech firms. 
You're tasked WITH Identifying top 5 Country Having greatest count of large (company size) number of companies.
*/
SELECT company_location,COUNT(*) AS '#companies' FROM salaries
WHERE experience_level = 'EN' AND company_size = 'L'
GROUP BY company_location
ORDER BY COUNT(*) DESC LIMIT 5;

/*
Picture yourself AS a data scientist Working for a workforce management platform. 
Your objective is to calculate the percentage of employees. 
Who enjoy fully remote roles WITH salaries Exceeding $100,000 USD, Shedding light ON the attractiveness of high-paying remote positions IN today's job market.
*/
SET @total = (SELECT COUNT(*) FROM salaries WHERE salary_in_usd > 100000);
SET @enjoy = (SELECT COUNT(*) FROM salaries WHERE remote_ratio = 100 AND salary_in_usd > 100000);
SELECT ROUND(((SELECT @enjoy)/(SELECT @total)*100),4) AS 'happy_employee_percentage';

/*
Imagine you're a data analyst Working for a global recruitment agency. 
Your Task is to identify the Locations where entry-level average salaries exceed the average salary for that job title 
IN market for entry level, helping your agency guide candidates towards lucrative opportunities.
*/
SELECT DISTINCT company_location FROM
(SELECT job_title,AVG(salary_in_usd) AS 'market_avg' FROM salaries
WHERE experience_level = 'EN'
GROUP BY job_title) t1
INNER JOIN
(SELECT company_location,job_title,AVG(salary_in_usd) AS 'country_avg' FROM salaries
WHERE experience_level = 'EN'
GROUP BY job_title,company_location) t2 ON t1.job_title = t2.job_title 
WHERE country_avg > market_avg;

/*
You've been hired by a big HR Consultancy to look at how much people get paid IN different Countries. 
Your job is to Find out for each job title which. Country pays the maximum average salary. 
This helps you to place your candidates IN those countries.
*/
SELECT * FROM
(SELECT job_title,company_location,AVG(salary_in_usd),DENSE_RANK() OVER(PARTITION BY job_title ORDER BY AVG(salary_in_usd) DESC) AS num
FROM salaries
GROUP BY company_location,job_title
ORDER BY job_title) t
WHERE num = 1;

/*
AS a data-driven Business consultant, you've been hired by a multinational corporation to analyze salary trends across different company 
Locations. Your goal is to Pinpoint Locations WHERE the average salary Has consistently Increased over the Past few years (Countries WHERE 
data is available for 3 years Only(present year and past two years) providing Insights into Locations experiencing Sustained salary growth.
*/  
WITH countries AS
(SELECT company_location,COUNT(DISTINCT work_year) AS cnt,AVG(salary_in_usd) FROM salaries
WHERE work_year >= YEAR(current_date())-2
GROUP BY company_location HAVING cnt = 3
ORDER BY company_location)

SELECT company_location FROM
(SELECT company_location,work_year,DENSE_RANK() OVER(PARTITION BY company_location ORDER BY work_year) AS runk FROM
(SELECT company_location,work_year,AVG(salary_in_usd) AS avg_salary,
LAG(AVG(salary_in_usd)) OVER(PARTITION BY company_location ORDER BY work_year) AS comp FROM salaries
WHERE work_year >= YEAR(current_date())-2
AND company_location IN (SELECT company_location FROM countries)
GROUP BY work_year,company_location
ORDER BY company_location,work_year) t3
WHERE avg_salary > comp) t4
WHERE runk = 2;

/*
Picture yourself AS a workforce strategist employed by a global HR tech startup. Your Mission is to Determine 
the percentage of fully remote work for each experience level IN 2021 and compare it WITH the corresponding figures for 2024, 
Highlighting any significant Increases or decreases IN remote work Adoption over the years.
*/
SELECT *,
CASE WHEN t11.remotly_2021 < t11.remotly_2024 THEN 'Increase' ELSE 'Decrease' END AS highlight FROM
(SELECT t9.experience_level,t9.remotly_2021,t10.remotly_2024 FROM
(SELECT *,(remotly/total)*100 AS remotly_2021 FROM
(SELECT experience_level,COUNT(*) AS total FROM salaries
WHERE work_year = 2021 
GROUP BY experience_level) t5
NATURAL JOIN
(SELECT experience_level,COUNT(*) AS remotly FROM salaries
WHERE work_year = 2021 AND remote_ratio = 100
GROUP BY experience_level) t6) t9
INNER JOIN
(SELECT *,(remotly/total)*100 AS remotly_2024 FROM
(SELECT experience_level,COUNT(*) AS total FROM salaries
WHERE work_year = 2024 
GROUP BY experience_level) t7
NATURAL JOIN
(SELECT experience_level,COUNT(*) AS remotly FROM salaries
WHERE work_year = 2024 AND remote_ratio = 100
GROUP BY experience_level) t8) t10 
ON t9.experience_level = t10.experience_level) t11;

/*
AS a Compensation specialist at a Fortune 500 company, you're tasked WITH analyzing salary trends over time. 
Your objective is to calculate the average salary increase percentage for each experience level and job title 
between the years 2023 and 2024, helping the company stay competitive IN the talent market.
*/
SELECT t12.job_title,t12.experience_level,salary_2023,salary_2024,ROUND(((salary_2024-salary_2023)/salary_2023)*100,2) AS percentage FROM
(SELECT job_title,experience_level,AVG(salary_in_usd) AS salary_2023 FROM salaries
WHERE work_year = 2023
GROUP BY job_title,experience_level) t12
INNER JOIN
(SELECT job_title,experience_level,AVG(salary_in_usd) AS salary_2024 FROM salaries
WHERE work_year = 2024
GROUP BY job_title,experience_level) t13
ON t12.job_title=t13.job_title AND t12.experience_level=t13.experience_level;

/*
You're a database administrator tasked with role-based access control for a company's employee database. 
Your goal is to implement a security measure where employees in different experience level (e.g. Entry Level, Senior level etc.) 
can only access details relevant to their respective experience level, ensuring data confidentiality and minimizing the risk of unauthorized access.
*/
CREATE USER  'entry_level'@'%' IDENTIFIED BY 'user';

CREATE VIEW entry_table AS
(SELECT * FROM salaries WHERE experience_level='EN');