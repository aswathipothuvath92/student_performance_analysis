
# Student Performance Analytics & Relational Database Pipeline


## 📈 Executive Summary

* **The Problem:** Raw student data is often messy, fragmented, and flat, making it difficult for leadership to uncover the real behavioral and environmental triggers that drive academic success.
* **The Solution:** Built an automated, production-grade relational database pipeline in PostgreSQL that cleans, organizes, and transforms raw metrics into actionable institutional intelligence.
* **The Strategic Insight:** Discovered a distinct **"Academic Success Equilibrium."** Student performance peaks when maintaining a balanced lifestyle envelope of **13–18 study hours per week** paired with a hard cap of **1–2 extracurricular activities**. Forcing metrics past these thresholds triggers a sharp drop in student efficiency due to acute burnout.
* **Leadership Impact:** Proved data-backed evidence that online learning models serve as an absolute academic equalizer for vulnerable populations. Transitioning schools from punitive attendance policies to adaptive, asynchronous safety nets unlocks measurable student retention without requiring costly campus expansion.
---


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
The project pipeline is modularized into sequential SQL scripts executed within VS Code:
1. `Create_DB.sql` ➡️ Establishes the core database structure and sets up relational tables.
2. `Load_data.sql` ➡️ Handles the initial ingestion of raw records into the staging environment.
3. `clean_data.sql` ➡️ Executes advanced data cleaning, formatting structural columns for consistency, and drilling down into data anomalies.

The raw data was initially ingested into a temporary staging area (`student_performance_staging`) to audit the schema and clean data types. From there, the dataset was normalized into a 3-table relational schema to eliminate data redundancy while completely preserving data lineage across all columns:
* **`students`**: Contains core demographic information (`student_id`, `student_name`, `gender`).
* **`academics`**: Tracks historical and current performance metrics. Both columns are retained in the schema, but **`attendance_rate`** was selected for final analytics over the corrupted `attendance_percentage` column (`student_id`, `attendance_rate`, `attendance_percentage`, `study_hours`, `previous_grade`, `final_grade`).
* **`engagement`**: Captures behavioral indicators and external support metrics. The table houses the raw source field `online_classes_taken` alongside the engineered and populated **`online_class_status`** column used for reporting (`student_id`, `extracurricular_activities`, `parental_support`, `online_classes_taken`, `online_class_status`).

## 🧠 Technical Challenges & Engineering Solutions

* **Challenge: Local File Permission Restrictions.** Faced operating system permission blocks when trying to execute local bulk SQL `COPY` scripts to ingest raw data.
  * *Solution:* Leveraged pgAdmin's visual Import/Export utility interface to safely bypass local OS path restrictions and successfully stream the records.
* **Challenge: Schema Drift (Unexpected Columns).** Discovered unexpected structural attributes (`attendance_percentage` and `online_classes_taken`) in the raw incoming CSV file that were completely missing from the initial database blueprint.
  * *Solution:* Audited the source file layout, altered the initial staging schema via DDL, and adapted column types to safely include `NUMERIC` and `BOOLEAN` allocations before processing downstream data.
* **Challenge: Data Anomalies (Missing IDs & Duplicate Keys).** The raw dataset contained unexpected `NULL` values and duplicate entries for singular primary keys, causing standard migration scripts to fail and violate relational constraints.
  * *Solution:* Implemented explicit `WHERE student_id IS NOT NULL` filtration alongside defensive `ON CONFLICT (student_id) DO NOTHING` clauses to dynamically filter out broken rows and handle duplicates smoothly without crashing the pipeline.
* **Challenge: Data Inconsistencies & Structural Anomalies.** The raw staging data contained missing operational records, text formatting discrepancies, and logical contradictions between related metrics.
  * *Solution:* Implemented comprehensive cleaning logic directly within `clean_data.sql` to:
    * **Handle Missing Data:** Identified `NULL` values across key academic metrics and systematically amended them using calculated averages and conditional `CASE` statements to maintain dataset integrity.
    * **Resolve Metric Mismatches:** Audited and reconciled logical scaling conflicts between `attendance_rate` and `attendance_percentage` to ensure tight mathematical consistency across downstream reporting features.
    * **Standardize Text Fields:** Audited and normalized inconsistent text casing across categorical columns to guarantee uniform, reliable groupings for final aggregate queries.
* **Challenge: Multi-Table Operational Synchronization & Data Leakage Risks.** When migrating data from a single flat staging table into an optimized, multi-table relational schema (`students`, `academics`, and `engagement`), standard `INNER JOIN` verification queries risked dropping student records entirely or hiding underlying anomalies if any of the split tables suffered from unexpected missing rows or key mismatches during initial loads.
  * *Solution:* Designed and executed a defensive data validation script utilizing a explicit `LEFT JOIN` pipeline structure. This ensured that even if a specific student profile lacked perfectly synchronized engagement or academic records in the newly split target tables, the pipeline audit would still pull a complete, non-destructive snapshot of the migration landscape. This allowed for precise profile matching and deep anomaly tracking without risking data loss from missing records:
