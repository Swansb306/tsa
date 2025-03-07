CREATE TABLE tsa (
    Date TEXT,  
    Numbers INTEGER); 
--after making tables and importing data from your csv
--I just used the import/export data command that you see when you right click the table for this one.

--ALTER TABLE tsa
--ALTER COLUMN date DATE;
--SELECT * FROM tsa;
--lets try to make additional column so we can do 
--avg per month

--convert text to date
ALTER TABLE tsa 
ALTER COLUMN date 
TYPE DATE USING date::DATE;

ALTER TABLE tsa
ADD COLUMN month integer,
ADD COLUMN year integer;

ALTER TABLE tsa
ADD COLUMN day integer;

UPDATE tsa
SET month = EXTRACT(MONTH FROM date),
    year = EXTRACT(YEAR FROM date);

UPDATE tsa
SET day = EXTRACT(DAY FROM date);

SELECT AVG(tsa.numbers), tsa.month, tsa.Year 
FROM tsa
GROUP BY month, year
ORDER BY month, year;

--this gives you averages for each month

SELECT ROUND(AVG(tsa.numbers),2), tsa.month, year
FROM tsa
GROUP BY year, month
ORDER BY year, month;
--right now this is giving you the average of 
--a day in that month. Not quite what you want.
--revisit


--what about sums per month, like average sums? 
SELECT ROUND(SUM(tsa.numbers),2), tsa.month, tsa.year
FROM tsa
GROUP BY year, month
ORDER BY year, month;

--this isn't quite right
--how about for between specific dates
SELECT AVG(tsa.numbers), tsa.date
FROM tsa
where month = 2 AND year != 2022 AND day >=10 
AND day <= 16
GROUP BY tsa.date;

SELECT tsa.numbers,tsa.date 
FROM tsa
where month = 2 AND year != 2022 AND day >=10 
AND day <= 16;

--this one adds a column to output with 3% increase
SELECT tsa.numbers,tsa.date, numbers *1.03 AS numbers_plus_3percent
FROM tsa
where month = 2 AND year != 2022 AND day >=10 
AND day <= 16;

--can we calculate % differences? 
SELECT 
t1.year as currentyear,
t1.day as currentday,
t1.numbers as currentyearnumbers,
t2.year as previousyear,
t2.day as previousday,
t2.numbers as previousyearnumbers,
ROUND(100 * (t1.numbers - t2.numbers)/t2.numbers,2) AS percent_change
FROM tsa t1
JOIN tsa t2
ON t1.year = t2.year +1
AND t1.day = t2.day
AND t1.month = t2.month
WHERE t1.month = 2 
    AND t1.year != 2022 
    AND t1.day BETWEEN 10 AND 16
ORDER BY t1.day, t1.year;

--for new week
SELECT AVG(tsa.numbers), tsa.date
FROM tsa
where month = 2 AND year != 2022 AND day >=17 
AND day <= 23
GROUP BY tsa.date;

SELECT AVG(tsa.numbers),tsa.year
FROM tsa
where month = 2 AND year != 2022 AND day >=17 
AND day <= 23
GROUP BY tsa.year;

--Lets try out some correlations
SELECT corr(t1.numbers,t2.numbers)
FROM tsa t1
JOIN tsa t2
ON t1.month = t2.month 
AND t1.day = t2.day
AND t1.year = t2.year - 1
WHERE t1.month = 2 
    AND t1.year != 2022 
    AND t1.day BETWEEN 10 AND 16
;
--showed a correlation of .24. So data for that week 
--is correlated with data for that week a year later
--what about correlating say first month of a year
--with total passengers in a year? or for future months?

SELECT corr(t1.yearlypass, t2.numbers)
FROM (
SELECT year, SUM(numbers) AS yearlypass
FROM tsa
GROUP BY year
)t1
JOIN (
SELECT year, SUM(numbers) AS jantotal
FROM tsa
WHERE month = 1
GROUP BY year
)t2
ON  t1.year = t2.year 
  ;

CREATE TABLE percentile_test(numbers integer
);

INSERT INTO percentile_test (numbers)
VALUES (1), (2), (3), (4), (5), (6);

SELECT percentile_cont(.5)
WITHIN GROUP (ORDER BY numbers),
percentile_disc(.5)
WITHIN GROUP (ORDER BY numbers)
FROM percentile_test;

 
SELECT AVG(tsa.numbers), tsa.date, percentile_cont(.5)
WITHIN GROUP (ORDER BY numbers) AS median
FROM tsa
where month = 2 AND year != 2022 AND day >=17 
AND day <= 23
GROUP BY tsa.date;
