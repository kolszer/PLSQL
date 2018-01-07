--Krzysztof Olszer 219090


CREATE OR REPLACE PACKAGE pakiet AS 
   FUNCTION stworzkonto(p_id pracownik.id%TYPE, p_haslo VARCHAR) RETURN konto.id%TYPE;
   FUNCTION wartoscprod(p_id magazyn.id%TYPE) RETURN NUMBER;
   FUNCTION najdrozszyprod(p_id magazyn.id%TYPE) RETURN produkt.id%TYPE;
   FUNCTION wyplatamiesiac(p_id oddzial.id%TYPE, p_rok INT) RETURN NUMBER;
   FUNCTION wyplatamiesiac(p_id oddzial.id%TYPE, p_rok VARCHAR) RETURN NUMBER;
   FUNCTION kosztproduktow(p_id dostawa.id%TYPE) RETURN NUMBER;
   PROCEDURE premiaoddzial (p_nazwa oddzial.nazwa%TYPE, p_miejscowosc kontakt.miejscowosc%TYPE, p_premia NUMBER);
   PROCEDURE zalegleplatnosci;
   PROCEDURE klientrabat (p_rabat NUMBER, p_suma NUMBER);
   PROCEDURE znajdzprodukt (p_id produkt.id%TYPE);
   PROCEDURE zamowieniaklient(p_id klient.id%TYPE);
END pakiet; 
/

CREATE OR REPLACE PACKAGE BODY pakiet AS 

FUNCTION stworzkonto(p_id pracownik.id%TYPE, p_haslo VARCHAR)
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

FUNCTION wartoscprod(p_id magazyn.id%TYPE) 
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

FUNCTION najdrozszyprod(p_id magazyn.id%TYPE) 
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

FUNCTION wyplatamiesiac(p_id oddzial.id%TYPE, p_rok INT) 
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

FUNCTION wyplatamiesiac(p_id oddzial.id%TYPE, p_rok VARCHAR) 
RETURN NUMBER IS
    v_suma NUMBER;
    v_rok INT;
BEGIN 
    v_rok := to_number(p_rok);
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

FUNCTION kosztproduktow(p_id dostawa.id%TYPE) 
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

PROCEDURE premiaoddzial (p_nazwa oddzial.nazwa%TYPE, p_miejscowosc kontakt.miejscowosc%TYPE, p_premia NUMBER) IS
    v_id oddzial.id%TYPE;
    v_miejsc kontakt.miejscowosc%TYPE;
BEGIN
    SELECT id INTO v_id FROM oddzial WHERE nazwa=p_nazwa;
    FOR v_rekord IN (SELECT * FROM pracownik WHERE oddzial_id=v_id)
    LOOP
        SELECT miejscowosc INTO v_miejsc FROM kontakt WHERE id = v_rekord.kontakt_id;
        IF v_miejsc = p_miejscowosc THEN
            UPDATE pracownik SET pensja = (v_rekord.pensja+(v_rekord.pensja*(p_premia/100))) WHERE id=v_rekord.id; 
        END IF;
    END LOOP;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Brak danych o podanym id');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Blad');
END;

PROCEDURE zalegleplatnosci IS
    v_suma NUMBER;
    v_roznica NUMBER;
    v_ilosc INT;
BEGIN
    FOR v_faktura IN (SELECT * FROM faktura)
    LOOP
        SELECT count(*) INTO v_ilosc FROM platnosc WHERE faktura_id=v_faktura.id;
        IF v_ilosc>0 THEN
            SELECT sum(kwota) INTO v_suma FROM platnosc GROUP BY faktura_id HAVING faktura_id=v_faktura.id;
            v_roznica := v_faktura.kwota-v_suma;
            IF v_roznica>0 THEN
                DBMS_OUTPUT.PUT_LINE('Faktura nr: '||v_faktura.numer_faktury||', brakuje: '||v_roznica);
            END IF;
        END IF;
    END LOOP;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Brak danych o podanym id');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Blad');
END;

PROCEDURE klientrabat (p_rabat NUMBER, p_suma NUMBER) IS
    CURSOR cur_klient IS
        SELECT sum(faktura.kwota), klient.id FROM zamowienie 
        INNER JOIN klient ON klient.id=zamowienie.klient_id 
        INNER JOIN faktura ON zamowienie.id=faktura.zamowienie_id 
        GROUP BY klient.id
        HAVING sum(faktura.kwota)>p_suma;