```sql
SELECT S.student_name, S.gender, A.attendance_rate, A.attendance_percentage, E.online_class_status
FROM students S
LEFT JOIN academics A ON S.student_id = A.student_id
LEFT JOIN engagement E ON S.student_id = E.student_id
WHERE S.student_name IN ('Anthony Smith', 'Andrea Frey', 'Erica Miller');
```

## 💡 Executive Business Insights

### 1. Are Online Classes an Effective Equalizer?
* **The Question:** Does changing the learning delivery medium to a digital environment hurt or help students who lack solid parental support structures at home?
* **The Evidence:** * *Grade Growth Depth:* Low-support students using online classes achieved a **5.52% average grade growth**, beating their in-person peers who averaged **5.03%**.
  * *Success Consistency:* The baseline probability of a student successfully improving their grades remained completely equal between both options (**55.63% online** vs. **55.47% in-person**).
* **Strategic Takeaway:** The medium of delivery does not hinder growth. Online learning environments act as an absolute equalizer, offering a highly scalable, equitable strategy to serve vulnerable student populations.

### 2. The Study Hour Threshold & Burnout Curves
* **The Question:** Is there a specific point where adding more study hours stops helping a student and starts hurting them?
* **The Evidence:** Tracking individual hours reveals a distinctly non-linear fatigue curve:

| Weekly Study Hours | Student Success Rate | Operational Status |
| :--- | :--- | :--- |
| **8 – 12 Hours** | 52.14% | Baseline Effort |
| **13 – 18 Hours** | **59.81%** | 🌟 **The Efficiency Sweet Spot** |
| **19 – 24 Hours** | 54.45% | ⚠️ **The Burnout Dip** (High Effort, Low Return) |
| **25 – 30 Hours** | **61.84%** | Maximum Mastery Breakthrough |

* **Strategic Takeaway:** While extreme grinding (25+ hours) yields the highest numerical success, the tiny **2% marginal gain** over the Sweet Spot does not justify the extra 12-hour weekly effort. Maximum institutional return lies in targeting the **13–18 hour window**.

### 3. The Attendance Threshold Paradox & "Hyper-Resilience"
* **Part 1: Data Validation & Boundary Exploration:** Audits on the academics schema revealed that `attendance_percentage` suffered from systemic scaling errors (ceilings up to 200.0). Conversely, `attendance_rate` proved clean and uncorrupted (70.0 to 95.0) and was locked in as our single source of truth.
* **Part 2: Macro Attendance Thresholds:** Segmented populations into Low (<80%), Moderate (80-89%), and High (90-95%) tiers. A fascinating paradox emerged: Low Attendance students demonstrated the highest overall directional grade improvement rate (**61.26%**), yet their absolute final mastery score sat at a lower baseline floor (**79.97**). High-attendance students maintain an excellent mastery floor but have naturally limited mathematical room for explosive point growth.
* **Part 3: Behavioral Profiling of Resilient Cohorts:** Engineered a chained CTE pipeline to locate initially failing students (<70) with low attendance (<80%) who achieved positive final growth.
  * *The Macro-Resilient Profile (47 Students):* **25 out of 47 students** actively utilized online classes, proving remote learning pathways act as a vital operational buffer when physical attendance collapses. Domestic support was split evenly, indicating family intervention was not the primary driver.
  * *The Formula of "The Hyper-Resilient Seven":* Stripping away all environmental cushions (isolating zero online classes and low parental support) left exactly 7 hyper-resilient students executing a self-directed comeback. Their exact behavioral formula was: replacing physical lectures with a massive **16.71 hours of weekly self-study** while keeping a strict behavioral anchor of **1.29 extracurricular activities** to prevent schedule collapse.

### 4. The Strategic Cohort Breakdown & Activity Caps
* **Core Analytical Framework:** Evaluated low-support student environments using macro-strategic engagement brackets (Approach A) and micro-forensic windowed aggregation (Approach B) to filter for individual students beating the cohort's net grade evolution.

> 💡 **Key Portfolio Insight: The Optimal Engagement Target**
> The data reveals that **exactly 125 isolated students** successfully beat the cohort average grade improvement curve. This resilient group maintains an optimal baseline average of **1.58 extracurricular activities**, proving empirically that a 1-2 activity range serves as the ideal lifestyle buffer for balancing academic stress.

