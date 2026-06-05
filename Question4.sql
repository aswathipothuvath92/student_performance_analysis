-- =================================================================================
-- QUESTION 3: COHORT ANALYSIS & BEHAVIORAL PROFILING
-- Business Question: What are the resilient group of kids doing right to win?
-- =================================================================================

-- STEP 1: Define the Macro-Resilient Cohort (The Outer "City")
-- We are isolating students who started at a disadvantage but forced a recovery.
WITH Resilient_students AS (
    SELECT 
        A.student_id,
        A.previous_grade,
        A.final_grade,
        (A.final_grade - A.previous_grade) AS points_improved,
        A.attendance_rate,
        E.online_class_status,
        E.parental_support,
        A.study_hours_per_week,
        E.extracurricular_activities
    FROM academics A
    JOIN engagement E ON A.student_id = E.student_id
    WHERE A.previous_grade < 70               -- Condition 1: Initially failing baseline
      AND A.attendance_rate < 80              -- Condition 2: High chronic absenteeism 
      AND A.final_grade > A.previous_grade    -- Condition 3: Achieved positive grade growth
),

-- STEP 2: Navigate Deep Inside to Isolate the "Hyper-Resilient Seven" (The Inner "City")
-- Slicing out the 7 students facing the absolute highest institutional barriers.
Hyper_resilient_students AS (
    SELECT 
        MIN(study_hours_per_week) AS min_weekly_hours,
        MAX(study_hours_per_week) AS max_weekly_hours,
        ROUND(AVG(study_hours_per_week), 2) AS avg_weekly_study_hours,
        ROUND(AVG(attendance_rate), 2) AS avg_attendance_percentage,
        ROUND(AVG(extracurricular_activities), 2) AS avg_no_of_extracurricular_activities
    FROM Resilient_students
    WHERE online_class_status = 'No'          -- Barrier 1: No digital/asynchronous safety net
      AND parental_support = 'Low'            -- Barrier 2: Low domestic support structures
)

-- STEP 3: THE EXECUTIVE REPORTING VIEW
-- This final SELECT acts as our dual-layer reporting dashboard.
SELECT 
    -- Macro Insights (The 47 Resilient Kids)
    COUNT(*) AS total_resilient_count,
    COUNT(CASE WHEN online_class_status = 'Yes' THEN 1 END) AS count_of_students_with_online_class,
    COUNT(CASE WHEN online_class_status = 'No' THEN 1 END) AS count_of_students_without_online_class,
    COUNT(CASE WHEN parental_support = 'High' THEN 1 END) AS count_of_students_with_High_parental_support,
    COUNT(CASE WHEN parental_support = 'Medium' THEN 1 END) AS count_of_students_with_Medium_parental_support,
    COUNT(CASE WHEN parental_support = 'Low' THEN 1 END) AS count_of_students_with_Low_parental_support,
    
    -- Micro Insights (The Hyper-Resilient 7 Profile)
    (SELECT avg_weekly_study_hours FROM Hyper_resilient_students) AS hyper_7_avg_study_hours,
    (SELECT max_weekly_hours FROM Hyper_resilient_students) AS hyper_7_max_study_hours,
    (SELECT avg_no_of_extracurricular_activities FROM Hyper_resilient_students) AS hyper_7_avg_activities
FROM Resilient_students;

-- =================================================================================
-- 💡 ANALYST DATA FINDINGS & BUSINESS INTERPRETATION:
-- 
-- 1. THE MACRO COHORT (47 Students): 
--    - Balanced Support: Parental support split evenly (16 High, 14 Med, 16 Low), 
--      proving family intervention wasn't the main driver of their comeback.
--    - Digital Substitution: 25 out of 47 leveraged online classes, suggesting 
--      asynchronous options acted as a vital backup for low physical attendance.
-- 
-- 2. THE HYPER-RESILIENT SEVEN (7 Students):
--    - What are they doing right? Pure sweat equity. Deprived of both online classes 
--      and parental support, they substituted classroom instruction with massive 
--      independent study, averaging 16.71 hours/week (scaling up to 25 hours).
--    - Tactical Scheduling: They maintain an average of 1.29 extracurriculars. 
--      They aren't disengaged; they are time-poor but hyper-efficient managers 
--      of their personal schedules.
-- =================================================================================