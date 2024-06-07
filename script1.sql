USE week16;

SELECT * FROM laptopdata;

CREATE TABLE laptop_backup LIKE laptopdata;

INSERT INTO laptop_backup
SELECT * FROM laptopdata;