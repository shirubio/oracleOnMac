-- ALTER SESSION SET CONTAINER = MYORADB1;
-- CREATE USER MY_USER IDENTIFIED BY "PWD GOES HERE";
-- GRANT DBA TO MY_USER;
-- ALTER USER MY_USER QUOTA UNLIMITED ON users;
-- SELECT * FROM dba_role_privs WHERE grantee = 'MY_USER';
--

ALTER SESSION SET CONTAINER = MYORADB1;

BEGIN
    -- Check if the user already exists
    DECLARE
        user_count INTEGER;
    BEGIN
        SELECT COUNT(*) INTO user_count FROM dba_users WHERE username = 'MY_USER';

        -- If the user does not exist, create the user and grant privileges
        IF user_count = 0 THEN
            EXECUTE IMMEDIATE 'CREATE USER MY_USER IDENTIFIED BY ChangeMe123';
            EXECUTE IMMEDIATE 'GRANT DBA TO MY_USER';
            EXECUTE IMMEDIATE 'ALTER USER MY_USER QUOTA UNLIMITED ON users';
            COMMIT;
        END IF;
    END;
END;
/

-- Check the privileges assigned to the user
SELECT * FROM dba_role_privs WHERE grantee = 'MY_USER';
