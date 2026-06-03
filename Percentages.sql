
--percentage of students who have improved their grade with different levels of parental support
/*
===================================================================
📊 KEY FINDINGS FROM THIS ANALYSIS:
- Out of 916 total students, 521 (56.88%) improved their grades.
- High Parental Support yielded the highest improvement rate at 19.54%.
- Medium Support followed closely at 18.78%.
- Low Support had the lowest improvement rate at 17.36%.
- CONCLUSION: There is a clear, positive correlation between higher 
  parental involvement and a student's upward academic momentum.
===================================================================
*/

-- Query 1: Total Baseline Improvement

        SELECT 
            COUNT(*) AS total_students_who_improved,
            ROUND((100.0 * COUNT(*) / (SELECT COUNT(*) FROM academics)), 2) AS total_school_improvement_percent
        FROM academics
        WHERE final_grade > previous_grade;

-- Query 2: Detailed Parental Support Breakdown

        SELECT  E.parental_support,
                COUNT(*) AS Student_count,
                ROUND((100.0*COUNT(*)/(SELECT COUNT(*) FROM academics)),2)AS percentage_Of_students_who_improved --keep 100.0 in the beginning to push the resul to decimal intead of integer
        FROM academics A
        JOIN engagement E ON A.student_id=E.student_id
        WHERE A.final_grade>A.previous_grade
        GROUP BY E.parental_support
        ORDER BY Student_count DESC;

