CREATE OR REPLACE TRIGGER pstgr_xpal_loyalty_voyage
    AFTER DELETE OR INSERT OR UPDATE
    ON XPAL
    REFERENCING NEW AS New OLD AS Old
    FOR EACH ROW
DECLARE
    l_xpda_shortdesc xpda.xpda_shortdesc%TYPE;
    l_exists PLS_INTEGER;
    l_log_id xcom.xcom_id%TYPE;
    l_xpac_id xpac.xpac_id%TYPE;
BEGIN
    -- -------------------------------------------------------------------------- --
    -- REVISIONS:
    -- -------------------------------------------------------------------------- --
    --  Ver        Date         Author           Description
    --  ---------  -----------  ---------------  ----------------------------------
    --  1.1        22 SEP 2022  KCELIK          2. Deleted action added,
    --                                          3. XPAC shortdesc VCR
    --  1.0        07 SEP 2022  KCELIK          1. Created this trigger.
    -- -------------------------------------------------------------------------- --
    SELECT xpac_id
    INTO l_xpac_id
    FROM xpac
    WHERE xpac_shortdesc = 'VCR';

    IF INSERTING OR UPDATING THEN
        IF :new.xpal_xpac_id = l_xpac_id THEN
            SELECT xpda_shortdesc
            INTO l_xpda_shortdesc
            FROM xpda
            WHERE xpda_id = :new.xpal_xpda_id;

            SELECT COUNT ( *)
            INTO l_exists
            FROM xcom
            WHERE xcom_xcmt_id = 6 AND xcom_primary = 1 AND xcom_xcms_id = :new.xpal_xcms_id;

            --SELECT xcom_value FROM xcom where xcom_xcmt_id = 6 and  xcom_primary = 1 and xcom_xcms_id = ;
            IF l_exists > 0 THEN
                UPDATE xcom
                SET xcom_value = l_xpda_shortdesc
                WHERE xcom_xcmt_id = 6 AND xcom_primary = 1 AND xcom_xcms_id = :new.xpal_xcms_id;
            ELSE
                SELECT seq_xcom.NEXTVAL INTO l_log_id FROM DUAL;

                INSERT INTO xcom (
                                  xcom_id
                                , xcom_xcmt_id
                                , xcom_primary
                                , xcom_xcms_id
                                , xcom_value
                                 )
                VALUES (
                        l_log_id
                      , 6
                      , 1
                      , :new.xpal_xcms_id
                      , l_xpda_shortdesc
                       );
            END IF;
        END IF;
    END IF;
    -- Constraint XCOM_Value is not null
    IF DELETING THEN
        IF :old.xpal_xpac_id = l_xpac_id THEN
            DELETE FROM xcom
            WHERE xcom_xcmt_id = 6 AND xcom_primary = 1 AND xcom_xcms_id = :old.xpal_xcms_id;
        END IF;
    END IF;
END;
/