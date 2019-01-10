CREATE OR REPLACE PACKAGE clothes_package IS
    TYPE clothes_row IS RECORD (
        clothesid clothes.clothes_id%TYPE,
        clothesname clothes.clothes_name%TYPE
    );
    TYPE clothes_table IS
        TABLE OF clothes_row;
    PROCEDURE add_clothes (
        status     OUT        VARCHAR2,
        cloid      IN         clothes.clothes_id%TYPE,
        cloname    IN         clothes.clothes_name%TYPE,
        cloautor   IN         clothes.user_info_user_login%TYPE
    );

    PROCEDURE del_clothes (
        status   OUT      VARCHAR2,
        cloid    IN       clothes.clothes_id%TYPE
    );

    PROCEDURE update_clothes (
        status    OUT       VARCHAR2,
        cloid     IN        clothes.clothes_id%TYPE,
        newname   IN        clothes.clothes_name%TYPE
    );

    FUNCTION get_user_clothes (
        cloautor   IN         clothes.user_info_user_login%TYPE
    ) RETURN clothes_table
        PIPELINED;

END clothes_package;
/

CREATE OR REPLACE PACKAGE BODY clothes_package IS

    PROCEDURE add_clothes (
        status     OUT        VARCHAR2,
        cloid      IN         clothes.clothes_id%TYPE,
        cloname    IN         clothes.clothes_name%TYPE,
        cloautor   IN         clothes.user_info_user_login%TYPE
    ) IS
        PRAGMA autonomous_transaction;
    BEGIN
        INSERT INTO clothes (
            clothes_id,
            clothes_name,
            user_info_user_login
        ) VALUES (
            cloid,
            cloname,
            cloautor
        );

        COMMIT;
        status := 'ok';
    EXCEPTION
        WHEN dup_val_on_index THEN
            status := 'Такий id уже існує';
        WHEN OTHERS THEN
            status := sqlerrm;
    END add_clothes;

    PROCEDURE del_clothes (
        status   OUT      VARCHAR2,
        cloid    IN       clothes.clothes_id%TYPE
    ) IS
        PRAGMA autonomous_transaction;
    BEGIN
        DELETE FROM clothes_view
        WHERE
            clothes_view.clothes_id = cloid;

        COMMIT;
        status := 'ok';
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            status := sqlerrm;
    END del_clothes;

    PROCEDURE update_clothes (
        status    OUT       VARCHAR2,
        cloid     IN        clothes.clothes_id%TYPE,
        newname   IN        clothes.clothes_name%TYPE
    ) IS
        PRAGMA autonomous_transaction;
    BEGIN
        UPDATE clothes
        SET
            clothes.clothes_name = newname
        WHERE
            clothes.clothes_id = cloid;

        COMMIT;
        status := 'ok';
    EXCEPTION
        WHEN OTHERS THEN
            status := sqlerrm;
    END update_clothes;

    FUNCTION get_user_clothes (
        cloautor   IN         clothes.user_info_user_login%TYPE
    ) RETURN clothes_table
        PIPELINED
    IS
    BEGIN
        FOR curr IN (
            SELECT DISTINCT
                clothes_id,
                clothes_name
            FROM
                clothes
            WHERE
                clothes.user_info_user_login = cloautor
        ) LOOP
            PIPE ROW ( curr );
        END LOOP;
    END get_user_clothes;

END clothes_package;