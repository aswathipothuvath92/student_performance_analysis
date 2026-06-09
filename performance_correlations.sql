
--student's performance Correlations--

WITH Performance_Momentum AS
                        (SELECT A.student_id,
                                A.study_hours_per_week,
                                A.attendance_percentage,
                                A.attendance_rate,
                                E.parental_support,
                                E.online_class_status,
                                E.extracurricular_activities,
                                CASE WHEN final_grade>previous_grade THEN 'Increased'
                                                WHEN final_grade=previous_grade THEN 'Same'
                                                ELSE 'Decreased'
                                END AS Performance
                                
                        FROM academics A
                        JOIN  engagement E ON A.student_id=E.student_id
                        )

SELECT 
        Performance,
        parental_support,
        online_class_status,
        COUNT(*) AS COUNT_OF_STUDENTS,
        ROUND(AVG(study_hours_per_week),2) AS Average_study_hours_per_week,
        ROUND(AVG(attendance_rate)) AS average_attendace_rate,
        ROUND(AVG(extracurricular_activities),2) AS AVG_NO_OF_EXTRA_CURRICULAR_CLASSES
FROM Performance_Momentum 
GROUP BY Performance,parental_support,online_class_status
ORDER BY COUNT_OF_STUDENTS DESC;



