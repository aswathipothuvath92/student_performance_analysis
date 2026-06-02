
# Student Performance Analytics & Relational Database Pipeline

## 📌 Project Overview
This project transforms a flat, raw student performance dataset into a fully normalized, production-grade relational database using PostgreSQL. The goal of this project is to build a reliable data infrastructure that isolates student demographics, academic metrics, and behavioral engagement into distinct, optimized tables for advanced analysis.


## 🛠️ Tech Stack & Skills
* **Database Management System:** PostgreSQL
* **Tools:** pgAdmin 4, VS Code, Git/GitHub
* **SQL Concepts utilized:** Data Definition Language (DDL), Data Manipulation Language (DML), Primary & Foreign Key Constraints, Staging Tables, Duplicate Resolution (`ON CONFLICT`), and Data Cleanliness Constraints (`NOT NULL`).

## 🗄️ Database Creation & Initialization
Before running the SQL scripts, a dedicated database must be initialized in PostgreSQL. You can create this via the pgAdmin Query Tool or your terminal using the following command:
```sql
CREATE DATABASE student_performance;
```

## 📐 Database Architecture & Normalization
The project pipeline has been modularized into sequential SQL scripts executed within VS Code:

* **`Create_DB.sql`**: Establishes the core database structure and sets up relational tables.
* **`Load_data.sql`**: Handles the initial ingestion of raw records into the staging environment.
* **`clean_data.sql`**: Executes advanced data cleaning, formatting structural columns for consistency, and drilling down into data anomalies.

The raw data was ingested into a temporary staging area (`student_performance_staging`) to audit the schema and clean data types. From there, the dataset was normalized into a 3-table relational schema to eliminate data redundancy and enforce relational integrity:
* **`students`**: Contains core demographic information (`student_id`, `student_name`, `gender`).
* **`academics`**: Tracks historical and current performance metrics (`attendance_rate`, `attendance_percentage`, `study_hours`, `previous_grade`, `final_grade`).
* **`engagement`**: Captures behavioral indicators and external support metrics (`extracurricular_activities`, `parental_support`, `online_classes_taken`).


## 🧠 Technical Challenges & Engineering Solutions
* **Challenge: Local File Permission Restrictions.** Faced system blocks when executing local `COPY` SQL scripts.
  * *Solution:* Leveraged pgAdmin's visual Import/Export utility tool to bypass local path restrictions safely.
* **Challenge: Schema Drift (Unexpected Columns).** Discovered unexpected attributes (`attendance_percentage` and `online_classes_taken`) in the raw CSV file that were missing from the initial database design.
  * *Solution:* Audited the source file, altered the staging schema, and adapted data types to include `NUMERIC` and `BOOLEAN` allocations before processing.
* **Challenge: Data Anomalies (Missing IDs & Duplicate Keys).** The raw dataset contained unexpected `NULL` values and duplicate entries for singular primary keys, causing standard migration scripts to fail.
  * *Solution:* Implemented explicit `WHERE student_id IS NOT NULL` filtration alongside `ON CONFLICT (student_id) DO NOTHING` clauses to dynamically filter out broken rows and handle duplicates without crashing the pipeline.
* **Challenge: Data Inconsistencies & Structural Anomalies.** The raw staging data contained missing records, text formatting discrepancies, and logical contradictions between related metrics.
  * *Solution:* Implemented comprehensive cleaning logic in `clean_data.sql` to:
    * **Handle Missing Data:** Identified `NULL` values across key academic metrics and systematically amended them using calculated averages and populated baseline values using CASE to maintain dataset integrity.
    * **Resolve Metric Mismatches:** Audited and reconciled logical conflicts between `attendance_rate` and `attendance_percentage` to ensure mathematical consistency across reporting features.
    * **Standardize Text Fields:** Checked for inconsistent text formatting across categorical columns for reliable grouping.
* **Challenge: Deep Data Anomalies & Duplicate Records.** Standard migration scripts risked contamination due to unexpected duplicate rows sharing the same student names or metrics, as well as placeholders like 'unknown' students repeating.
  * *Solution:* Developed deep audit queries in `clean_data.sql` utilizing advanced aggregations (`GROUP BY` and `HAVING COUNT(*) > 1`) to flag potential duplicates. To verify whether these rows represented true data duplication or natural data overlap, I implemented a defensive **`LEFT JOIN` pipeline audit script** to drill down into target student profiles (e.g., 'Anthony Smith', 'Andrea Frey', 'Erica Miller') across all split relational tables without risking data loss from missing records:
```sql
  SELECT S.student_name, S.gender, A.attendance_rate, A.attendance_percentage, E.online_class_status
  FROM students S
  LEFT JOIN academics A ON S.student_id = A.student_id
  LEFT JOIN engagement E ON S.student_id = E.student_id
  WHERE S.student_name IN ('Anthony Smith', 'Andrea Frey', 'Erica Miller');
```


## 📈 Next Steps
* Implement advanced data exploration queries using **Joins**, **CTEs (Common Table Expressions)** and **Window Functions** to extract student performance insights.
* Connect the finalized PostgreSQL database to a visualization tool to build a performance dashboard.



