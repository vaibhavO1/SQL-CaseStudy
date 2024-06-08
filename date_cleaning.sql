SELECT * FROM week16.laptop_backup;

-- Number of Rows/ Tuples
SELECT COUNT(*) FROM laptop_backup;

-- Size in Kb = 256 Kb
SELECT DATA_LENGTH/1024 FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'week16' AND TABLE_NAME = 'laptop_backup';

-- Renaming Column
ALTER TABLE laptop_backup RENAME COLUMN `UNNAMED: 0` TO `Index`;

-- Modify Index number
UPDATE laptop_backup
SET `Index` = `Index` + 1;

-- Check for all Null row
SELECT * FROM laptop_backup
WHERE Company IS NULL AND TypeName IS NULL AND Inches IS NULL AND ScreenResolution IS NULL AND
Cpu IS NULL AND Ram IS NULL AND Memory IS NULL AND Gpu IS NULL AND OpSys IS NULL AND
Weight IS NULL AND Price IS NULL;

-- Check for Duplicates
SELECT COUNT(*) AS 'check_duplicates' FROM laptop_backup
GROUP BY Company,TypeName,Inches,ScreenResolution,Cpu,Ram,Memory,Gpu,OpSys,Weight,Price
HAVING check_duplicates > 1;

SELECT MIN(`Index`) AS 'Index',Company,TypeName,Inches,ScreenResolution,Cpu,Ram,Memory,Gpu,OpSys,Weight,Price FROM laptop_backup
GROUP BY Company,TypeName,Inches,ScreenResolution,Cpu,Ram,Memory,Gpu,OpSys,Weight,Price;

-- Drop Duplicates Keep=first
DELETE FROM laptop_backup 
WHERE `Index` NOT IN (SELECT * FROM (SELECT MIN(`Index`) FROM laptop_backup
GROUP BY Company,TypeName,Inches,ScreenResolution,Cpu,Ram,Memory,Gpu,OpSys,Weight,Price) AS subquery);

-- Modifying Ram Column from text to integer
UPDATE laptop_backup
SET Ram = REPLACE(Ram,'GB','');

ALTER TABLE laptop_backup MODIFY COLUMN Ram INTEGER;

-- Modifying Weight Column from text to integer
UPDATE laptop_backup
SET Weight = REPLACE(Weight,'kg','');

SELECT * FROM laptop_backup
WHERE Weight IS NULL; 

ALTER TABLE laptop_backup MODIFY COLUMN Weight DECIMAL (6,3);

UPDATE laptop_backup
SET Price = ROUND(Price);

SELECT * FROM laptop_backup
WHERE `Index` = 202;

SELECT OpSys,
CASE
    WHEN OpSys LIKE '%ac%' THEN 'MacOS'
    WHEN OpSys LIKE 'Window%' THEN 'WindowsOS'
    WHEN OpSys LIKE 'Linux' THEN 'LinuxOS'
    WHEN OpSys LIKE 'No OS' THEN 'N/A'
    ELSE 'OtherOS'
END AS 'OS'
FROM laptop_backup;

-- Modifying OpSys Column
UPDATE laptop_backup
SET OpSys = CASE
    WHEN OpSys LIKE '%ac%' THEN 'MacOS'
    WHEN OpSys LIKE 'Window%' THEN 'WindowsOS'
    WHEN OpSys LIKE 'Linux' THEN 'LinuxOS'
    WHEN OpSys LIKE 'No OS' THEN 'N/A'
    ELSE 'OtherOS'
END;

-- Modify Gpu Column
ALTER TABLE laptop_backup
ADD COLUMN Gpu_brand VARCHAR(255) AFTER Gpu,
ADD COLUMN Gpu_name VARCHAR(255) AFTER Gpu_brand;

UPDATE laptop_backup
SET Gpu_brand = SUBSTRINg_INDEX(Gpu,' ',1);

UPDATE laptop_backup
SET Gpu_name = LTRIM(REPLACE(Gpu,Gpu_brand,'')); 

ALTER TABLE laptop_backup DROP COLUMN Gpu;

-- Modify Cpu Column
ALTER TABLE laptop_backup
ADD COLUMN Cpu_brand VARCHAR(255) AFTER Cpu,
ADD COLUMN Cpu_name VARCHAR(255) AFTER Cpu_brand,
ADD COLUMN Cpu_speed VARCHAR(255) AFTER Cpu_name;

UPDATE laptop_backup
SET Cpu_brand = SUBSTRINg_INDEX(Cpu,' ',1);

UPDATE laptop_backup
SET Cpu_speed = SUBSTRING_INDEX(Cpu,' ',-1);

UPDATE laptop_backup
SET Cpu_name = REPLACE(REPLACE(Cpu,Cpu_brand,''),Cpu_speed,'');

UPDATE laptop_backup
SET Cpu_speed = REPLACE(Cpu_speed,'GHz','');

ALTER TABLE laptop_backup MODIFY COLUMN Cpu_speed DECIMAL (4,2);

ALTER TABLE laptop_backup DROP COLUMN Cpu;

-- Modify ScreenResolution Column
ALTER TABLE laptop_backup
ADD COLUMN ScreenType VARCHAR(255) AFTER ScreenResolution,
ADD COLUMN Resolution VARCHAR(255) AFTER ScreenType;

UPDATE laptop_backup
SET Resolution = SUBSTRING_INDEX(ScreenResolution,' ',-1);

ALTER TABLE laptop_backup
ADD COLUMN Pixels_hor INTEGER AFTER Resolution,
ADD COLUMN Pixels_ver INTEGER AFTER Pixels_hor;

