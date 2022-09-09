-- To run this on Scalingo PostgreSQL database:
--
-- 1. Run scalingo -a noskvabbel pgsql-console | cat >expenses.txt
-- 2. Copy and paste the query below. It won't echo.
-- 3. Type `exit` (without the backticks), then press Enter key. This will exit.
--
-- All the output will be in the file expenses.txt. Beware it will require some
-- cleanup and a thorough parser to extract information
--
SELECT  u.username,
        e.label,
        e.amount,
        e.spent_on,
        e.created_at,
        e.updated_at,
        u2.username
FROM    expenses e
JOIN    users u ON u.id = e.user_id
JOIN    users u2 ON u2.id = e.created_by_id
;
