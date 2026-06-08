-- ====================================================================================================
-- QUESTION 4: THE COMMUNITY BUFFER EFFECT & EXTRA-CURRICULAR IMPACT ANALYSIS
-- 
-- 📈 METRIC FINDINGS SUMMARY:
-- 1. THE ATTENDANCE PARADOX: Higher extracurricular engagement strongly correlates with a decline 
--    in class attendance (Inverse Proportionality). High-engagement students sacrifice  seat-time
--    to budget for their campus community activities.
-- 2. THE ISOLATION PERFORMANCE TRADE-OFF: The 'No Engagement' tier shows higher immediate net grade 
--    evolution, but lacks long-term peer accountability support structures.
-- 3. THE GOLDEN RATIO: Exactly 125 isolated students beat the cohort average grade improvement curve, 
--    maintaining an optimal baseline average of 1.58 extracurricular activities.
-- ====================================================================================================

-- ----------------------------------------------------------------------------------------------------
-- APPROACH A: MACRO-STRATEGIC COHORT BRACKETS (The Executive View)
-- Purpose: Aggregate the entire low-support population to discover systemic behavioral trends.
-- ----------------------------------------------------------------------------------------------------

SELECT 
    CASE 
        WHEN ROUND(E.extracurricular_activities) = 0 THEN '1. No Engagement (0 Activities)'
        WHEN ROUND(E.extracurricular_activities) BETWEEN 1 AND 2 THEN '2. Optimal Engagement (1-2 Activities)'
        ELSE '3. High Engagement (3+ Activities)'
    END AS engagement_tier,
    COUNT(*) AS total_students,
    ROUND(AVG(A.attendance_rate), 2) AS avg_attendance_rate,  -- Audited clean attendance metric
    ROUND(AVG(A.previous_grade), 2) AS avg_starting_grade,
    ROUND(AVG(A.final_grade), 2) AS avg_final_grade,
    ROUND(AVG(A.final_grade) - AVG(A.previous_grade), 2) AS net_grade_evolution
FROM engagement E
JOIN academics A ON E.student_id = A.student_id
WHERE E.parental_support = 'Low'
GROUP BY engagement_tier
ORDER BY engagement_tier;


-- ----------------------------------------------------------------------------------------------------
-- APPROACH B: MICRO-FORENSIC COHORT ISOLATION (The Deep-Dive View)
-- Purpose: Use window functions to identify the exact success formula of the 125 resilient students.
-- ----------------------------------------------------------------------------------------------------

WITH low_support_students AS (
    SELECT 
        E.student_id,
        E.extracurricular_activities,
        A.previous_grade,
        A.final_grade,
        -- Window function establishes the macro growth benchmark for this isolated population
        ROUND(AVG(A.final_grade - A.previous_grade) OVER(), 2) AS AVG_CHANGE_IN_SCORE,
        (A.final_grade - A.previous_grade) AS CHANGE_IN_SCORE
    FROM engagement E
    JOIN academics A ON E.student_id = A.student_id
    WHERE E.parental_support = 'Low'
)

SELECT 
    COUNT(student_id) AS total_resilient_students,            -- Result: 125 Students
    ROUND(AVG(extracurricular_activities), 2) AS avg_activities -- Result: 1.58 Average Activities
FROM low_support_students
WHERE CHANGE_IN_SCORE > AVG_CHANGE_IN_SCORE;