CREATE OR REPLACE PACKAGE parametrs_package IS
    TYPE parametrs_row IS RECORD (
        paramid parametrs.param_id%TYPE,
        paramname parametrs.param_name%TYPE
    );
    TYPE parametrs_table IS
        TABLE OF parametrs_row;
    PROCEDURE add_parametrs (
        status     OUT        VARCHAR2,
        paramid      IN         parametrs.param_id%TYPE,
        paramname    IN         parametrs.param_name%TYPE,
        paramautor   IN         parametrs.user_info_user_login%TYPE
    );

    PROCEDURE del_parametrs (
        status   OUT      VARCHAR2,
        paramid    IN       parametrs.param_id%TYPE
    );

    PROCEDURE update_parametrs (
        status    OUT       VARCHAR2,
        paramid     IN        parametrs.param_id%TYPE,
        paramname   IN        parametrs.param_name%TYPE
    );

    FUNCTION get_user_parametrs(
        paramautor   IN         parametrs.user_info_user_login%TYPE
    ) RETURN parametrs_table
        PIPELINED;

END parametrs_package;
/

CREATE OR REPLACE PACKAGE BODY parametrs_package IS

    PROCEDURE add_parametrs (
        status     OUT        VARCHAR2,
        paramid      IN         parametrs.param_id%TYPE,
        paramname    IN         parametrs.param_name%TYPE,
        paramautor   IN         parametrs.user_info_user_login%TYPE
    ) IS
        PRAGMA autonomous_transaction;
    BEGIN
        INSERT INTO parametrs (
            param_id,
            param_name,
            user_info_user_login
        ) VALUES (
            paramid,
            paramname,
            paramautor
        );

        COMMIT;
        status := 'ok';
    EXCEPTION
        WHEN dup_val_on_index THEN
            status := 'Такий id уже існує';
        WHEN OTHERS THEN
            status := sqlerrm;
    END add_parametrs;

    PROCEDURE del_parametrs (
        status   OUT      VARCHAR2,
        paramid    IN       parametrs.param_id%TYPE
    ) IS
        PRAGMA autonomous_transaction;
    BEGIN
        DELETE FROM parametrs_view
        WHERE
            parametrs_view.param_id = paramid;

        COMMIT;
        status := 'ok';
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            status := sqlerrm;
    END del_parametrs;

    PROCEDURE update_parametrs (
        status    OUT       VARCHAR2,
        paramid     IN        parametrs.param_id%TYPE,
        paramname   IN        parametrs.param_name%TYPE
    ) IS
        PRAGMA autonomous_transaction;
    BEGIN
        UPDATE parametrs
        SET
            parametrs.param_name = paramname
        WHERE
            parametrs.param_id = paramid;

        COMMIT;
        status := 'ok';
    EXCEPTION
        WHEN OTHERS THEN
            status := sqlerrm;
    END update_parametrs;

    FUNCTION get_user_parametrs(
        paramautor   IN         parametrs.user_info_user_login%TYPE
    ) RETURN parametrs_table
        PIPELINED
    IS
    BEGIN
        FOR curr IN (
            SELECT DISTINCT
                param_id,
                param_name
            FROM
                parametrs
            WHERE
                parametrs.user_info_user_login = paramautor
        ) LOOP
            PIPE ROW ( curr );
        END LOOP;
    END get_user_parametrs;

END parametrs_package;