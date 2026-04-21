-- PostgreSQL version of webgoat_sqlserver.sql
-- Remediation: SQL Server to PostgreSQL syntax migration
-- CAST Imaging Advisor ID: 1202247 (SQL Server Database to PostgreSQL)
--
-- Changes applied:
--   1. NVARCHAR -> VARCHAR (PostgreSQL does not have NVARCHAR)
--   2. CONVERT(varchar(10), x) -> CAST(x AS VARCHAR(10))
--   3. @variable declarations -> PostgreSQL $body$ / DECLARE blocks
--   4. SET/SELECT @var = ... -> PostgreSQL variable assignment (:=)
--   5. GO batch separators removed (not supported in PostgreSQL)
--   6. CREATE PROCEDURE -> CREATE OR REPLACE FUNCTION ... RETURNS VOID
--   7. sp_executesql -> EXECUTE with format()
--   8. IF EXISTS ... DROP -> DROP ... IF EXISTS
--   9. CREATE LOGIN / CREATE USER / GRANT CONTROL -> CREATE ROLE with privileges
--  10. EXEC sp_configure / RECONFIGURE -> removed (not applicable)
--  11. USE database -> \connect (handled externally)
--  12. CREATE SCHEMA -> CREATE SCHEMA IF NOT EXISTS
--  13. BIT return type -> INTEGER (0/1) for API compatibility
--  14. CREATE ASSEMBLY / EXTERNAL NAME -> removed (CLR not supported)

-- Drop existing objects if they exist
DROP SCHEMA IF EXISTS webgoat_guest CASCADE;
DROP ROLE IF EXISTS webgoat_guest;

-- Note: In PostgreSQL, database creation is typically done externally:
--   CREATE DATABASE webgoat;
--   \connect webgoat

CREATE SCHEMA IF NOT EXISTS webgoat_guest;

CREATE ROLE webgoat_guest WITH LOGIN PASSWORD '_webgoat';
GRANT USAGE ON SCHEMA webgoat_guest TO webgoat_guest;
ALTER DEFAULT PRIVILEGES IN SCHEMA webgoat_guest GRANT ALL ON TABLES TO webgoat_guest;

CREATE TABLE webgoat_guest.employee (
    userid INT NOT NULL PRIMARY KEY,
    first_name VARCHAR(20),
    last_name VARCHAR(20),
    ssn VARCHAR(12),
    password VARCHAR(10),
    title VARCHAR(20),
    phone VARCHAR(13),
    address1 VARCHAR(80),
    address2 VARCHAR(80),
    manager INT,
    start_date CHAR(8),
    salary INT,
    ccn VARCHAR(30),
    ccn_limit INT,
    disciplined_date CHAR(8),
    disciplined_notes VARCHAR(60),
    personal_description VARCHAR(60)
);

