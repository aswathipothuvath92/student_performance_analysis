-----STEP 1: Changing datatype of student_id(primarykey)----

        -- 1. Drop the foreign key constraints temporarily so the tables are untied
        ALTER TABLE academics DROP CONSTRAINT IF EXISTS academics_student_id_fkey;
        ALTER TABLE engagement DROP CONSTRAINT IF EXISTS engagement_student_id_fkey;

        -- 2. NOW run your alter statements (they will work flawlessly now!)
        ALTER TABLE students ALTER COLUMN student_id TYPE INTEGER USING student_id::INTEGER;
        ALTER TABLE academics ALTER COLUMN student_id TYPE INTEGER USING student_id::INTEGER;
        ALTER TABLE engagement ALTER COLUMN student_id TYPE INTEGER USING student_id::INTEGER;

        -- 3. Re-create the foreign key constraints now that everyone is an INTEGER
        ALTER TABLE academics 
        ADD CONSTRAINT academics_student_id_fkey 
        FOREIGN KEY (student_id) REFERENCES students(student_id);

        ALTER TABLE engagement 
        ADD CONSTRAINT engagement_student_id_fkey 
        FOREIGN KEY (student_id) REFERENCES students(student_id);

        --Checking student_id column
        SELECT student_id FROM students;

        --checking its datatype
        SELECT table_name,
                column_name,
                data_type
        FROM information_schema.columns
        WHERE column_name='student_id';

---STEP 2: Checking null values 
        --student table--
        SELECT 
                COUNT(*),
                COUNT(CASE WHEN student_id IS NULL THEN 1 END) AS missing_stud_id,
                COUNT(CASE WHEN student_name IS NULL THEN 1 END) AS missing_stud_name,
                COUNT(CASE WHEN gender IS NULL THEN 1 END) AS missing_gender
        FROM students;

        --academics table--
        SELECT
                COUNT(*),
                COUNT(CASE WHEN attendance_rate IS NULL THEN 1 END) AS Missing_attendance_rate,
                COUNT(CASE WHEN attendance_percentage IS NULL THEN 1 END) AS Missing_attendance_percentage,
                COUNT(CASE WHEN study_hours IS NULL THEN 1 END) AS missing_study_hours,
                COUNT(CASE WHEN study_hours_per_week IS NULL THEN 1 END) AS missing_study_hours_per_week,
                COUNT(CASE WHEN previous_grade IS NULL THEN 1 END) AS missing_previous_grade,
                COUNT(CASE WHEN final_grade IS NULL THEN 1 END) AS missing_final_grade
        FROM academics;

        --engagement table--
        SELECT
                COUNT(*),
                COUNT(CASE WHEN extracurricular_activities IS NULL THEN 1 END) AS missing_extra_cur,
                COUNT(CASE WHEN parental_support IS NULL THEN 1 END) AS missing_parental_support_entry,
                COUNT(CASE WHEN online_classes_taken IS NULL THEN 1 END) AS missing_online_classes_taken
        FROM engagement;

