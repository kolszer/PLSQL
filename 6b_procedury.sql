--Krzysztof Olszer 219090

--Procedura dodaje premie dla wszystkich pracownikow pracujacych w danym oddziale i mieszkajacych w danej miejscowosci
--p_nazwa: nazwa oddzialu
--p_miejscowosc: miejscowosc pracownika
--p_premia: procentowa wartosc premii
CREATE OR REPLACE PROCEDURE premiaoddzial (p_nazwa oddzial.nazwa%TYPE, p_miejscowosc kontakt.miejscowosc%TYPE, p_premia NUMBER) IS
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
/



--Procedura wypisuje numery faktur i brakujace kwoty zaleglych platnosci
CREATE OR REPLACE PROCEDURE zalegleplatnosci IS
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
/


--Procedura dodaje rabat klientom, ktorzy zakupili produkty z odpowiednia suma
--p_rabat: rabat, ktory zostanie dodany
--p_suma: warunek dla jakiej sumy klienci otrzymaja rabat
CREATE OR REPLACE PROCEDURE klientrabat (p_rabat NUMBER, p_suma NUMBER) IS
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
/


--Procedura wypisuje w ktorym oddziale, magazynie, ktorym sektorze i w ktorym kontenerze znajduje sie dany produkt
--p_id: id produktu ktorego szukamy
CREATE OR REPLACE PROCEDURE znajdzprodukt (p_id produkt.id%TYPE) IS
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
/


--Procedura wyswietlajaca faktury klienta i sprawdzajaca czy te faktury zostaly oplacone
--p_id: id klienta
CREATE OR REPLACE PROCEDURE zamowieniaklient(p_id klient.id%TYPE) IS
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
/

--Sprawdzenie dzialania
BEGIN
    DBMS_OUTPUT.PUT_LINE('premiaoddzial ');
    premiaoddzial('Oddzial1','Miejscowosc2',10);
    DBMS_OUTPUT.PUT_LINE('zalegleplatnosci ');
    zalegleplatnosci;
    DBMS_OUTPUT.PUT_LINE('klientrabat');
    klientrabat(10,3000);
    DBMS_OUTPUT.PUT_LINE('znajdzprodukt');
    znajdzprodukt(1);
    DBMS_OUTPUT.PUT_LINE('zamowieniaklient');
    zamowieniaklient(1);
END;
/