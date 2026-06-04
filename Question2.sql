/*
===================================================================
 QUESTION 2: What is the optimal study hour threshold before performance plateaus?
   
 METHODOLOGY:
   - Initial exploration established the dataset boundaries (Min: 8 hours, Max: 30 hours).
   - Students were split into 4 balanced behavioral buckets to isolate trends.
   - Success rate was calculated internally within each bucket to eliminate sample size bias.

 KEY FINDINGS:
   - 8-12 Hours (Low Effort): 52.14% success rate.
   - 13-18 Hours (Sweet Spot): 59.81% success rate.
   - 19-24 Hours (The Plateau/Dip): Success drops back down to 54.45%.
   - 25-30 Hours (Maximum Breakthrough): 61.84% success rate.

===================================================================

*/--FINDING MINIMUM AND MAXIMUM STUDY HOURS ER WEEK
SELECT
        MIN(study_hours_per_week),
        MAX(study_hours_per_week)  
FROM academics
--result: Study hours per week spans from 8 hours to 30 hours

--Slicing the buckets based on that to find out percentage of improved students within each bucket
SELECT 
        CASE WHEN study_hours_per_week>=8 AND study_hours_per_week<=12 THEN '1.Between8_12_studyHours'
             WHEN study_hours_per_week>=13 AND study_hours_per_week<=18 THEN '2.Between13_18_studyHours'
             WHEN study_hours_per_week>=19 AND study_hours_per_week<=24 THEN '3.Between19_24_studyHours'
             ELSE '4.Above_24_studyHours'
        END AS StudyHours_Bucket,
        COUNT(*),
        ROUND(100.0*COUNT(CASE WHEN final_grade>previous_grade THEN 1 END)/COUNT(*),2)AS Percentage_of_improved_students
FROM academics
GROUP BY StudyHours_Bucket
ORDER BY StudyHours_Bucket;
        
        
   
