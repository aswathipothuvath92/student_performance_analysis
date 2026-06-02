
-- STEP 0: Database Initialization
-- Execute this script first to create the physical database container.

SELECT 'Creating database...' AS status;

-- Note: In standard SQL, CREATE DATABASE cannot run inside a transaction block. 
-- Ensure this is executed on your default postgres server connection.
--CREATING STUDENT PERFORMANCE DATABASE--
CREATE DATABASE Student_perfomance_DB;
