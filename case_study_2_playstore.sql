SELECT * FROM 5_sql_casestudy.playstore;

USE 5_sql_casestudy;

TRUNCATE TABLE playstore;

LOAD DATA INFILE "D:/EndSem/playstore.csv"
INTO TABLE playstore
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

/*
You're working as a market analyst for a mobile app development company. 
Your task is to identify the most promising categories (TOP 5) for launching new free apps based on their average ratings.
*/
SELECT Category,ROUND(AVG(Rating),2) AS avg_rating FROM playstore
WHERE Type = 'Free'
GROUP BY Category
ORDER BY avg_rating DESC LIMIT 5;

/*
As a business strategist for a mobile app company, your objective is to pinpoint the three categories that generate the most revenue from paid apps. 
This calculation is based on the product of the app price and its number of installations.
*/
SELECT Category,AVG(Installs * Price) AS revenue FROM playstore
WHERE Type = 'Paid'
GROUP BY Category
ORDER BY revenue DESC LIMIT 3;

/*
As a data analyst for a gaming company, you're tasked with calculating the percentage of games within each category. 
This information will help the company understand the distribution of gaming apps across different categories.
*/
SET @total = (SELECT COUNT(*) FROM playstore);
SELECT Category,ROUND(COUNT(*)/(SELECT @total)*100,2) FROM playstore
GROUP BY Category;

/*
As a data analyst at a mobile app-focused market research firm you’ll recommend whether the company should 
develop paid or free apps for each category based on the ratings of that category.
*/
SELECT t2.Category,t2.Type,t2.rating FROM
(SELECT *,MAX(t1.rating) OVER(PARTITION BY Category) AS checki FROM
(SELECT Category,Type,ROUND(AVG(Rating),1) AS rating FROM playstore
GROUP BY Category,Type) t1) t2
WHERE t2.rating = t2.checki;

/*
Suppose you're a database administrator your databases have been hacked and hackers are changing price of certain apps on the database, 
it is taking long for IT team to neutralize the hack, however you as a responsible manager don’t want your data to be changed, 
do some measure where the changes in price can be recorded as you can’t stop hackers from making changes.
*/
CREATE TABLE change_log(
	column_naam VARCHAR(255),
    old_value VARCHAR(255),
    new_value VARCHAR(255),
    operation_type VARCHAR(255),
    operataion_date timestamp
);

DELIMITER //
CREATE TRIGGER ab_kr_hack
AFTER UPDATE
ON playstore
FOR EACH ROW
BEGIN
	INSERT INTO chnange_log(column_naam, old_value, new_value, operation_type, operation_date)
    VALUES(NEW.App,OLD.Price,NEW.PRICE,'UPDATE',CURRENT_TIMESTAMP());
END;
// DELIMITER  ;

/*
Your IT team have neutralized the threat; however, hackers have made some changes in the prices, 
but because of your measure you have noted the changes, 
now you want correct data to be inserted into the database again.
*/
-- update + join

-- DROP TRIGGER ab_kr_hack;

-- UPDATE playstore as p
-- INNER JOIN change_log as c ON 
-- SET column_naam = old_value;

/*
As a data person you are assigned the task of investigating the correlation between two numeric factors: 
app ratings and the quantity of reviews.
*/
SET @x = (SELECT AVG(Rating) FROM playstore);
SET @y = (SELECT AVG(Reviews) FROM playstore);
SELECT ROUND(SUM((Rating-(SELECT @x))*(Reviews-(SELECT @y)))/
	SQRT(SUM((Rating-(SELECT @x))*(Rating-(SELECT @x)))*SUM((Reviews-(SELECT @y))*(Reviews-(SELECT @y)))),4) AS corr
    FROM playstore;
-- ratings ke sth reviews v badh rahe hai but bahut chote margin se 

/*
Your boss noticed  that some rows in genres columns have multiple genres in them, 
which was creating issue when developing the recommender system from the data he/she assigned you the task to clean the genres column and 
make two genres out of it, 
rows that have only one genre will have other column as blank.
*/   
ALTER TABLE playstore 
ADD COLUMN Genre_1 VARCHAR(255) AFTER Genres,
ADD COLUMN Genre_2 VARCHAR(255) AFTER Genre_1;

DELIMITER //
CREATE FUNCTION first_name(a VARCHAR(255))
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
	SET @l = LOCATE(';',a);
    SET @s = IF((SELECT @l)>0, LEFT(a,(SELECT @l)-1), a);
    RETURN (SELECT @s);
END
// DELIMITER   ; 

UPDATE playstore
SET Genre_1 = first_name(Genres);

DELIMITER //
CREATE FUNCTION second_name(b VARCHAR(255))
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
	SET @lr = LOCATE(';',b);
    SET @sr = IF((SELECT @lr)>0, RIGHT(b,LENGTH(b)-(SELECT @lr)), '');
    RETURN (SELECT @sr);
END
// DELIMITER  ;

UPDATE playstore
SET Genre_2 = second_name(Genres);

ALTER TABLE playstore DROP COLUMN Genres;