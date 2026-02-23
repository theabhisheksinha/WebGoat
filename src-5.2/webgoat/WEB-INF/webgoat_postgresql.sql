-- PostgreSQL-compatible version of webgoat_sqlserver.sql
-- Migrated from SQL Server to PostgreSQL to address CAST Imaging database migration findings:
--   - Replaced NVARCHAR with VARCHAR (PostgreSQL uses VARCHAR natively for Unicode)
--   - Replaced CONVERT() scalar function with CAST() (ANSI SQL standard)
--   - Replaced @variable declarations (DECLARE @var) with PostgreSQL $$ block variables
--   - Replaced SET/SELECT @variable assignments with PostgreSQL := assignments
--   - Replaced SQL Server GO batch separators with PostgreSQL semicolons
--   - Replaced SQL Server stored procedures with PostgreSQL functions
--   - Removed CLR assembly references (not supported in PostgreSQL)
--   - Replaced sp_executesql with PostgreSQL EXECUTE

-- Drop existing objects if they exist
DROP ROLE IF EXISTS webgoat_guest;
DROP DATABASE IF EXISTS webgoat;

-- Create database
CREATE DATABASE webgoat;

-- Connect to webgoat database (run \c webgoat in psql)

-- Create schema
CREATE SCHEMA IF NOT EXISTS webgoat_guest;

-- Create role
CREATE ROLE webgoat_guest WITH LOGIN PASSWORD '_webgoat';
GRANT USAGE ON SCHEMA webgoat_guest TO webgoat_guest;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA webgoat_guest TO webgoat_guest;
ALTER DEFAULT PRIVILEGES IN SCHEMA webgoat_guest GRANT ALL ON TABLES TO webgoat_guest;


-- Create EMPLOYEE table
-- Migration: No NVARCHAR needed; PostgreSQL VARCHAR handles Unicode natively
CREATE TABLE webgoat_guest.EMPLOYEE (
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

-- Drop existing functions if they exist
DROP FUNCTION IF EXISTS webgoat_guest.UPDATE_EMPLOYEE(INT, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, INT, CHAR, INT, VARCHAR, INT, CHAR, VARCHAR, VARCHAR);
DROP FUNCTION IF EXISTS webgoat_guest.UPDATE_EMPLOYEE_BACKUP(INT, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, INT, CHAR, INT, VARCHAR, INT, CHAR, VARCHAR, VARCHAR);

-- Migration: SQL Server PROCEDURE -> PostgreSQL FUNCTION
-- Migration: @variable parameters -> p_ prefixed parameters (no @ in PostgreSQL)
CREATE OR REPLACE FUNCTION webgoat_guest.UPDATE_EMPLOYEE(
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
    UPDATE webgoat_guest.EMPLOYEE
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

CREATE OR REPLACE FUNCTION webgoat_guest.UPDATE_EMPLOYEE_BACKUP(
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
    UPDATE webgoat_guest.EMPLOYEE
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

-- Drop existing login functions if they exist
DROP FUNCTION IF EXISTS webgoat_guest.EMPLOYEE_LOGIN(INT, VARCHAR);
DROP FUNCTION IF EXISTS webgoat_guest.EMPLOYEE_LOGIN_BACKUP(INT, VARCHAR);

-- Migration: DECLARE @sql NVARCHAR -> v_sql VARCHAR (no NVARCHAR in PostgreSQL)
-- Migration: CONVERT(varchar(10), @v_id) -> CAST(p_id AS VARCHAR(10))
-- Migration: sp_executesql -> EXECUTE with format()
-- Migration: SELECT @variable = expression -> variable := expression
CREATE OR REPLACE FUNCTION webgoat_guest.EMPLOYEE_LOGIN(
    p_id INT,
    p_password VARCHAR(100)
) RETURNS INTEGER AS $$
DECLARE
    v_sql VARCHAR(4000);
    v_count INT;
BEGIN
    v_sql := 'SELECT COUNT(*) FROM webgoat_guest.EMPLOYEE WHERE USERID = ' || CAST(p_id AS VARCHAR(10)) || ' AND PASSWORD = ''' || p_password || '''';
    EXECUTE v_sql INTO v_count;
    RETURN v_count;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION webgoat_guest.EMPLOYEE_LOGIN_BACKUP(
    p_id INT,
    p_password VARCHAR(100)
) RETURNS INTEGER AS $$
DECLARE
    v_sql VARCHAR(4000);
    v_count INT;
BEGIN
    v_sql := 'SELECT COUNT(*) FROM webgoat_guest.EMPLOYEE WHERE USERID = ' || CAST(p_id AS VARCHAR(10)) || ' AND PASSWORD = ''' || p_password || '''';
    EXECUTE v_sql INTO v_count;
    RETURN v_count;
END;
$$ LANGUAGE plpgsql;

-- Migration: CLR Assembly (RegexMatch) -> PostgreSQL native regex
-- PostgreSQL has built-in regex support, no need for external assemblies
-- Migration: NVARCHAR(MAX) -> TEXT (PostgreSQL equivalent for unlimited length strings)
-- Migration: BIT return type -> BOOLEAN
DROP FUNCTION IF EXISTS webgoat_guest.RegexMatch(TEXT, TEXT);

CREATE OR REPLACE FUNCTION webgoat_guest.RegexMatch(
    p_input TEXT,
    p_pattern TEXT
) RETURNS BOOLEAN AS $$
BEGIN
    RETURN p_input ~ p_pattern;
END;
$$ LANGUAGE plpgsql;
