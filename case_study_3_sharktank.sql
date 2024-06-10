SELECT * FROM 5_sql_casestudy.sharktank;

load data infile "D:/EndSem/sharktank.csv"
into table sharktank
fields terminated by ','
optionally enclosed by  '"'
lines terminated by '\r\n'
ignore 1 rows;

/*
You Team must promote shark Tank India season 4, The senior come up with the idea to show highest funding domain 
wise so that new startups can be attracted, and you were assigned the task to show the same.
*/
SELECT Industry,MAX(Total_Deal_Amount_in_lakhs) AS Total_funding FROM sharktank
GROUP BY Industry
ORDER BY Total_funding DESC;

/*
You have been assigned the role of finding the domain where female as pitchers have female to male pitcher ratio >70%
*/
SELECT *,ROUND((t1.Female_pitcher/(t1.Female_pitcher+t1.Male_pitcher))*100,2) AS F_to_M_ratio FROM
(SELECT Industry,SUM(Male_Presenters) AS Male_pitcher,SUM(Female_Presenters) AS Female_pitcher
FROM sharktank GROUP BY Industry) t1;

/*
You are working at marketing firm of Shark Tank India, you have got the task to determine volume of per season sale pitch made, 
pitches who received offer and pitches that were converted. 
Also show the percentage of pitches converted and percentage of pitches entertained.
*/
SELECT *,
CASE WHEN t2.Accepted_Offer = 'Yes' THEN ROUND(t2.Total/t3.Total_Offer*100,2) ELSE 0 END AS percentage_of_pitches_converted,
CASE WHEN t2.Accepted_Offer = 'No' THEN ROUND((1-(t3.Total_Offer-t2.Total)/t4.Total_R_Offer)*100,2) ELSE 0 END AS percentage_of_pitches_entertained FROM
(SELECT Season_Number,Accepted_Offer,COUNT(*) AS Total FROM sharktank
WHERE Received_Offer = 'Yes' 
GROUP BY Season_Number,Accepted_Offer) t2
NATURAL JOIN
(SELECT Season_Number,COUNT(Accepted_Offer) AS Total_Offer FROM sharktank
WHERE Received_Offer = 'Yes' 
GROUP BY Season_Number) t3
NATURAL JOIN
(SELECT Season_Number,COUNT(*) AS Total_R_Offer FROM sharktank
GROUP BY Season_Number) t4;

/*
As a venture capital firm specializing in investing in startups featured on a renowned entrepreneurship TV show, you are determining the 
season with the highest average monthly sales and 
identify the top 5 industries with the highest average monthly sales during that season to optimize investment decisions?
*/
SELECT Industry,ROUND(AVG(Monthly_Sales_in_lakhs),1) AS Avg FROM sharktank
WHERE Season_Number = (SELECT Season_Number FROM sharktank
GROUP BY Season_Number
ORDER BY ROUND(AVG(Monthly_Sales_in_lakhs),1) DESC LIMIT 1)
GROUP BY Industry
ORDER BY Avg DESC LIMIT 5;

/*
As a data scientist at our firm, your role involves solving real-world challenges like identifying industries with consistent increases in 
funds raised over multiple seasons. This requires focusing on industries where data is available across all three seasons. 
Once these industries are pinpointed, your task is to delve into the specifics, 
analyzing the number of pitches made, offers received, and offers converted per season within each industry.
*/
SELECT Season_Number,Industry,COUNT(*) AS No_Pitches,
SUM(CASE WHEN Received_Offer = 'Yes' THEN 1 ELSE 0 END) AS Offers_Received,
SUM(CASE WHEN Accepted_Offer = 'Yes' THEN 1 ELSE 0 END) AS Offers_Converted FROM sharktank
WHERE Industry IN (SELECT Industry FROM
((SELECT Industry,SUM(Total_Deal_Amount_in_lakhs) AS Season_1_total_fund FROM sharktank
WHERE Season_Number = 1 GROUP BY Industry) t4
NATURAL JOIN
(SELECT Industry,SUM(Total_Deal_Amount_in_lakhs) AS Season_2_total_fund FROM sharktank
WHERE Season_Number = 2 GROUP BY Industry) t5
NATURAL JOIN
(SELECT Industry,SUM(Total_Deal_Amount_in_lakhs) AS Season_3_total_fund FROM sharktank
WHERE Season_Number = 3 GROUP BY Industry) t6)
WHERE t4.Season_1_total_fund < t5.Season_2_total_fund AND t5.Season_2_total_fund < t6.Season_3_total_fund)
GROUP BY Season_Number,Industry;

/*
Every shark wants to know in how much year their investment will be returned, so you must create a system for them, 
where shark will enter the name of the startup’s and the based on the total deal and 
equity given in how many years their principal amount will be returned and make their investment decisions.
*/
delimiter //
create procedure TOT( in startup varchar(100))
begin
   case 
      when (select Accepted_offer ='No' from sharktank where startup_name = startup)
	        then  select 'Turn Over time cannot be calculated';
	 when (select Accepted_offer ='yes' and Yearly_Revenue_in_lakhs = 'Not Mentioned' from sharktank where startup_name= startup)
           then select 'Previous data is not available';
	 else
         select `startup_name`,`Yearly_Revenue_in_lakhs`,`Total_Deal_Amount_in_lakhs`,`Total_Deal_Equity_%`, 
         `Total_Deal_Amount_in_lakhs`/((`Total_Deal_Equity_%`/100)*`Total_Deal_Amount_in_lakhs`) as 'years'
		 from sharktank where Startup_Name= startup;
	
    end case;
end
//
DELIMITER ;

