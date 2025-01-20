$$$sql
create database Human_Resource;

use human_resource;

select * from hr;

-- ------------------- RENAME------------------------

ALTER TABLE hr
CHANGE COLUMN ï»¿id emp_id VARCHAR(20);

-- ------------------------CHECK FOR DATASET--------------------------

DESC hr;

-- ------------------------CHANGE DATE FORMAT-----------------------------
SELECT birthdate FROM HR;

SELECT birthdate,
CASE
	WHEN birthdate like '%%/%%' then date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
    	WHEN birthdate like '%%-%%' then date_format(str_to_date(birthdate,'%m-%d-%Y'),'%Y-%m-%d')
        else null
        end  as birthdate
from hr;


UPDATE hr
SET birthdate = CASE
	WHEN birthdate like '%%/%%' then date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
    	WHEN birthdate like '%%-%%' then date_format(str_to_date(birthdate,'%m-%d-%Y'),'%Y-%m-%d')
        else null
        end;


UPDATE hr
SET hire_date = CASE
	WHEN hire_date like '%%/%%' then date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
    	WHEN hire_date like '%%-%%' then date_format(str_to_date(hire_date,'%m-%d-%Y'),'%Y-%m-%d')
        else null
        end;
        
select hire_date,birthdate from hr;
-- --------------------------CHANGE DATA TYPE--------------------------------        
ALTER TABLE hr
MODIFY COLUMN birthdate DATE;

ALTER TABLE hr
MODIFY COLUMN hire_date DATE;

-- ------------------------CHANGE DATE DATA TYPE--------------------------------

SELECT termdate from hr;

UPDATE hr
SET termdate = DATE(STR_TO_DATE(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND TRIM(termdate) != '';

UPDATE hr
SET termdate = '0000-00-00'
WHERE termdate IS NULL OR TRIM(termdate) = '';

ALTER TABLE hr
MODIFY COLUMN termdate date;

select termdate from hr;

UPDATE hr
SET termdate = '0000-00-00'
WHERE termdate is null;

-- ------------------------------------ADD AGE-----------------------------------
ALTER TABLE hr
ADD COLUMN age VARCHAR(5);

select * FROM hr;

select birthdate,timestampdiff(year,birthdate,curdate()) as age
from hr;

update hr
set age = timestampdiff(year,birthdate,curdate());

select age from hr;

-- -------------------------------------------Questions-----------------------------------------------

-- 1. What is the gender breakdown of employees in the company?

select * from hr;

select gender,count(*) gender_cnt
from hr
where age >= 18 and termdate = 0000-00-00
group by gender;

-- 2. What is the race/ethnicity breakdown of employees in the company?

select race,count(*) race_cnt
from hr
where age >= 18 and termdate = 0000-00-00
group by race;

-- 3. What is the age distribution of employees in the company?

select age,count(*) age_cnt
from hr
where age >= 18 and termdate = 0000-00-00
group by age;

select min(age) young,
max(age) old
from hr
where age >= 18 and termdate = 0000-00-00;


select 
case
when age >=18 and age<= 24 then '18-24'
when age >=25 and age<= 34 then '25-34'
when age >=35 and age<= 44 then '35-44'
when age >=45 and age<= 54 then '45-54'
else '55+'
end as 'age_group',gender,count(*) as count
from hr
where age >= 18 and termdate = 0000-00-00
group by age_group,gender
order by age_group,gender;

-- 4. How many employees work at headquarters versus remote locations?

select location,count(*) count
 from hr
 where age >= 18 and termdate = 0000-00-00
 group by location;
 
 -- 5. What is the average length of employment for employees who have been terminated?

select round(avg(datediff(termdate,hire_date)/365),0)as avg_emp_len
from hr
where termdate<=curdate() and termdate<>0000-00-00 and age>=18;

-- 6. How does the gender distribution vary across departments and job titles?

select gender,department,count(*) as count
from hr
where age >= 18 and termdate = 0000-00-00
group by gender,department;

-- 7. What is the distribution of job titles across the company?

select jobtitle,count(*) as count
from hr
where age >= 18 and termdate = 0000-00-00
group by jobtitle
order by count desc;

-- 9. What is the distribution of employees across locations by city and state?

select location_city,location_state,count(*) as emp_count
from hr
where age >= 18 and termdate = 0000-00-00
group by location_city,location_state
order by location_state;

-- 11. What is the tenure distribution for each department?
SELECT department, ROUND(AVG(DATEDIFF(CURDATE(), termdate)/365),0) as avg_tenure
FROM hr
WHERE termdate <= CURDATE() AND termdate <> 0000-00-00 AND age >= 18
GROUP BY department;

-- 10. How has the company's employee count changed over time based on hire and term dates?

SELECT 
    YEAR(hire_date) AS year, 
    COUNT(*) AS hires, 
    SUM(CASE WHEN termdate <> 0000-00-00 AND termdate <= CURDATE() THEN 1 ELSE 0 END) AS terminations, 
    COUNT(*) - SUM(CASE WHEN termdate <> 0000-00-00 AND termdate <= CURDATE() THEN 1 ELSE 0 END) AS net_change,
    ROUND(((COUNT(*) - SUM(CASE WHEN termdate <> 0000-00-00 AND termdate <= CURDATE() THEN 1 ELSE 0 END)) / COUNT(*) * 100),2) AS net_change_percent
FROM 
    hr
WHERE age >= 18
GROUP BY 
    YEAR(hire_date)
ORDER BY 
    YEAR(hire_date) ASC;
$$$sql
