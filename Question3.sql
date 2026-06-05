/*
===============================================================================
QUESTION 3
Investigating the Relationship Between Attendance Thresholds and Grades

===============================================================================

DESCRIPTION:
  This script explores how student attendance rates correlate with both 
  academic improvement (directional growth) and overall final grade mastery 
  (absolute performance). It addresses a potential "ceiling effect" paradox 
  where low-attendance students show higher improvement rates due to a lower 
  starting baseline floor.

SCHEMA REFERENCED:
  - academics (student_id, attendance_rate, previous_grade, final_grade)

TABLE OF CONTENTS:
  1. Data Validation & Boundary Exploration
  2. Macro Attendance Bracket Breakdown (Main Analysis)
  3. Micro-Targeted Cohort Analysis via CTE (Rescue vs. Vulnerable Groups)
===============================================================================
*/

-- ===============================================================================
-- 1. DATA VALIDATION & BOUNDARY EXPLORATION
-- ===============================================================================
-- Purpose: To audit the ranges of the attendance columns before bucket design.
-- Finding: 'attendance_percentage' contained corrupt scaling (Max: 200.0). 
--          'attendance_rate' proved clean (Range: 70.0 - 95.0) and was selected.

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


-- ===============================================================================
-- 2. MACRO ATTENDANCE BRACKET BREAKDOWN
-- ===============================================================================
-- Purpose: Aggregates metrics into three logical behavioral categories:
--          Low (<80%), Moderate (80-89%), and High (90-95%) attendance.
-- Insights: Reveals the "Ceiling Effect"—Low attendance correlates with high 
--           improvement percentage (61.26%) but lower absolute mastery (79.97).

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


-- ===============================================================================
-- 3. MICRO-TARGETED COHORT ANALYSIS (CTE FORMAT)
-- ===============================================================================
-- Purpose: Isolates specific cross-sections of the student population to prove 
--          the behavioral safety net of current attendance state.
-- Cohorts:
--   - Rescue Group (144 Students): Low baseline floor (<70) who improved with 
--     stable attendance (>=80%).
--   - Vulnerable Group (51 Students): High baseline floor (>80) who dropped with 
--     low attendance (<80%).

WITH student_behavior_segments AS (
    SELECT 
        student_id,
        previous_grade,
        final_grade,
        attendance_rate,
        -- Staging directional growth indicators for downstream clean aggregation
        CASE WHEN final_grade > previous_grade THEN 1 ELSE 0 END AS did_improve,
        CASE WHEN final_grade < previous_grade THEN 1 ELSE 0 END AS did_drop
    FROM academics
)
SELECT 
    -- Cohort 1: The Low-Baseline Rescue Count
    COUNT(CASE WHEN previous_grade < 70 AND attendance_rate >= 80 AND did_improve = 1 THEN 1 END) 
        AS count_of_students_grade_improved_with_good_attendance,
        
    -- Cohort 2: The High-Baseline Vulnerable Count
    COUNT(CASE WHEN previous_grade > 80 AND attendance_rate < 80 AND did_drop = 1 THEN 1 END) 
        AS count_of_students_grade_dropped_with_low_attendance
FROM student_behavior_segments;


