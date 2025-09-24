-- =========================================
-- SETUP: Create the StudentEnrollments table
-- =========================================
DROP TABLE IF EXISTS StudentEnrollments;

CREATE TABLE StudentEnrollments (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL,
    course_id VARCHAR(10) NOT NULL,
    enrollment_date DATE NOT NULL,
    UNIQUE (student_name, course_id)   -- Ensures no duplicate enrollments
);

-- Insert initial records
INSERT INTO StudentEnrollments (student_name, course_id, enrollment_date)
VALUES 
('Ashish', 'CSE101', '2024-07-01'),
('Smaran', 'CSE102', '2024-07-01'),
('Vaibhav', 'CSE101', '2024-07-01');



-- =========================================
-- PART A: Prevent Duplicate Enrollments
-- =========================================
-- Open two sessions to simulate concurrency.

-- USER 1
START TRANSACTION;
INSERT INTO StudentEnrollments (student_name, course_id, enrollment_date)
VALUES ('Ashish', 'CSE101', CURRENT_DATE);
COMMIT;

-- USER 2 (running at same time, will fail due to UNIQUE constraint)
START TRANSACTION;
INSERT INTO StudentEnrollments (student_name, course_id, enrollment_date)
VALUES ('Ashish', 'CSE101', CURRENT_DATE);
-- ERROR: Duplicate entry 'Ashish-CSE101' for key 'student_name_course_id'
COMMIT;



-- =========================================
-- PART B: SELECT FOR UPDATE (Row Locking)
-- =========================================
-- USER A
START TRANSACTION;
SELECT * FROM StudentEnrollments 
WHERE student_name = 'Ashish' AND course_id = 'CSE101'
FOR UPDATE;
-- Row is now locked until COMMIT/ROLLBACK

-- USER B (will be blocked until User A commits)
START TRANSACTION;
UPDATE StudentEnrollments
SET enrollment_date = CURRENT_DATE
WHERE student_name = 'Ashish' AND course_id = 'CSE101';
COMMIT;

-- USER A eventually commits
COMMIT;



-- =========================================
-- PART C: Locking Preserves Consistency
-- =========================================
-- USER A
START TRANSACTION;
SELECT * FROM StudentEnrollments 
WHERE student_name = 'Vaibhav' AND course_id = 'CSE101'
FOR UPDATE;
UPDATE StudentEnrollments
SET enrollment_date = '2024-07-15'
WHERE student_name = 'Vaibhav' AND course_id = 'CSE101';
-- Do not commit yet

-- USER B (tries to update same record, will wait)
START TRANSACTION;
SELECT * FROM StudentEnrollments 
WHERE student_name = 'Vaibhav' AND course_id = 'CSE101'
FOR UPDATE;
UPDATE StudentEnrollments
SET enrollment_date = '2024-07-20'
WHERE student_name = 'Vaibhav' AND course_id = 'CSE101';
COMMIT;

-- USER A commits (now User B proceeds)
COMMIT;

-- Final check
SELECT * FROM StudentEnrollments;
