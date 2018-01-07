CREATE OR REPLACE FUNCTION loguj (p_username konto.login%TYPE, p_password konto.haslo%TYPE)
RETURN BOOLEAN IS
    v_haslo konto.haslo%TYPE;
    v_haslotab konto.haslo%TYPE;
BEGIN
    SELECT standard_hash(p_password) INTO v_haslo FROM dual;
    SELECT haslo INTO v_haslotab FROM konto WHERE UPPER(login) = UPPER(p_username);
    IF v_haslo = v_haslotab THEN
        RETURN TRUE;
    END IF;
    RETURN FALSE;
END;
/


INSERT INTO konto VALUES (null,'admin',standard_hash('admin'));
INSERT INTO pracownik VALUES (null,'asdad','adasdasd',3333,TO_DATE('2000/05/03', 'yyyy/mm/dd'),1,7,34);
INSERT INTO konto VALUES (null,'userr',standard_hash('userr'));

SELECT 1 FROM konto 
WHERE UPPER(login)=:APP_USER AND id IN (SELECT konto_id FROM pracownik);
select * from konto;