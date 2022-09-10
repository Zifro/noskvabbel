-- To run this on Scalingo PostgreSQL database:
--
-- 1. Run scalingo --app noskvabbel db-tunnel SCALINGO_POSTGRESQL_URL
-- 2. Set the DATABASE_URL environment variable with what the above command has
--    instructed you to, using the login and password present in environment
--    variable SCALINGO_POSTGRESQL_URL. It should be something linke:
--       postgresql://<user>:<password>@127.0.0.1:<port>/<db name>
-- 3. Run psql $DATABASE_URL
-- 4. Run \o expenses.txt to output the query results in the file expenses.txt
-- 5. Copy, paste, and execute the query below
-- 6. Run \q to exist the database client
--
-- All the output will be in the file expenses.txt, one record per line. Note it
-- will require some cleanup before parsing, or writing a tool to extract the
-- fields from the first line, ignore the second line, and drop the last line.
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
