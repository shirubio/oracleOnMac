ALTER SESSION SET CONTAINER = MYORADB1;

BEGIN
    -- Enable DBMS_OUTPUT to print messages
    DBMS_OUTPUT.PUT_LINE('SCRIPT STARTED');

    -- Check if the user already exists
    DECLARE
        user_count INTEGER;
    BEGIN
        -- Print message indicating user check
        DBMS_OUTPUT.PUT_LINE('CHECKING IF USER EXISTS');

        SELECT COUNT(*) INTO user_count FROM dba_users WHERE username = 'MY_USER';

        -- If the user does not exist, create the user and grant privileges
        IF user_count = 0 THEN
            DBMS_OUTPUT.PUT_LINE('USER DOES NOT EXIST, CREATING USER...');
            EXECUTE IMMEDIATE 'CREATE USER MY_USER IDENTIFIED BY ChangeMe123';
            EXECUTE IMMEDIATE 'GRANT DBA TO MY_USER';
            EXECUTE IMMEDIATE 'ALTER USER MY_USER QUOTA UNLIMITED ON users';
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('USER CREATED AND PRIVILEGES GRANTED');
        ELSE
            DBMS_OUTPUT.PUT_LINE('USER ALREADY EXISTS');
        END IF;

        DBMS_OUTPUT.PUT_LINE('SCRIPT ENDED');
    END;
END;
/

-- Ensure server output is enabled to see the messages
SET SERVEROUTPUT ON;

-- Check the privileges assigned to the user
SELECT * FROM dba_role_privs WHERE grantee = 'MY_USER';