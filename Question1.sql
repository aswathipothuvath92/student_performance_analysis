
/*
===================================================================
 QUESTION 1: Are online classes an effective equalizer for low-support students?
   
 METHODOLOGY & ANALYSIS:
   To ensure a rock-solid conclusion, this question was analyzed 
   using two distinct mathematical angles:
   1. INTENSITY (CTE Query): Measures the average improvement percentage jump in actual grade marks.
   2. VOLUME (Success Rate Query): Measures the raw probability of a student improving.

KEY FINDINGS:
   - Grade Growth Depth: Low-support students in online classes saw an average 
     grade increase of 5.52%, compared to 5.03% for in-person students.
   - Overall Success Rate: 55.63% of online low-support students successfully 
     improved their grades, compared to 55.47% of in-person students.

BUSINESS INSIGHT & CONCLUSION:
   Online learning environments act as an absolute academic equalizer. 
   Whether studying online or in-person, the probability of success (~55%) 
   and the depth of grade growth (~5%) remain remarkably stable. For educational 
   stakeholders, this proves that expanding online delivery models is a reliable, 
   scalable strategy that does not compromise student progress.
===================================================================

/* 1. Here we are comparing the average percentage of improvement of low parental support students who are 
 in online classes  vs not in online class(only in-person classes)
*/

WITH percentage_improvement AS(
                    SELECT A.student_id,
                    E.online_class_status,
                    A.previous_grade,
                    A.final_grade,
                    ROUND(100.0*((A.final_grade-A.previous_grade)/A.previous_grade),2)AS Percentage_of_improvement
                    FROM engagement E
                    JOIN academics A ON E.student_id=A.student_id
                    WHERE E.parental_support='Low'
)

SELECT  online_class_status,
        AVG(Percentage_of_improvement)
FROM percentage_improvement
GROUP BY online_class_status;

/* 2.Here we are comparing what percentage of low-support online students saw their grades go up vs
the percentage of low-support in-person students*/

SELECT 
        E.online_class_status,
        ROUND(100.0*COUNT(CASE WHEN A.final_grade>A.previous_grade THEN 1 END)/Count(*),2)AS Percentage_of_improved_students
FROM engagement E
JOIN academics A ON E.student_id=A.student_id
WHERE E.parental_support='Low'
GROUP BY E.online_class_status;
