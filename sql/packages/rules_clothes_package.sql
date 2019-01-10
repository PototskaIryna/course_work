CREATE OR REPLACE PACKAGE rule_clothes_package IS
    PROCEDURE add_rule_clothes (
        status    OUT       VARCHAR2,
        firstid   IN        rules_have_clothes.clothes_clothes_id%TYPE,
        lastid    IN        rules_have_clothes.clothes_rules_rule_id%TYPE
    );

    PROCEDURE del_rule_clothes (
        status   OUT      VARCHAR2,
        ruleid   IN       rules_have_clothes.clothes_rules_rule_id%TYPE
    );

END rule_clothes_package;
/

CREATE OR REPLACE PACKAGE BODY rule_clothes_package IS

    PROCEDURE add_rule_clothes (
        status    OUT       VARCHAR2,
        firstid   IN        rules_have_clothes.clothes_clothes_id%TYPE,
        lastid    IN        rules_have_clothes.clothes_rules_rule_id%TYPE
    ) IS
        PRAGMA autonomous_transaction;
    BEGIN
        INSERT INTO rules_have_clothes (
            clothes_clothes_id,
            clothes_rules_rule_id
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
    END add_rule_clothes;

    PROCEDURE del_rule_clothes (
        status   OUT      VARCHAR2,
        ruleid   IN       rules_have_clothes.clothes_rules_rule_id%TYPE
    ) IS
        PRAGMA autonomous_transaction;
    BEGIN
        DELETE FROM rules_have_clothes
        WHERE
            rules_have_clothes.clothes_rules_rule_id = ruleid;

        COMMIT;
        status := 'ok';
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            status := sqlerrm;
    END del_rule_clothes;

END rule_clothes_package;