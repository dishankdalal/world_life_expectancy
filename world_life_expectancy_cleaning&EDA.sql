# World Life Expetancy Project (Data Cleaning)
SELECT * FROM world_life_expectancy;

# Looking for Duplicates
SELECT Row_ID, country, Year, CONCAT(country, Year), COUNT(CONCAT(country, Year)) 
FROM world_life_expectancy
GROUP BY Country, Year, CONCAT(country,Year)
HAVING COUNT(CONCAT(country, Year)) > 1;

# OR

SELECT * 
FROM(	
    SELECT Row_ID, CONCAT(country, Year),
	ROW_NUMBER() OVER(PARTITION BY CONCAT(country, Year) ORDER BY CONCAT(country, Year)) AS Row_Num
	FROM world_life_expectancy) AS Row_table
WHERE Row_Num > 1;

DELETE FROM world_life_expectancy
WHERE ROW_ID IN (SELECT Row_ID FROM( 
				SELECT Row_ID, country, Year, CONCAT(country, Year), COUNT(CONCAT(country, Year)) 
				FROM world_life_expectancy
				GROUP BY Country, Year, CONCAT(country,Year)
				HAVING COUNT(CONCAT(country, Year)) > 1
                ) AS temp );

## Filling up the Blank Values in Status Column          
SELECT * FROM world_life_expectancy;

SELECT  DISTINCT(status), country FROM world_life_expectancy
WHERE status = '';

SELECT DISTINCT(country)
FROM world_life_expectancy
WHERE status = 'Developing';

UPDATE world_life_expectancy
SET status = 'Developing'
WHERE country in (SELECT DISTINCT(country)
					FROM world_life_expectancy
					WHERE status = 'Developing' );

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2 
	ON t1.country = t2.country
SET t1.status = 'Developing'
WHERE t1.status = ''
AND t2.status <> ''
AND t2.status = 'Developing';

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2 
	ON t1.country = t2.country
SET t1.status = 'Developed'
WHERE t1.status = ''
AND t2.status <> ''
AND t2.status = 'Developed';

## Filling Up blank values in Life Expectancy column

SELECT * FROM world_life_expectancy;

SELECT *
FROM world_life_expectancy
WHERE `Life expectancy` = '';

SELECT t1.country, t1.year, t1.`Life expectancy`,  
t2.country, t2.year, t2.`Life expectancy`,
t3.country, t3.year, t3.`Life expectancy`,
ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1)
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.country = t2.country
    AND t1.year = t2.year - 1 
JOIN world_life_expectancy t3
	ON t1.country = t3.country
    AND t1.year = t3.year + 1
WHERE t1.`Life expectancy` = '';

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.country = t2.country
    AND t1.year = t2.year - 1 
JOIN world_life_expectancy t3
	ON t1.country = t3.country
    AND t1.year = t3.year + 1
SET t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1)
WHERE t1.`Life expectancy` = '';


############################################################ EDA ############################################################################
SELECT * FROM world_life_expectancy;

## Lowest and Highest Life Expectancy -- Which country has done really good over the time to increase their life expectancy?
SELECT country, Min(`Life Expectancy`), 
Max(`Life Expectancy`),
ROUND(Max(`Life Expectancy`) - Min(`Life Expectancy`),1) AS life_increase
FROM world_life_expectancy
GROUP BY country
HAVING Min(`Life Expectancy`) <> 0 AND Max(`Life Expectancy`) <> 0
ORDER BY life_increase DESC;

## Average Life Expectancy for Each Year
SELECT year, ROUND(AVG(`Life Expectancy`),2)
FROM world_life_expectancy
WHERE `Life Expectancy` != 0
GROUP BY year
ORDER BY year; -- Avg Life Expectancy has increased over the period of time
 


## If GDP has a correlation to Life Expectancy

SELECT country,  ROUND(AVG(`Life Expectancy`),1) AS Life_exp, ROUND(AVG(GDP),2) AS GDP
FROM world_life_expectancy
GROUP BY Country
HAVING Life_exp > 0 AND GDP > 0
ORDER BY GDP ASC;  ## Lower GDP is fairly correlated with Lower Life Expectancy

SELECT 
SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END )High_GDP_Count,
ROUND(AVG(CASE WHEN GDP >= 1500 THEN `Life Expectancy` ELSE NULL END ),2)High_GDP_Life_Expec,
SUM(CASE WHEN GDP <= 1500 THEN 1 ELSE 0 END )Low_GDP_Count,
ROUND(AVG(CASE WHEN GDP <= 1500 THEN `Life Expectancy` ELSE NULL END ),2)Low_GDP_Life_Expec
FROM world_life_expectancy;


-- How does Status (Developed and Developing) affecting the Avg Life Expectancy

SELECT status, ROUND(AVG(`Life Expectancy`),1)
FROM world_life_expectancy
GROUP BY status;

SELECT COUNT(DISTINCT country), status,  ROUND(AVG(`Life Expectancy`),1)
FROM world_life_expectancy
GROUP BY status;


-- Avg Life Expectancy with respect to BMI ( Low BMI = Low Life Expectancy) in Developed countries maybe 
SELECT country,  ROUND(AVG(`Life Expectancy`),1) AS life_exp,  ROUND(AVG(BMI),1) AS avg_bmi
FROM world_life_expectancy
GROUP BY Country
HAVING life_exp > 0 AND avg_bmi > 0
ORDER BY avg_bmi DESC;

-- Rolling Total of deaths by country in 15 year span
SELECT country,
year,
`Life Expectancy`,
`Adult Mortality`,
SUM(`Adult Mortality`) OVER(PARTITION BY Country ORDER BY Year) AS rolling_total
FROM world_life_expectancy
;