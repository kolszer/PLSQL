--Krzysztof Olszer 219090

--Funkcja STWORZKONTO tworzy konto dla pracownika
--p_id: id pracownika
--p_haslo: jawnie podane haslo pracownika
--Dzialanie: funkcja dodaje login zlozony z 1 litery imienia + nazwisko
--oraz haslo, ktore jest skrotem MD5 do tabeli konto
--Return: id dodanego konta
CREATE OR REPLACE FUNCTION stworzkonto(p_id pracownik.id%TYPE, p_haslo VARCHAR)
RETURN konto.id%TYPE IS
    v_login konto.login%TYPE;
    v_haslo konto.haslo%TYPE;
    v_pracw pracownik%ROWTYPE;
    v_id konto.id%TYPE;
BEGIN
    SELECT * INTO v_pracw FROM pracownik WHERE id=p_id;
    SELECT standard_hash(p_haslo) INTO v_haslo FROM dual;
    v_login := SUBSTR(v_pracw.imie, 1, 1)||v_pracw.nazwisko;
    SELECT konto_id_seq.nextval INTO v_id FROM dual;
    INSERT INTO konto VALUES (v_id,v_login,v_haslo);
    RETURN v_id;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Powtorzona wartosc id lub login w tabeli konto');
        RETURN NULL;
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Brak pracownika o podanym id');
        RETURN NULL;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Blad');
        RETURN NULL;
END;
/


--Funkcja zwracajaca wartosc wszystkich produktow w danym magazynie
--p_id: id magazynu
--return: wartosc produktow w magazynie
CREATE OR REPLACE FUNCTION wartoscprod(p_id magazyn.id%TYPE) 
RETURN NUMBER IS
    v_wartosc NUMBER;
BEGIN 
    SELECT sum(produkt.ilosc*produkt.cena) INTO v_wartosc FROM kontener 
    INNER JOIN produkt ON kontener.produkt_id=produkt.id
    INNER JOIN sektor ON kontener.sektor_id=sektor.id
    INNER JOIN magazyn ON sektor.magazyn_id=magazyn.id
    WHERE magazyn.id=p_id;
    RETURN v_wartosc;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Blad');
        RETURN NULL;
END;
/


--Funkcja zwracajaca id najdrozszego produktu w magazynie
--p_id: id magazynu
--return: id produktu
CREATE OR REPLACE FUNCTION najdrozszyprod(p_id magazyn.id%TYPE) 
RETURN produkt.id%TYPE IS
    v_id produkt.id%TYPE;
BEGIN 
    SELECT produkt.id INTO v_id FROM kontener 
    INNER JOIN produkt ON kontener.produkt_id=produkt.id
    INNER JOIN sektor ON kontener.sektor_id=sektor.id
    INNER JOIN magazyn ON sektor.magazyn_id=magazyn.id
    WHERE magazyn.id=p_id AND produkt.cena=(SELECT max(cena) FROM produkt);
    RETURN v_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Brak danych o podanym id');
        RETURN NULL;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Blad');
        RETURN NULL;
END;
/


--Funkcja zwracajaca sume wyplat w danym roku w danym oddziale
--p_id: id magazynu
CREATE OR REPLACE FUNCTION wyplatamiesiac(p_id oddzial.id%TYPE, p_rok INT) 
RETURN NUMBER IS
    v_suma NUMBER;
BEGIN 
    SELECT sum(kwota) INTO v_suma FROM wyplata
    INNER JOIN pracownik ON wyplata.pracownik_id=pracownik.id
    WHERE pracownik.oddzial_id=p_id AND extract(year from data_przelewu)=p_rok;
    RETURN v_suma;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Brak danych o podanym id');
        RETURN NULL;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Blad');
        RETURN NULL;
END;
/


--Funkcja zwracajaca sume kosztow produktow
--p_id: id dostawy
CREATE OR REPLACE FUNCTION kosztproduktow(p_id dostawa.id%TYPE) 
RETURN NUMBER IS
    v_suma NUMBER;
BEGIN 
    SELECT sum(produkt.cena*dostawaprodukt.ilosc) INTO v_suma FROM dostawaprodukt
    INNER JOIN produkt ON dostawaprodukt.produkt_id=produkt.id
    WHERE dostawa_id=p_id;
    RETURN v_suma;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Brak danych o podanym id');
        RETURN NULL;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Blad');
        RETURN NULL;
END;
/

--Sprawdzenie dzialania
BEGIN
    DBMS_OUTPUT.PUT_LINE('stworzkonto '||stworzkonto(3,'haslo'));--Dziala tylko przy 1 uruchomnieiu, poniewaz po 2 uruchomiueniu beda 2 loginy takie same(check)
    DBMS_OUTPUT.PUT_LINE('wartoscprod '||wartoscprod(1));
    DBMS_OUTPUT.PUT_LINE('najdrozszyprod '||najdrozszyprod(1));
    DBMS_OUTPUT.PUT_LINE('wyplatamiesiac '||wyplatamiesiac(1,2010));
    DBMS_OUTPUT.PUT_LINE('kosztproduktow '||kosztproduktow(1));
END;
/
