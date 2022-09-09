-- To run this on Scalingo PostgreSQL database:
--
-- 1. Run scalingo -a noskvabbel pgsql-console | cat >users.txt
-- 2. Copy and paste the query below. It won't echo.
-- 3. Type `exit` (without the backticks), then press Enter key. This will exit.
--
-- All the output will be in the file users.txt. Beware it will require some
-- cleanup and a thorough parser to extract information
--
SELECT  *
FROM    users
;
