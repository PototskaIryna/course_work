CREATE OR REPLACE VIEW rule_view AS
    SELECT
        rule_id,
        rule_name,
        user_info_user_login
    FROM
        clothes_rules
    WHERE
        clothes_rules.rule_deleted IS NULL;

CREATE OR REPLACE TRIGGER trg_delete_rule INSTEAD OF
    DELETE ON rule_view
    FOR EACH ROW
DECLARE
    PRAGMA autonomous_transaction;
BEGIN
    UPDATE clothes_rules
    SET
        clothes_rules.rule_deleted = systimestamp
    WHERE
        clothes_rules.rule_id = :old.rule_id;

    COMMIT;
END;