CALL TOT('HammerLifestyle');

/*
In the world of startup investing, we're curious to know which big-name investor, often referred to as "sharks," tends to put the most money into each deal on average. 
This comparison helps us see who's the most generous with their investments and how they measure up against their fellow investors.
*/
SELECT SharkName,ROUND(AVG(t.avg_deal),2) AS Avg_Deal FROM
((SELECT `Namita_Investment_Amount_in lakhs` AS avg_deal,'Namita' AS SharkName FROM sharktank WHERE `Namita_Investment_Amount_in lakhs`>0)
UNION ALL
(SELECT `Vineeta_Investment_Amount_in_lakhs`,'Vineeta' AS SharkName FROM sharktank WHERE `Vineeta_Investment_Amount_in_lakhs`>0)
UNION ALL
(SELECT `Anupam_Investment_Amount_in_lakhs`,'Anupam' AS SharkName FROM sharktank WHERE `Anupam_Investment_Amount_in_lakhs`>0)
UNION ALL
(SELECT `Aman_Investment_Amount_in_lakhs`,'Aman' AS SharkName FROM sharktank WHERE `Aman_Investment_Amount_in_lakhs`>0)
UNION ALL
(SELECT `Peyush_Investment_Amount_in_lakhs`,'Peyush' AS SharkName FROM sharktank WHERE `Peyush_Investment_Amount_in_lakhs`>0)
UNION ALL
(SELECT `Amit_Investment_Amount_in_lakhs`,'Amit' AS SharkName FROM sharktank WHERE `Amit_Investment_Amount_in_lakhs`>0)
UNION ALL
(SELECT `Ashneer_Investment_Amount_in_lakhs`,'AShneer' AS SharkName FROM sharktank WHERE `Ashneer_Investment_Amount_in_lakhs`>0)) t
GROUP BY SharkName;

/*
Develop a stored procedure that accepts inputs for the season number and the name of a shark. The procedure will then provide 
detailed insights into the total investment made by that specific shark across different industries during the specified season. 
Additionally, it will calculate the percentage of their investment in each sector relative to the total investment in that year, 
giving a comprehensive understanding of the shark's investment distribution and impact.
*/
delimiter //
create procedure GetSeason( in sharkname varchar(100),in season integer)
begin
   case 
      when sharkname = 'Namita' THEN 
      set @total = (select sum(`Namita_Investment_Amount_in lakhs`) from sharktank where Season_Number = season);
      select Industry,SUM(`Namita_Investment_Amount_in lakhs`) as sum, round(SUM(`Namita_Investment_Amount_in lakhs`)/(select @total)*100,2) as percentage FROM sharktank where Season_Number = season group by Industry;
      when sharkname = 'Vineeta' THEN select Industry,SUM(`Vineeta_Investment_Amount_in_lakhs`) FROM sharktank
											where Season_Number = season group by Industry;  
      when sharkname = 'Anupam' THEN select Industry,SUM(`Anupam_Investment_Amount_in_lakhs`) FROM sharktank
											where Season_Number = season group by Industry;
      when sharkname = 'Aman' THEN select Industry,SUM(`Aman_Investment_Amount_in_lakhs`) FROM sharktank
											where Season_Number = season group by Industry;
      when sharkname = 'Peyush' THEN select Industry,SUM(`Peyush_Investment_Amount_in_lakhs`) FROM sharktank
											where Season_Number = season group by Industry;
      when sharkname = 'Amit' THEN select Industry,SUM(`Amit_Investment_Amount_in_lakhs`) FROM sharktank
											where Season_Number = season group by Industry;
      when sharkname = 'Ashneer' THEN select Industry,SUM(`Ashneer_Investment_Amount_in_lakhs`) FROM sharktank
											where Season_Number = season group by Industry;    
      else select 'This shark is not available for i/p season';                                      
	end case;
end
//
DELIMITER ;

drop procedure GetSeasonRestructured;

CALL GetSeason('Namita',2);

alter table sharktank rename column `Namita_Investment_Amount_in lakhs` to Namita_Investment_Amount_in_lakhs;

delimiter //
create procedure GetSeasonRestructured( in sharkname varchar(100),in season integer)
begin
   case 
      when sharkname = 'Namita' THEN 
      set @col = concat(sharkname,'_Investment_Amount_in_lakhs');
      set @naam = (select @col);
		set @total = (select sum(@naam) from sharktank where Season_Number = season);
	  select Industry,SUM(@naam) as sum, round(SUM(@naam)/(@total)*100,2) as percentage FROM sharktank where Season_Number = season group by Industry;                                   
	end case;
end
//
DELIMITER ;

DELIMITER //

CREATE PROCEDURE GetSeasonRestructured(IN sharkname VARCHAR(100), IN season INT)
BEGIN
   
   IF sharkname = 'Namita' THEN 
      SET @col = CONCAT(sharkname, '_Investment_Amount_in_lakhs');
      
      SET @query = CONCAT('SELECT SUM(', @col, ') INTO @total FROM sharktank WHERE Season_Number = ?');
      PREPARE stmt FROM @query;
      SET @season = season;
      EXECUTE stmt USING @season;
      DEALLOCATE PREPARE stmt;
      
      SET @query = CONCAT('SELECT Industry, SUM(', @col, ') AS sum, ROUND(SUM(', @col, ')/@total*100, 2) AS percentage FROM sharktank WHERE Season_Number = ? GROUP BY Industry');
      PREPARE stmt FROM @query;
      EXECUTE stmt USING @season;
      DEALLOCATE PREPARE stmt;
   END IF;
END
//
DELIMITER ;

CALL GetSeasonRestructured('Namita',2);