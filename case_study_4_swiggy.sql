SELECT * FROM 5_sql_casestudy.swiggy;

select sum(case when time_minutes='' then 1 else 0 end) As total_null from swiggy;

select * from swiggy where time_minutes='';

update swiggy
set  time_minutes = replace(time_minutes,' mins','');

update swiggy
set rating = ''
where rating like '%min%';

select column_name from information_schema.columns where table_name = 'swiggy';

DELIMITER //

CREATE PROCEDURE null_count(IN t_name VARCHAR(64))
BEGIN
    DECLARE sql_query TEXT;
    
    -- Build the SQL query to count NULL values in each column
    SELECT GROUP_CONCAT(
        CONCAT('SUM(CASE WHEN `', column_name, '` = "" THEN 1 ELSE 0 END) AS `', column_name, '`')
    ) INTO sql_query
    FROM information_schema.columns
    WHERE table_schema = DATABASE() AND table_name = t_name;

    -- Concatenate the final SELECT statement
    SET @sql_query = CONCAT('SELECT ', sql_query, ' FROM ', t_name);

    -- Prepare, execute, and deallocate the prepared statement
    PREPARE stmt FROM @sql_query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //

DELIMITER ;

call null_count('swiggy');

select * from swiggy where time_minutes like '%-%';
                    
update swiggy
set time_minutes = (first_name(time_minutes)+second_name(time_minutes))/2
where time_minutes like '%-%';

alter table swiggy modify column time_minutes decimal(3,1);

update swiggy AS t
JOIN (
    SELECT location, round(AVG(rating),1) AS avg_rating
    FROM swiggy
    WHERE rating !=''
    GROUP BY location
) AS avg_table ON t.location = avg_table.location
set t.rating= avg_table.avg_rating
where t.rating = '';

set @average = (select round(avg(rating),1) from swiggy where rating != '');
select @average;

update  swiggy
set rating = @average 
where rating = '';

alter table swiggy modify column rating decimal(2,1) ;

update swiggy
set location = 'Kandivali East'
where location like '%Kandivali%E%';

select distinct food from(
select *,substring_index(substring_index(food_type,',',numbers.n),',',-1) as food from swiggy
join
(
	select 1+a.N + b.N*10 as n from 
		(
			(
			SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 
			UNION ALL SELECT 8 UNION ALL SELECT 9) a
			cross join 
			(
			SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 
			UNION ALL SELECT 8 UNION ALL SELECT 9)b
		)
) as numbers
on char_length(food_type) - char_length(replace(food_type,',','')) >= numbers.n-1  ) t ;