### 5. Behavioral Profiles of Elite Achievers
* **The Uniform Distribution Workaround:** Initial data profiling revealed a distinct uniform distribution challenge: 100% of these elite achievers (>90% grade) sat at an identical final grade of exactly **92%**. To circumvent this tie, analytical window functions (`RANK()` and `DENSE_RANK()`) were deployed, partitioned dynamically by parental support levels.
* **Core Analytical Findings:**
  * *The Parental Support Partition Hierarchy:* Localized ranks show that success factors shift based on household engagement. Within both **High** and **Low** parental support brackets, traditional in-person students (`online_class_status = 'No'`) capture the **#1 Rank** for self-study investments (maxing out at **19.75 hours/week**). Conversely, this trend completely flips within the **Medium** parental support tier, where online students claim the **#1 Rank** by securing a higher baseline of **16.42 hours/week**.
  * *Validation of the Global Benchmarks:* The un-aggregated, segmented metrics of this elite cohort completely validate our global sweet spot, clustering tightly between **81.5% and 86.6% attendance** while logging **16.3 to 19.7 hours** of weekly independent study.
  * *The Activity Anchor:* Across every environmental variation, outside commitments remain highly compressed, tracking strictly between **1.17 and 1.89 activities**, proving elite achievers use a 1-2 activity cap as a hard behavioral brake to protect focus.
  

---

## 🚀 Data-Driven Actionable Recommendations

Based on the macro trends and micro-cohort insights extracted from the relational dataset, the following strategic interventions are recommended to optimize student retention and maximize institutional outcomes:

* **Transition from Punitive to Adaptive Attendance Rules:** * *The Data:* Low-attendance students (<80%) registered the highest overall directional improvement rate (**61.26%**). This proves that low classroom seat-time does not automatically equate to student apathy or a lack of capability.
  * *The Action:* Shift institutional frameworks away from purely punitive grading policies for absenteeism. Instead, build early-alert triggers that deploy automated academic check-ins at the 80% attendance mark to assess a student's situational needs before they hit an absolute learning ceiling.
* **Institutionalize the "Asynchronous Safety Net":** * *The Data:* Over **53% of the resilient, low-attendance cohorts** successfully leveraged online alternative pathways to protect their grades and maintain upward momentum.
  * *The Action:* Confidently scale up the availability of recorded lectures, digital resource hubs, and hybrid modular assignments. Treat asynchronous learning platforms as a deliberate operational backup pipeline designed specifically to support students managing non-traditional schedules or unexpected personal barriers.
* **Deploy "Self-Directed Learner" Independent Toolkits:** * *The Data:* The *Hyper-Resilient Seven* compensated for zero domestic support and a lack of digital infrastructure by grinding out an extraordinary **16.71 to 25.0 hours of weekly independent study** completely unassisted.
  * *The Action:* Identify highly disciplined, independent students facing systemic resource or household poverty. Provide them with targeted self-study toolkits—such as quiet campus study zone access, offline-accessible hardware, or learning resource stipends—to lower the friction of their high-intensity routines.
* **Implement a Proactive "1–2 Activity Cap" Policy:** * *The Data:* Across the board—including elite performers (>90% final grades) and resilient low-support cohorts—the optimal activity footprint remains immovably compressed, tracking strictly between **1.17 and 1.89 activities**.
  * *The Action:* Academic advisors should actively discourage students from overextending into 3 or more extracurricular commitments. Faculty should promote a "quality over quantity" approach, guiding students to select exactly 1 to 2 focal activities to preserve their critical independent study windows.
* **Tailor Modalities by Household Support Dynamics:** * *The Data:* Under Medium parental support, online students completely flip the global trend, capturing the **#1 Rank** by out-studying traditional in-person peers at **16.42 hours/week**.
  * *The Action:* Provide Medium Support student segments with robust, structured digital learning modules, as they exhibit an exceptional capacity to maximize study efficiency asynchronously. Conversely, restrict purely unmanaged asynchronous paths for Low Support tiers unless heavily augmented with digital accountability check-ins.
* **Target Operational Equilibrium Over Perfection:** * *The Data:* The non-linear study curve exposes a severe burnout dip between 19–24 hours (dropping to a 54.45% success rate), while the moderate 13–18 hour window captures a highly efficient **59.81% success rate**.
  * *The Action:* Shift institutional marketing from chasing a baseline of 100% attendance or extreme study blocks to tracking a sustainable student balance: **82%–86% classroom attendance paired with 16–19 hours of weekly independent review**. Target interventions to move low-effort students into this sweet spot rather than pushing moderate students into exhaustion.
---

## 📈 Next Steps
* Connect the finalized PostgreSQL database to a visualization tool to build a performance dashboard.



