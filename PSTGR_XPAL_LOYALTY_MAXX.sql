CREATE OR REPLACE TRIGGER pstgr_xpal_loyalty_maxx
    AFTER DELETE OR INSERT OR UPDATE
    ON XPAL
    REFERENCING NEW AS New OLD AS Old
    FOR EACH ROW
DECLARE
    l_xpda_shortdesc xpda.xpda_shortdesc%TYPE;
    l_xpac_id xpac.xpac_id%TYPE;
BEGIN
    -- -------------------------------------------------------------------------- --
    -- REVISIONS:
    -- -------------------------------------------------------------------------- --
    --  Ver        Date         Author           Description
    --  ---------  -----------  ---------------  ------------------------------  
    --  1.1        22 SEP 2022  KCELIK          2. XPAC shortdesc CRD    
    --  1.0        07 SEP 2022  KCELIK          1. Created this trigger.
    -- -------------------------------------------------------------------------- --
    SELECT xpac_id
    INTO l_xpac_id
    FROM xpac
    WHERE xpac_shortdesc = 'CRD';


    IF INSERTING OR UPDATING THEN
        IF :new.xpal_xpac_id = l_xpac_id THEN
            SELECT xpda_shortdesc
            INTO l_xpda_shortdesc
            FROM xpda
            WHERE xpda_id = :new.xpal_xpda_id;

            UPDATE XCID
            SET XCID_TITLE = l_xpda_shortdesc
            WHERE xcid_id = :new.xpal_xcms_id;
        END IF;
    END IF;

    IF DELETING THEN
        IF :old.xpal_xpac_id = l_xpac_id THEN
            UPDATE XCID
            SET XCID_TITLE = NULL
            WHERE xcid_id = :old.xpal_xcms_id;
        END IF;
    END IF;
 EXCEPTION WHEN OTHERS THEN NULL;
END;
/
