--To view first 10 rows of tables

SELECT*FROM students
LIMIT 10;

SELECT*FROM academics
LIMIT 10;

SELECT*FROM engagement
LIMIT 10;

--To find number of rows in each table
SELECT COUNT(*)
FROM students;

SELECT COUNT(*)
FROM academics;

SELECT COUNT(*)
FROM engagement;
-- verified all of them have same number of rows
