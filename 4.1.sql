-- ====================================================
-- Setup: Create FeePayments table
-- ====================================================
DROP TABLE IF EXISTS FeePayments;

CREATE TABLE FeePayments (
    payment_id   INT PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL,
    amount       DECIMAL(10,2) CHECK (amount > 0),
    payment_date DATE NOT NULL
);

-- ====================================================
-- Part A: Insert Multiple Payments (COMMIT)
-- ====================================================
BEGIN TRANSACTION;

INSERT INTO FeePayments VALUES (1, 'Ashish', 5000.00, '2024-06-01');
INSERT INTO FeePayments VALUES (2, 'Smaran', 4500.00, '2024-06-02');
INSERT INTO FeePayments VALUES (3, 'Vaibhav', 5500.00, '2024-06-03');

-- Commit to save permanently
COMMIT;

-- Verify Part A
SELECT 'After Part A (Committed Inserts)' AS status, * FROM FeePayments;

-- ====================================================
-- Part B: Failed Insert (ROLLBACK due to duplicate ID)
-- ====================================================
BEGIN TRANSACTION;

-- Valid insert
INSERT INTO FeePayments VALUES (4, 'Kiran', 6000.00, '2024-06-04');

-- Invalid insert (duplicate payment_id = 1, negative amount)
INSERT INTO FeePayments VALUES (1, 'Ashish', -4000.00, '2024-06-05');

-- Rollback since failure occurs
ROLLBACK;

-- Verify Part B (should still only show first 3 rows)
SELECT 'After Part B (Rollback due to failure)' AS status, * FROM FeePayments;

-- ====================================================
-- Part C: Partial Failure (NULL student_name)
-- ====================================================
BEGIN TRANSACTION;

-- Valid insert
INSERT INTO FeePayments VALUES (5, 'Ravi', 4800.00, '2024-06-06');

-- Invalid insert (NULL student_name violates NOT NULL)
INSERT INTO FeePayments VALUES (6, NULL, 5200.00, '2024-06-07');

-- Rollback entire transaction
ROLLBACK;

-- Verify Part C
SELECT 'After Part C (Rollback due to NULL)' AS status, * FROM FeePayments;

-- ====================================================
-- Part D: ACID Compliance Verification
-- ====================================================
-- Final check: Only valid committed inserts from Part A should remain
SELECT 'Final State (ACID Verified)' AS status, * FROM FeePayments;
