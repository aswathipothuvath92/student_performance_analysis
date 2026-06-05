-- ====================================================================================================
-- QUESTION 3: THE ATTENDANCE-PERFORMANCE PARADOX & ADVANCED COHORT ANALYSIS
-- 
-- Business Investigation: 
-- 1. AUDIT: Are our data metrics clean, and what are the operational boundaries?
-- 2. MACRO TRENDS: How do attendance brackets correlate with grade mastery vs. directional growth?
-- 3. MICRO DEEP-DIVE: For students defying the odds, what specific habits enable their success?
-- ====================================================================================================

-- ----------------------------------------------------------------------------------------------------
-- PART 1: DATA VALIDATION & BOUNDARY EXPLORATION
-- Purpose: Audit the operational ranges and scales of key columns before bucket design.
-- Finding: 'attendance_percentage' contained corrupt scaling (Max: 200.0). 
--          'attendance_rate' proved clean (Range: 70.0 - 95.0) and was selected for tracking.
-- ----------------------------------------------------------------------------------------------------

SELECT 
    MIN(attendance_rate) AS min_att_rate,
    MAX(attendance_rate) AS max_att_rate,
    MIN(attendance_percentage) AS min_att_perc,
    MAX(attendance_percentage) AS max_att_perc,
    MIN(previous_grade) AS min_prev_grade,
    MAX(previous_grade) AS max_prev_grade,
    MIN(final_grade) AS min_final_grade,
    MAX(final_grade) AS max_final_grade
FROM academics;


-- ----------------------------------------------------------------------------------------------------
-- PART 2: MACRO ATTENDANCE BRACKET BREAKDOWN
-- Purpose: Aggregate performance metrics into logical behavioral attendance categories.
-- Insights: Reveals a "Ceiling Effect" where low attendance correlates with high directional 
--           improvement percentage (61.26%) but a lower absolute mastery floor (79.97).
-- ----------------------------------------------------------------------------------------------------

SELECT 
    CASE 
        WHEN attendance_rate < 80 THEN '1. Low Attendance (<80%)'
        WHEN attendance_rate < 90 THEN '2. Moderate Attendance (80-89%)'
        ELSE '3. High Attendance (90-95%)'
    END AS attendance_category,
    COUNT(*) AS student_count,
    ROUND(100.0 * COUNT(CASE WHEN final_grade > previous_grade THEN 1 END) / COUNT(*), 2) AS percentage_of_improved_students,
    ROUND(AVG(final_grade), 2) AS avg_final_grade,
    ROUND(AVG(previous_grade), 2) AS avg_previous_grade,
    ROUND(AVG(final_grade) - AVG(previous_grade), 2) AS avg_grade_point_improvement
FROM academics
GROUP BY attendance_category
ORDER BY attendance_category;


-- ----------------------------------------------------------------------------------------------------
-- PART 3: MICRO-TARGETED COHORT ANALYSIS & BEHAVIORAL PROFILING
-- Purpose: Pull on the thread discovered in Part 2. If low-attendance students are improving at 
--          high rates, what specific habits and environmental factors are enabling their success?
--          Isolates the 47 Resilient Students and profiles the "Hyper-Resilient Seven".
-- ----------------------------------------------------------------------------------------------------

WITH Resilient_students AS (
    SELECT 
        A.student_id,
        A.attendance_rate,
        E.online_class_status,
        E.parental_support,
        A.study_hours_per_week,
        E.extracurricular_activities
    FROM academics A
    JOIN engagement E ON A.student_id = E.student_id
    WHERE A.previous_grade < 70               -- Condition 1: Initially failing baseline floor
      AND A.attendance_rate < 80              -- Condition 2: Chronic absenteeism
      AND A.final_grade > A.previous_grade    -- Condition 3: Achieved positive grade growth
),

Hyper_resilient_students AS (
    SELECT 
        MIN(study_hours_per_week) AS min_hours,
        MAX(study_hours_per_week) AS max_hours,
        ROUND(AVG(study_hours_per_week), 2) AS avg_hours,GIT 
        ROUND(AVG(attendance_rate), 2) AS avg_att,
        ROUND(AVG(extracurricular_activities), 2) AS avg_activities
    FROM Resilient_students
    WHERE online_class_status = 'No'          -- Barrier 1: No digital/asynchronous backup
      AND parental_support = 'Low'            -- Barrier 2: Low domestic support network
)

SELECT 
    -- Macro Distribution Insights (The 47 Resilient Kids)
    COUNT(*) AS total_resilient_count,
    COUNT(CASE WHEN online_class_status = 'Yes' THEN 1 END) AS count_with_online_class,
    COUNT(CASE WHEN online_class_status = 'No' THEN 1 END) AS count_without_online_class,
    COUNT(CASE WHEN parental_support = 'High' THEN 1 END) AS count_with_high_parental_support,
    COUNT(CASE WHEN parental_support = 'Medium' THEN 1 END) AS count_with_med_parental_support,
    COUNT(CASE WHEN parental_support = 'Low' THEN 1 END) AS count_with_low_parental_support,
    
    -- Deep-Dive Behavioral Metrics (The Hyper-Resilient 7 Formula)
    (SELECT avg_hours FROM Hyper_resilient_students) AS hyper_7_avg_study_hours,
    (SELECT max_hours FROM Hyper_resilient_students) AS hyper_7_max_study_hours,
    (SELECT avg_activities FROM Hyper_resilient_students) AS hyper_7_avg_activities
FROM Resilient_students;

-- ====================================================================================================
-- 💡 FINAL INVESTIGATIVE CONCLUSION:
-- 
-- 1. DATA AUDIT: Validating boundaries caught an anomaly in 'attendance_percentage' (scaling up to 200.0),
--    saving our downstream visualizations from broken parameters before any data buckets were built.
-- 2. THE DIGITAL SUBSTITUTE: 25 out of 47 resilient students used online classes to offset low physical 
--    attendance. Remote learning models provide a critical safety net for non-traditional schedules.
-- 3. THE HYPER-RESILIENT STRATEGY: Strip away parental support and online classes, and the remaining 7 
--    students survive on pure operational discipline. They substitute physical seat-time with a massive 
--    16.71-hour weekly independent study grind, while strictly budgeting extracurriculars to 1.29 to 
--    prevent complete time poverty and burnout.
-- ====================================================================================================