CREATE TABLE students (
                        student_id NUMERIC PRIMARY KEY,         
                        student_name VARCHAR(100),
                        gender VARCHAR(10)
                      );

CREATE TABLE academics (
                        student_id NUMERIC PRIMARY KEY REFERENCES students(student_id),
                        attendance_rate NUMERIC,
                        attendance_percentage NUMERIC,
                        study_hours_per_week NUMERIC,
                        study_hours NUMERIC,
                        previous_grade NUMERIC,
                        final_grade NUMERIC
                    );

CREATE TABLE engagement (
                            student_id NUMERIC PRIMARY KEY REFERENCES students(student_id),
                            extracurricular_activities NUMERIC,     -- Kept as NUMERIC for activity counts!
                            parental_support VARCHAR(20),
                            online_classes_taken BOOLEAN
                        );


-- STEP 4: Move the data from staging into  permanent tables

TRUNCATE TABLE students, academics, engagement CASCADE;--Wipe out any partially loaded data

--Creating table1
INSERT INTO students (student_id, student_name, gender)
SELECT DISTINCT student_id, student_name, gender 
FROM student_performance_staging
WHERE student_id IS NOT NULL     -- because it Throws error when student_id is null
ON CONFLICT (student_id) DO NOTHING;  -- Ignores the row if the ID already exists(Safety net for duplicates)!

--Creating table2
INSERT INTO academics (student_id, attendance_rate, attendance_percentage, study_hours_per_week, study_hours, previous_grade, final_grade)
SELECT student_id, attendance_rate, Attendance_percentage, study_hours_per_week, study_hours, previous_grade, final_grade 
FROM student_performance_staging
WHERE student_id IS NOT NULL
ON CONFLICT (student_id) DO NOTHING;

--Creating table3
INSERT INTO engagement (student_id, extracurricular_activities, parental_support, online_classes_taken)
SELECT student_id, extracurricular_activities, parental_support, Online_Classes_Taken 
FROM student_performance_staging
WHERE student_id IS NOT NULL
ON CONFLICT (student_id) DO NOTHING;


-- STEP 5: Delete the staging table to keep  database tidy
DROP TABLE student_performance_staging;