BEGIN
    FOR v_rekord IN cur_klient LOOP
        UPDATE klient SET rabat=rabat+p_rabat WHERE id = v_rekord.id;
    END LOOP;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Brak danych o podanym id');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Blad');
END;

PROCEDURE znajdzprodukt (p_id produkt.id%TYPE) IS
    CURSOR cur_produkt IS
        SELECT 
            kontener.KONTENER KONTENER,
            sektor.MAGAZYN_ID MAGAZYN_ID,
            sektor.SEKTOR SEKTOR,
            magazyn.ODDZIAL_ID ODDZIAL_ID 
        FROM kontener 
        INNER JOIN sektor ON sektor.id = kontener.sektor_id 
        INNER JOIN magazyn ON magazyn.id = sektor.magazyn_id
        WHERE kontener.produkt_id=p_id;
    v_nazwa produkt.nazwa%TYPE;
BEGIN
    SELECT nazwa INTO v_nazwa FROM produkt WHERE id=p_id;
    FOR v_rekord IN cur_produkt LOOP
        DBMS_OUTPUT.PUT_LINE('Produkt '||v_nazwa||' o id '||p_id||' znajduje sie w oddziale '
        ||v_rekord.ODDZIAL_ID||', w magazynie '||v_rekord.MAGAZYN_ID||', w sektorze '||v_rekord.SEKTOR||', w kontenerze '||v_rekord.KONTENER);
    END LOOP;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Brak danych o podanym id');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Blad');
END;

PROCEDURE zamowieniaklient(p_id klient.id%TYPE) IS
    v_suma NUMBER;
    CURSOR cur_faktura IS 
        SELECT 
            faktura.id id,
            faktura.numer_faktury numer_faktury,
            faktura.kwota kwota
        FROM faktura
        INNER JOIN zamowienie ON zamowienie.id = faktura.zamowienie_id
        WHERE zamowienie.klient_id=p_id;
BEGIN 
    DBMS_OUTPUT.PUT_LINE('Faktura i platnosci klienta od numerze id: '||p_id);
    FOR v_faktura IN cur_faktura LOOP
        SELECT sum(kwota) INTO v_suma FROM platnosc WHERE faktura_id = v_faktura.id;
        DBMS_OUTPUT.PUT_LINE('Numer faktury: '||v_faktura.numer_faktury||', kwota faktury: '||v_faktura.kwota||', suma platnosci: '||v_suma);
    END LOOP;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Brak danych o podanym id');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Blad');
END;

END pakiet;
/


--Sprawdzenie dzialania
BEGIN
    DBMS_OUTPUT.PUT_LINE('stworzkonto '||pakiet.stworzkonto(4,'haslo'));--Dziala tylko przy 1 uruchomnieiu, poniewaz po 2 uruchomiueniu beda 2 loginy takie same(check)
    DBMS_OUTPUT.PUT_LINE('wartoscprod '||pakiet.wartoscprod(1));
    DBMS_OUTPUT.PUT_LINE('najdrozszyprod '||pakiet.najdrozszyprod(1));
    DBMS_OUTPUT.PUT_LINE('wyplatamiesiac(int,int) '||pakiet.wyplatamiesiac(1,2010));
    DBMS_OUTPUT.PUT_LINE('wyplatamiesiac(int,string) '||pakiet.wyplatamiesiac(1,'2010'));
    DBMS_OUTPUT.PUT_LINE('kosztproduktow '||pakiet.kosztproduktow(1));
    DBMS_OUTPUT.PUT_LINE('premiaoddzial ');
    pakiet.premiaoddzial('Oddzial1','Miejscowosc2',10);
    DBMS_OUTPUT.PUT_LINE('zalegleplatnosci ');
    pakiet.zalegleplatnosci;
    DBMS_OUTPUT.PUT_LINE('klientrabat');
    pakiet.klientrabat(10,3000);
    DBMS_OUTPUT.PUT_LINE('znajdzprodukt');
    pakiet.znajdzprodukt(1);
    DBMS_OUTPUT.PUT_LINE('zamowieniaklient');
    pakiet.zamowieniaklient(1);
END;
/