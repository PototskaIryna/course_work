CREATE OR REPLACE PACKAGE rule_package IS
    TYPE rule_row IS RECORD (
        ruleid clothes_rules.rule_id%TYPE,
        rulename clothes_rules.rule_name%TYPE
    );
    TYPE rule_table IS
        TABLE OF rule_row;
    PROCEDURE add_rule(
        status     OUT        VARCHAR2,
        ruleid      IN         clothes_rules.rule_id%TYPE,
        rulename    IN         clothes_rules.rule_name%TYPE,
        ruleautor   IN         clothes_rules.user_info_user_login%TYPE
    );

    PROCEDURE del_rule (
        status   OUT      VARCHAR2,
        ruleid    IN       clothes_rules.rule_id%TYPE
    );

    PROCEDURE update_rule(
        status    OUT       VARCHAR2,
        ruleid     IN        clothes_rules.rule_id%TYPE,
        rulename   IN        clothes_rules.rule_name%TYPE
    );

    FUNCTION get_user_rule(
        ruleautor   IN         clothes_rules.user_info_user_login%TYPE
    ) RETURN rule_table
        PIPELINED;

END rule_package;
/

CREATE OR REPLACE PACKAGE BODY rule_package IS

    PROCEDURE add_rule(
        status     OUT        VARCHAR2,
        ruleid      IN         clothes_rules.rule_id%TYPE,
        rulename    IN         clothes_rules.rule_name%TYPE,
        ruleautor   IN         clothes_rules.user_info_user_login%TYPE
    ) IS
        PRAGMA autonomous_transaction;
    BEGIN
        INSERT INTO clothes_rules (
            rule_id,
            rule_name,
            user_info_user_login
        ) VALUES (
            ruleid,
            rulename,
            ruleautor
        );

        COMMIT;
        status := 'ok';
    EXCEPTION
        WHEN dup_val_on_index THEN
            status := 'Такий id уже існує';
        WHEN OTHERS THEN
            status := sqlerrm;
    END add_rule;

    PROCEDURE del_rule (
        status   OUT      VARCHAR2,
        ruleid    IN       clothes_rules.rule_id%TYPE
    ) IS
        PRAGMA autonomous_transaction;
    BEGIN
        DELETE FROM rule_view
        WHERE
            rule_view.rule_id = ruleid;

        COMMIT;
        status := 'ok';
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            status := sqlerrm;
    END del_rule;

    PROCEDURE update_rule(
        status    OUT       VARCHAR2,
        ruleid     IN        clothes_rules.rule_id%TYPE,
        rulename   IN        clothes_rules.rule_name%TYPE
    ) IS
        PRAGMA autonomous_transaction;
    BEGIN
        UPDATE clothes_rules
        SET
            clothes_rules.rule_name = rulename
        WHERE
            clothes_rules.rule_id = ruleid;

        COMMIT;
        status := 'ok';
    EXCEPTION
        WHEN OTHERS THEN
            status := sqlerrm;
    END update_rule;

    FUNCTION get_user_rule (
        ruleautor   IN         clothes_rules.user_info_user_login%TYPE
    ) RETURN rule_table
        PIPELINED
    IS
    BEGIN
        FOR curr IN (
            SELECT DISTINCT
                rule_id,
                rule_name
            FROM
                clothes_rules
            WHERE
                clothes_rules.user_info_user_login = ruleautor
        ) LOOP
            PIPE ROW ( curr );
        END LOOP;
    END get_user_rule;

END rule_package;