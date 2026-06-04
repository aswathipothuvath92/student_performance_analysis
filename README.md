
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
---

## 🧠 Business Insights & Strategic Conclusions

### 📉 Question 1: Are Online Classes an Effective Equalizer?

#### **The Problem:**
We evaluated whether digital learning platforms successfully serve vulnerable student demographics—specifically those lacking strong parental support at home—or if changing the delivery medium compromises their academic growth.

#### **The Methodology:**
To build an indisputable conclusion, this question was analyzed using two distinct mathematical angles:
1. **Intensity (Growth Depth):** A CTE query calculated the exact average percentage jump in grade marks (`(Final - Previous) / Previous`).
2. **Volume (Success Rate):** A conditional aggregation query calculated the raw internal probability of a student successfully improving their grades.

#### **The Key Findings:**
* **Grade Growth Depth:** Low-parental-support students taking online classes achieved an average grade growth of **5.52%**, outperforming their in-person peers who averaged **5.03%**.
* **Success Rate:** When measuring the probability of improvement, the internal success rates remained remarkably stable and equal, sitting at **55.63%** for online delivery versus **55.47%** for traditional classrooms.

#### **Strategic Institutional Conclusion:**
The medium of delivery does not hinder academic performance or derail upward momentum. Online learning environments act as an absolute academic equalizer. For educational stakeholders and EdTech platforms, this is a green light: expanding digital infrastructure is a reliable, scalable, and highly equitable strategy to serve vulnerable student demographics without compromising growth metrics.

---

### ⏳ Question 2: The Study Hour Threshold & Diminishing Returns

#### **The Problem:**
To discover if there is an optimal study hour threshold before a student hits a plateau, or if extreme studying hours eventually yield diminishing academic returns.

#### **The Methodology:**
* **Data Boundary Exploration:** Prior to bucketing, `MIN()` and `MAX()` functions established that weekly student study habits strictly spanned between 8 hours and 30 hours.
* **Internal Ratio Slicing:** The continuous hour variables were segmented into 4 balanced behavioral buckets. 
* **Bias Correction:** The denominator was dynamically calculated as `COUNT(*)` per group rather than the total school population, ensuring low-sample groups (like extreme studiers) weren't mathematically masked by highly populated groups.

#### **The Key Findings:**
The relationship between time invested and academic return is non-linear, exposing a distinct behavioral fatigue curve among students as hours scale up:
* **8–12 Hours (Baseline Effort):** Yields a **52.14%** success rate.
* **13–18 Hours (The Efficiency Sweet Spot):** Success sharply climbs to **59.81%** (a substantial ~7% performance jump).
* **19–24 Hours (The Burnout Dip):** Performance hits a structural wall and drops back down to **54.45%**, indicating severe fatigue or inefficient study habits.
* **25–30 Hours (Maximum Breakthrough):** Rebounds to its highest point at **61.84%** as dedicated students break through the fatigue barrier to achieve mastery.

#### **Strategic Institutional Conclusion:**
While extreme grinding (25+ hours/week) yields the absolute highest performance, the marginal success gain—just ~2% higher than the moderate group—does not justify the massive extra 12+ hour weekly time commitment for standard interventions. True institutional efficiency lies in targeting the moderate window.

---

## 🛠️ Actionable Recommendations

1. **Standardize and Promote the "Sweet Spot":** Platform documentation, onboarding materials, and school guidance guidelines should actively market **13–18 hours/week** as the optimal, most sustainable study window. It delivers the maximum academic return on time invested.
2. **Flag and Intervene in the "Burnout Zone":** Build automated backend dashboard triggers to flag students who cross into the high-effort 19–24 hour range. Instead of encouraging them to study *more*, the platform should provide interventions focused on efficiency coaching, time management, and structured cognitive breaks.
3. **Resource Optimization:** Do not recommend extreme studying (25+ hours) as a baseline intervention strategy for struggling students. The time investment is massive, and the institutional resources are better spent moving "Low Effort" students (8-12 hours) into the highly efficient "Sweet Spot."
4. **Confident Online Scaling:** Educational stakeholders can confidently fund and scale online flexible learning options. It provides reliable, equitable upward momentum for independent learners without requiring intense, costly physical campus expansions.

## 📈 Next Steps
* Ask more business questions to extract student performance insights.
* Connect the finalized PostgreSQL database to a visualization tool to build a performance dashboard.