UPDATE laptop_backup
SET Pixels_hor = SUBSTRING_INDEX(Resolution,'x',1);

UPDATE laptop_backup
SET Pixels_ver = SUBSTRING_INDEX(Resolution,'x',-1);

ALTER TABLE laptop_backup DROP COLUMN Resolution;

ALTER TABLE laptop_backup
ADD COLUMN Touchscreen INTEGER AFTER Pixels_ver;

UPDATE laptop_backup
SET Touchscreen = ScreenResolution LIKE '%Touch%';

SELECT ScreenResolution, TRIM(REPLACE(REPLACE(REPLACE(ScreenResolution,CONCAT(Pixels_hor,'x',Pixels_ver),''),'Touchscreen',''),'/','')) FROM laptop_backup;

UPDATE laptop_backup
SET ScreenType = TRIM(REPLACE(REPLACE(REPLACE(ScreenResolution,CONCAT(Pixels_hor,'x',Pixels_ver),''),'Touchscreen',''),'/',''));

UPDATE laptop_backup
SET ScreenType = 'N/A'
WHERE ScreenType = '';

ALTER TABLE laptop_backup DROP COLUMN ScreenResolution;

SELECT DISTINCT ScreenType FROM laptop_backup;

-- Modify Memory Column
ALTER TABLE laptop_backup
ADD COLUMN Memory_type VARCHAR(255) AFTER Memory,
ADD COLUMN Primary_Memory INTEGER AFTER Memory_type,
ADD COLUMN Secondary_Memory INTEGER AFTER Primary_Memory;

SELECT MEMORY,
CASE
	WHEN MEMORY LIKE '%SSD%' AND MEMORY LIKE '%HDD%' THEN 'Hybrid'
    WHEN MEMORY LIKE '%Flash Storage%' AND MEMORY LIKE '%HDD%' THEN 'Hybrid'
    WHEN MEMORY LIKE '%Hybrid%' THEN 'Hybrid'
    WHEN MEMORY LIKE '%SSD%' THEN 'SSD'
    WHEN MEMORY LIKE '%HDD%' THEN 'HDD'
    WHEN MEMORY LIKE '%Flash Storage%' THEN 'Flash Storage'
    ELSE 'N/A'
END AS 'Memory_Type'
FROM laptop_backup;

UPDATE laptop_backup
SET Memory_type =  CASE
						WHEN MEMORY LIKE '%SSD%' AND MEMORY LIKE '%HDD%' THEN 'Hybrid'
						WHEN MEMORY LIKE '%Flash Storage%' AND MEMORY LIKE '%HDD%' THEN 'Hybrid'
						WHEN MEMORY LIKE '%Hybrid%' THEN 'Hybrid'
						WHEN MEMORY LIKE '%SSD%' THEN 'SSD'
						WHEN MEMORY LIKE '%HDD%' THEN 'HDD'
						WHEN MEMORY LIKE '%Flash Storage%' THEN 'Flash Storage'
						ELSE 'N/A'
					END;
                    
SELECT Memory,Memory_type,SUBSTRING_INDEX(Memory,'+',1) FROM laptop_backup
WHERE Memory_type = 'Hybrid';

UPDATE laptop_backup
SET Primary_Memory = TRIM(SUBSTRING_INDEX(Memory,'+',1))
WHERE Memory_type = 'Hybrid';

UPDATE laptop_backup
SET Secondary_Memory = TRIM(SUBSTRING_INDEX(Memory,'+',-1))
WHERE Memory_type = 'Hybrid';

UPDATE laptop_backup
SET Primary_Memory = Memory
WHERE Memory_type != 'Hybrid';

UPDATE laptop_backup
SET Secondary_Memory = 0
WHERE Memory_type != 'Hybrid';

UPDATE laptop_backup
SET Secondary_Memory = TRIM(REPLACE(REPLACE(REPLACE(Secondary_Memory,'SSD',''),'HDD',''),'Hybrid',''));

UPDATE laptop_backup
SET Secondary_Memory = '1024GB'
WHERE Secondary_Memory = '1TB' OR Secondary_Memory = '1.0TB'; 

UPDATE laptop_backup
SET Secondary_Memory = '2048GB'
WHERE Secondary_Memory = '2TB'; 

UPDATE laptop_backup
SET Primary_Memory = TRIM(REPLACE(REPLACE(REPLACE(REPLACE(Primary_Memory,'SSD',''),'HDD',''),'Hybrid',''),'Flash Storage',''));

UPDATE laptop_backup
SET Primary_Memory = '1024GB'
WHERE Primary_Memory = '1TB' OR Primary_Memory = '1.0TB' OR Primary_Memory LIKE '%512%512%'; 

UPDATE laptop_backup
SET Primary_Memory = '512GB'
WHERE Primary_Memory LIKE '%256%256%'; 

UPDATE laptop_backup
SET Primary_Memory = 0
WHERE Primary_Memory LIKE '%?%'; 

UPDATE laptop_backup
SET Primary_Memory = '2048GB'
WHERE Primary_Memory = '2TB'; 

UPDATE laptop_backup
SET Primary_Memory = TRIM(REPLACE(Primary_Memory,'GB',''));

UPDATE laptop_backup
SET Secondary_Memory = REPLACE(Secondary_Memory,'GB','');

ALTER TABLE laptop_backup MODIFY COLUMN Secondary_Memory INTEGER;

ALTER TABLE laptop_backup MODIFY COLUMN Primary_Memory INTEGER;

ALTER TABLE laptop_backup DROP COLUMN Memory;