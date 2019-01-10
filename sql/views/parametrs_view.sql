CREATE OR REPLACE VIEW parametrs_view AS
    SELECT
        param_id,
        param_name,
        user_info_user_login
    FROM
        parametrs
    WHERE
        parametrs.param_deleted IS NULL;

CREATE OR REPLACE TRIGGER trg_delete_parametrs INSTEAD OF
    DELETE ON parametrs_view
    FOR EACH ROW
DECLARE
    PRAGMA autonomous_transaction;
BEGIN
    UPDATE parametrs
    SET
        parametrs.param_deleted = systimestamp
    WHERE
        parametrs.param_id = :old.param_id;
    COMMIT;
END;