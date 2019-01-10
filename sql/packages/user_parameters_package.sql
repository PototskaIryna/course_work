CREATE OR REPLACE PACKAGE user_parameters_package IS
    PROCEDURE add_user_parameters (
        status    OUT       VARCHAR2,
        firstid   IN        user_have_parameters.USER_INFO_USER_LOGIN%TYPE,
        lastid    IN        user_have_parameters.PARAMETERS_PARAM_ID%TYPE
    );

    PROCEDURE del_user_parameters(
        status   OUT      VARCHAR2,
        userid   IN       user_have_parameters.USER_INFO_USER_LOGIN%TYPE
    );
END user_parameters_package;
/

CREATE OR REPLACE PACKAGE BODY user_parameters_package IS

    PROCEDURE add_user_parameters (
        status    OUT       VARCHAR2,
        firstid   IN        user_have_parameters.USER_INFO_USER_LOGIN%TYPE,
        lastid    IN        user_have_parameters.PARAMETERS_PARAM_ID%TYPE
    ) IS
        PRAGMA autonomous_transaction;
    BEGIN
        INSERT INTO user_have_parameters (
            USER_INFO_USER_LOGIN,
            PARAMETERS_PARAM_ID
        ) VALUES (
            firstid,
            lastid
        );

        COMMIT;
        status := 'ok';
    EXCEPTION
        WHEN dup_val_on_index THEN
            status := 'Такий id уже існує';
        WHEN OTHERS THEN
            status := sqlerrm;
    END add_user_parameters;

    PROCEDURE del_user_parameters(
        status   OUT      VARCHAR2,
        userid   IN       user_have_parameters.USER_INFO_USER_LOGIN%TYPE
    ) IS
        PRAGMA autonomous_transaction;
    BEGIN
        DELETE FROM user_have_parameters
        WHERE
            user_have_parameters.USER_INFO_USER_LOGIN = userid;

        COMMIT;
        status := 'ok';
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            status := sqlerrm;
    END del_user_parameters;

END user_parameters_package;