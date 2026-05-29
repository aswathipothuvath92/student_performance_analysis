
# Student Performance Analytics & Relational Database Pipeline

## 📌 Project Overview
This project transforms a flat, raw student performance dataset into a fully normalized, production-grade relational database using PostgreSQL. The goal of this project is to build a reliable data infrastructure that isolates student demographics, academic metrics, and behavioral engagement into distinct, optimized tables for advanced analysis.


## 🛠️ Tech Stack & Skills
* **Database Management System:** PostgreSQL
* **Tools:** pgAdmin 4, VS Code, Git/GitHub
* **SQL Concepts utilized:** Data Definition Language (DDL), Data Manipulation Language (DML), Primary & Foreign Key Constraints, Staging Tables, Duplicate Resolution (`ON CONFLICT`), and Data Cleanliness Constraints (`NOT NULL`).


## 📐 Database Architecture & Normalization
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

## 📈 Next Steps
* Implement advanced data exploration queries using **Joins**, **CTEs (Common Table Expressions)** and **Window Functions** to extract student performance insights.
* Connect the finalized PostgreSQL database to a visualization tool to build a performance dashboard.