--STEP 3: amending values to fix null values

        -- Fix Academics Numeric Gaps
        UPDATE academics
        SET study_hours = (SELECT ROUND(AVG(study_hours), 1) FROM academics)
        WHERE study_hours IS NULL;

        UPDATE academics
        SET study_hours_per_week = (SELECT ROUND(AVG(study_hours_per_week), 1) FROM academics)
        WHERE study_hours_per_week IS NULL;

        UPDATE academics
        SET previous_grade = (SELECT ROUND(AVG(previous_grade), 1) FROM academics)
        WHERE previous_grade IS NULL;

        UPDATE academics
        SET final_grade = (SELECT ROUND(AVG(final_grade), 1) FROM academics)
        WHERE final_grade IS NULL;

        -- Fix Engagement Numeric Gaps (Extracurricular activities count)
        UPDATE engagement
        SET extracurricular_activities = (SELECT ROUND(AVG(extracurricular_activities), 0) FROM engagement)
        WHERE extracurricular_activities IS NULL;

        -- Fix Student Text Gaps
        UPDATE students
        SET student_name = 'Unknown Student'
        WHERE student_name IS NULL;

        UPDATE students
        SET gender = 'Unknown'
        WHERE gender IS NULL;

        -- Fix Engagement Text Gaps
        UPDATE engagement
        SET parental_support = 'Unknown'
        WHERE parental_support IS NULL;

        -- since online_classes_taken is boolean, we can show another column 
        --default it to 'Unknown' for null values,'YES' for 'TRUE' and 'NO' for 'FALSE' depending on context
                -- 1. Add the new text column (leaves the original boolean completely alone)
                ALTER TABLE engagement 
                ADD COLUMN online_class_status VARCHAR(10);

                -- 2. Populate the new column based on the original boolean data
                UPDATE engagement
                SET online_class_status = CASE 
                                                WHEN online_classes_taken = TRUE THEN 'Yes'
                                                WHEN online_classes_taken = FALSE THEN 'No'
                                                ELSE 'Unknown'
                                                END;


        -- Finding Mismatch in attendance rate and percentage
                SELECT 
                        COUNT(CASE WHEN attendance_rate=attendance_percentage THEN 1 END) AS Same_attendance_columns,
                        COUNT(CASE WHEN attendance_rate!=attendance_percentage THEN 1 END)AS  Mismatche_in_attendance_columns
                FROM academics;

        ---This result proves-->attendance_rate and attendance_percentage are not duplicate columns tracking the same thing. They are completely different metrics, 
        --or one of them was severely corrupted during data entry.

        --Since we don't know the exact story behind the 828 mismatches, we should preserve both columns for now,
        --but let's patch the holes.We can calculate the average attendance of the whole school and use that exact average to fill in the missing blanks for those specific students. 
        --This keeps our overall school statistics balanced.

        -- Filling missing data with average values

                --  Patch the 34 missing rows in attendance_rate with the column's average
                UPDATE academics
                SET attendance_rate = (SELECT ROUND(AVG(attendance_rate), 1) FROM academics)
                WHERE attendance_rate IS NULL;

                -- Patch the 18 missing rows in attendance_percentage with its column's average
                UPDATE academics
                SET attendance_percentage = (SELECT ROUND(AVG(attendance_percentage), 1) FROM academics)
                WHERE attendance_percentage IS NULL;

        SELECT attendance_rate,
                attendance_percentage
        FROM academics;

        --checked number of null values again using above queries and made sure that there are no null values anymore.
        --checking populated online_class_status values
        SELECT COUNT(CASE WHEN online_class_status IS NULL THEN 1 END) AS missing_online_classes_taken
                FROM engagement;

--STEP 4: Standardizing Text

        -- Audit 1: Check Gender categories
        SELECT DISTINCT gender FROM students;

        -- Audit 2: Check Parental Support categories
        SELECT DISTINCT parental_support FROM engagement;

        -- Audit 3: Check our newly created status column just to be safe
        SELECT DISTINCT online_class_status FROM engagement;
---data already looks stabdardized!

--STEP 5: Finding duplicates

        --1--checking identical rows in student table
        SELECT student_name,gender,COUNT(*)
        FROM students
        GROUP BY student_name,gender
        HAVING COUNT(*)>1;
        --returned 5 rows, 2 rows being 'unknown'students repeating and 3 rows with student names:'Anthony Smith', 'Andrea Frey', 'Erica Miller'
        
        --driiling into data to see if those are actual duplicates
        SELECT S.student_name,S.gender,A.attendance_rate,A.attendance_percentage,A.study_hours,A.study_hours_per_week,A.previous_grade,A.final_grade,E.parental_support,E.extracurricular_activities,E.online_class_status
        FROM students S
        LEFT JOIN academics A ON S.student_id=A.student_id
        LEFT JOIN engagement E ON S.student_id=E.student_id
        WHERE S.student_name IN('Anthony Smith', 'Andrea Frey', 'Erica Miller')
        --verified those are not duplicate rows

        --2--checking identical rows in academics table
        SELECT attendance_rate,attendance_percentage,study_hours,study_hours_per_week,previous_grade,final_grade,COUNT(*)
        FROM academics
        GROUP BY attendance_rate,attendance_percentage,study_hours,study_hours_per_week,previous_grade,final_grade
        HAVING COUNT(*) > 1;

        --3--checking identical rows in engagement table
        SELECT count(*)
        FROM (SELECT extracurricular_activities, parental_support, online_classes_taken, online_class_status, COUNT(*)
        FROM engagement
        GROUP BY extracurricular_activities, parental_support, online_classes_taken, online_class_status
        HAVING COUNT(*) > 1)
        --this table has many duplicates but it is expected as many values falls into same bucket naturally


                        