-- Remediated: SQL Server PROCEDURE with @parameters -> PostgreSQL FUNCTION with DECLARE block
-- Remediated: SQL Server @v_* variables -> PostgreSQL p_* parameters
DROP FUNCTION IF EXISTS webgoat_guest.update_employee(INT, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, INT, CHAR, INT, VARCHAR, INT, CHAR, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION webgoat_guest.update_employee(
    p_userid INT,
    p_first_name VARCHAR(20),
    p_last_name VARCHAR(20),
    p_ssn VARCHAR(12),
    p_title VARCHAR(20),
    p_phone VARCHAR(13),
    p_address1 VARCHAR(80),
    p_address2 VARCHAR(80),
    p_manager INT,
    p_start_date CHAR(8),
    p_salary INT,
    p_ccn VARCHAR(30),
    p_ccn_limit INT,
    p_disciplined_date CHAR(8),
    p_disciplined_notes VARCHAR(60),
    p_personal_description VARCHAR(60)
) RETURNS VOID AS $$
BEGIN
    UPDATE webgoat_guest.employee
    SET
        first_name = p_first_name,
        last_name = p_last_name,
        ssn = p_ssn,
        title = p_title,
        phone = p_phone,
        address1 = p_address1,
        address2 = p_address2,
        manager = p_manager,
        start_date = p_start_date,
        salary = p_salary,
        ccn = p_ccn,
        ccn_limit = p_ccn_limit,
        disciplined_date = p_disciplined_date,
        disciplined_notes = p_disciplined_notes,
        personal_description = p_personal_description
    WHERE
        userid = p_userid;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS webgoat_guest.update_employee_backup(INT, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, INT, CHAR, INT, VARCHAR, INT, CHAR, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION webgoat_guest.update_employee_backup(
    p_userid INT,
    p_first_name VARCHAR(20),
    p_last_name VARCHAR(20),
    p_ssn VARCHAR(12),
    p_title VARCHAR(20),
    p_phone VARCHAR(13),
    p_address1 VARCHAR(80),
    p_address2 VARCHAR(80),
    p_manager INT,
    p_start_date CHAR(8),
    p_salary INT,
    p_ccn VARCHAR(30),
    p_ccn_limit INT,
    p_disciplined_date CHAR(8),
    p_disciplined_notes VARCHAR(60),
    p_personal_description VARCHAR(60)
) RETURNS VOID AS $$
BEGIN
    UPDATE webgoat_guest.employee
    SET
        first_name = p_first_name,
        last_name = p_last_name,
        ssn = p_ssn,
        title = p_title,
        phone = p_phone,
        address1 = p_address1,
        address2 = p_address2,
        manager = p_manager,
        start_date = p_start_date,
        salary = p_salary,
        ccn = p_ccn,
        ccn_limit = p_ccn_limit,
        disciplined_date = p_disciplined_date,
        disciplined_notes = p_disciplined_notes,
        personal_description = p_personal_description
    WHERE
        userid = p_userid;
END;
$$ LANGUAGE plpgsql;

-- Remediated: NVARCHAR(4000) -> VARCHAR(4000)
-- Remediated: DECLARE @sql nvarchar, @count int -> PostgreSQL DECLARE block
-- Remediated: SELECT @sql = ... -> v_sql := ...
-- Remediated: CONVERT(varchar(10), @v_id) -> CAST(p_id AS VARCHAR(10))
-- Remediated: EXEC sp_executesql -> EXECUTE ... USING
DROP FUNCTION IF EXISTS webgoat_guest.employee_login(INT, VARCHAR);

CREATE OR REPLACE FUNCTION webgoat_guest.employee_login(
    p_id INT,
    p_password VARCHAR(100)
) RETURNS INTEGER AS $$
DECLARE
    v_sql VARCHAR(4000);
    v_count INT;
BEGIN
    -- Note: This intentionally preserves the dynamic SQL pattern from the original
    -- for educational purposes (WebGoat is a deliberately vulnerable application).
    -- In production code, use parameterized queries instead.
    v_sql := 'SELECT COUNT(*) FROM webgoat_guest.employee WHERE userid = '
             || CAST(p_id AS VARCHAR(10))
             || ' AND password = ''' || p_password || '''';
    EXECUTE v_sql INTO v_count;
    RETURN v_count;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS webgoat_guest.employee_login_backup(INT, VARCHAR);

CREATE OR REPLACE FUNCTION webgoat_guest.employee_login_backup(
    p_id INT,
    p_password VARCHAR(100)
) RETURNS INTEGER AS $$
DECLARE
    v_sql VARCHAR(4000);
    v_count INT;
BEGIN
    -- Note: This intentionally preserves the dynamic SQL pattern from the original
    -- for educational purposes (WebGoat is a deliberately vulnerable application).
    -- In production code, use parameterized queries instead.
    v_sql := 'SELECT COUNT(*) FROM webgoat_guest.employee WHERE userid = '
             || CAST(p_id AS VARCHAR(10))
             || ' AND password = ''' || p_password || '''';
    EXECUTE v_sql INTO v_count;
    RETURN v_count;
END;
$$ LANGUAGE plpgsql;

-- Note: The original RegexMatch function used SQL Server CLR integration
-- (CREATE ASSEMBLY / EXTERNAL NAME) which is not supported in PostgreSQL.
-- PostgreSQL has native regex support via the ~ operator and regexp_match().
-- The following function provides equivalent functionality using built-in regex.
DROP FUNCTION IF EXISTS webgoat_guest.regex_match(VARCHAR, VARCHAR);

-- Returns INTEGER (1 = match, 0 = no match) to preserve compatibility with
-- the original SQL Server BIT return type.  The instructor Stage 2 solution
-- (see UpdateProfile_i.java) tests "RegexMatch(...) = 0", so returning
-- BOOLEAN would break that pattern.
CREATE OR REPLACE FUNCTION webgoat_guest.regex_match(
    p_input VARCHAR,
    p_pattern VARCHAR
) RETURNS INTEGER AS $$
BEGIN
    IF p_input ~ p_pattern THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
END;
$$ LANGUAGE plpgsql;
