CREATE OR REPLACE VIEW clothes_view AS
    SELECT
        clothes_id,
        clothes_name,
        user_info_user_login
    FROM
        clothes
    WHERE
        clothes.clothes_deleted IS NULL;

CREATE OR REPLACE TRIGGER trg_delete_clothes INSTEAD OF
    DELETE ON clothes_view
    FOR EACH ROW
DECLARE
    PRAGMA autonomous_transaction;
BEGIN
    UPDATE clothes
    SET
        clothes.clothes_deleted = systimestamp
    WHERE
        clothes.clothes_id = :old.clothes_id;

    COMMIT;
END;