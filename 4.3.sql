-- =========================================
-- SETUP: Create StudentEnrollments table
-- =========================================
DROP TABLE IF EXISTS StudentEnrollments;

CREATE TABLE StudentEnrollments (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100),
    course_id VARCHAR(10),
    enrollment_date DATE
) ENGINE=InnoDB;

-- Insert sample data
INSERT INTO StudentEnrollments VALUES
(1, 'Ashish', 'CSE101', '2024-06-01'),
(2, 'Smaran', 'CSE102', '2024-06-01'),
(3, 'Vaibhav', 'CSE103', '2024-06-01');


-- =========================================
-- PART A: Simulating a Deadlock
-- =========================================
-- Open two sessions (Session A and Session B)

-- Session A
START TRANSACTION;
UPDATE StudentEnrollments SET enrollment_date = '2024-06-10' WHERE student_id = 1;
-- Do not commit yet, now try to update student_id = 2
UPDATE StudentEnrollments SET enrollment_date = '2024-06-11' WHERE student_id = 2;
-- This will wait (because Session B has already locked student_id=2)

-- Session B
START TRANSACTION;
UPDATE StudentEnrollments SET enrollment_date = '2024-06-20' WHERE student_id = 2;
-- Do not commit yet, now try to update student_id = 1
UPDATE StudentEnrollments SET enrollment_date = '2024-06-21' WHERE student_id = 1;
-- Deadlock occurs! One transaction is rolled back automatically.

-- Expected Output:
-- ERROR 1213 (40001): Deadlock found when trying to get lock; try restarting transaction


-- =========================================
-- PART B: MVCC Demonstration
-- =========================================
-- User A (Reader)
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
SELECT * FROM StudentEnrollments WHERE student_id = 1;
-- Output: enrollment_date = 2024-06-01 (snapshot value)

-- User B (Writer, concurrently)
START TRANSACTION;
UPDATE StudentEnrollments SET enrollment_date = '2024-07-10' WHERE student_id = 1;
COMMIT;

-- Back to User A (still in the same transaction)
SELECT * FROM StudentEnrollments WHERE student_id = 1;
-- Output still shows enrollment_date = 2024-06-01 (consistent snapshot)

-- User A commits
COMMIT;

-- New transaction by User A
START TRANSACTION;
SELECT * FROM StudentEnrollments WHERE student_id = 1;
-- Output now shows enrollment_date = 2024-07-10
COMMIT;


-- =========================================
-- PART C: Comparing With and Without MVCC
-- =========================================

-- CASE 1: With Traditional Locking (SELECT FOR UPDATE)
-- User A
START TRANSACTION;
SELECT * FROM StudentEnrollments WHERE student_id = 1 FOR UPDATE;
-- Row locked, reader holds exclusive lock

-- User B (concurrent session)
START TRANSACTION;
SELECT * FROM StudentEnrollments WHERE student_id = 1;
-- This will BLOCK until User A commits (because of FOR UPDATE)

-- CASE 2: With MVCC (Normal SELECT under Repeatable Read)
-- User A
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
SELECT * FROM StudentEnrollments WHERE student_id = 1;
-- Reads snapshot

-- User B
START TRANSACTION;
UPDATE StudentEnrollments SET enrollment_date = '2024-07-15' WHERE student_id = 1;
COMMIT;

-- User A (still in same transaction)
SELECT * FROM StudentEnrollments WHERE student_id = 1;
-- Still sees the old value (snapshot), no blocking

-- User A commits
COMMIT;

-- After commit, new reads show the updated value
SELECT * FROM StudentEnrollments WHERE student_id = 1;
