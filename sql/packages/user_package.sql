CREATE OR REPLACE PACKAGE user_package IS
    TYPE user_row IS RECORD (
        loginuser user_info.user_login%TYPE,
        nameuser user_info.user_name%TYPE
    );
    TYPE user_table IS
        TABLE OF user_row;
    PROCEDURE add_user (
        status          OUT             VARCHAR2,
        loginuser       IN              user_info.user_login%TYPE,
        nameuser   IN              user_info.user_name%TYPE,
        passworduser    IN              user_info.user_password%TYPE
    );

    PROCEDURE del_user (
        loginuser   IN          user_info.user_login%TYPE
    );

    PROCEDURE update_user (
        status          OUT             VARCHAR2,
        loginuser       IN              user_info.user_login%TYPE,
        nameuser   IN              user_info.user_name%TYPE
    );

    FUNCTION get_user_info (
        loginuser   IN          user_info.user_login%TYPE
    ) RETURN user_table
        PIPELINED;

    FUNCTION login_user (
        loginuser      user_info.user_login%TYPE,
        passworduser   user_info.user_password%TYPE
    ) RETURN NUMBER;

END user_package;
/

CREATE OR REPLACE PACKAGE BODY user_package IS

    PROCEDURE add_user (
        status          OUT             VARCHAR2,
        loginuser       IN              user_info.user_login%TYPE,
        nameuser   IN              user_info.user_name%TYPE,
        passworduser    IN              user_info.user_password%TYPE
    ) IS
        PRAGMA autonomous_transaction;
    BEGIN
        INSERT INTO user_info (
            user_login,
            user_name,
            user_password
        ) VALUES (
            loginuser,
            nameuser,
            passworduser
        );

        COMMIT;
        status := 'ok';
    EXCEPTION
        WHEN dup_val_on_index THEN
            status := 'Користувач з таким іменем уже існує';
        WHEN OTHERS THEN
            status := sqlerrm;
    END add_user;

    PROCEDURE del_user (
        loginuser   IN          user_info.user_login%TYPE
    ) IS
        PRAGMA autonomous_transaction;
    BEGIN
        DELETE FROM USER_INFO
        WHERE
            USER_INFO.user_login = loginuser;

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE value_error;
    END del_user;

    PROCEDURE update_user (
        status          OUT             VARCHAR2,
        loginuser       IN              user_info.user_login%TYPE,
        nameuser   IN              user_info.user_name%TYPE
    ) IS
        PRAGMA autonomous_transaction;
    BEGIN
        UPDATE user_info
        SET
            user_info.user_name = nameuser
        WHERE
            user_info.user_login = loginuser;

        COMMIT;
        status := 'ok';
    EXCEPTION
        WHEN OTHERS THEN
            status := sqlerrm;
    END update_user;

    FUNCTION get_user_info (
        loginuser   IN          user_info.user_login%TYPE
    ) RETURN user_table
        PIPELINED
    IS
    BEGIN
        FOR curr IN (
            SELECT DISTINCT
                user_login,
                user_name
            FROM
                user_info
            WHERE
                user_info.user_login = loginuser
        ) LOOP
            PIPE ROW ( curr );
        END LOOP;
    END get_user_info;

    FUNCTION login_user (
        loginuser      user_info.user_login%TYPE,
        passworduser   user_info.user_password%TYPE
    ) RETURN NUMBER IS
        res   NUMBER(1);
    BEGIN
        SELECT
            COUNT(*)
        INTO res
        FROM
            user_info
        WHERE
            user_info.user_login = loginuser
            AND user_info.user_password = passworduser;

        return(res);
    END login_user;

END user_package;
/