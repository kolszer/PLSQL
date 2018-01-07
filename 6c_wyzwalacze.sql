--Krzysztof Olszer 219090

--Wyzwalacz sprawdza czy ilosc nie jest wieksza niz ilosc produktow w tab. produkt.
--Jesli ilosc sie zgadza to odejmuje od ilosci produktow w tab. produkt.
CREATE OR REPLACE TRIGGER dostawaprod_ilosc_trg
AFTER INSERT ON dostawaprodukt FOR EACH ROW
DECLARE
    v_ilosc dostawaprodukt.ilosc%TYPE; 
BEGIN
    SELECT ilosc INTO v_ilosc FROM produkt WHERE id=:new.produkt_id;
    IF v_ilosc > :new.ilosc THEN
        UPDATE produkt SET ilosc=ilosc-:new.ilosc WHERE id=:new.produkt_id;
    ELSE
        RAISE_APPLICATION_ERROR(-20500,'Podana jest zbyt duza ilosc');
    END IF;
END;
/

--Wyzwalacz sprawdza czy podany koszt zgadza sie z iloscia * cena
CREATE OR REPLACE TRIGGER dostawa_koszt_trg
AFTER INSERT ON dostawa FOR EACH ROW
DECLARE
    v_koszt dostawa.koszt_produktow%TYPE; 
BEGIN
    SELECT sum(dostawaprodukt.ilosc*produkt.cena) INTO v_koszt FROM dostawaprodukt
    INNER JOIN produkt ON dostawaprodukt.id = produkt.id
    WHERE dostawaprodukt.id=:new.id;
    IF v_koszt <> :new.koszt_produktow THEN
        RAISE_APPLICATION_ERROR(-20500,'Podany jest zly koszt produtkow');
    END IF;
END;
/

--Wyzwalacz sprawdza czy kwota nie bedzie przekraczala sumy platnosci - kwoty faktury
CREATE OR REPLACE TRIGGER platnosc_kwota_trg
AFTER INSERT ON platnosc FOR EACH ROW
DECLARE
    v_suma platnosc.kwota%TYPE;
    v_kwota faktura.kwota%TYPE;
BEGIN
    SELECT sum(kwota) INTO v_suma FROM platnosc WHERE faktura_id = :new.faktura_id;
    SELECT kwota INTO v_kwota FROM faktura WHERE id = :new.faktura_id;
    IF v_kwota < v_suma+:new.kwota THEN
        RAISE_APPLICATION_ERROR(-20500,'Podany jest zly koszt produtkow');
    END IF;
END;
/

--Wyzwalacz sprawdza czy podana kwota jest < pensji
CREATE OR REPLACE TRIGGER wyplata_kwota_trg
AFTER INSERT ON wyplata FOR EACH ROW
DECLARE
    v_pensja pracownik.pensja%TYPE;
BEGIN
    SELECT pensja INTO v_pensja FROM pracownik WHERE id = :new.pracownik_id;
    IF v_pensja > :new.kwota THEN
        RAISE_APPLICATION_ERROR(-20500,'Podana kwota jest mniejsza od pensji');
    END IF;
END;
/

--Wyzwalacz sprawdza czy pracownik ma ukonczone 15 lat
CREATE OR REPLACE TRIGGER pracownik_dataur_trg
AFTER INSERT ON pracownik FOR EACH ROW
DECLARE
    v_wiek NUMBER;
BEGIN
    v_wiek := to_number(TO_CHAR(SYSDATE, 'yyyy'))-to_number(to_char(:new.data_ur, 'yyyy'));
    IF v_wiek < 15 THEN
        RAISE_APPLICATION_ERROR(-20500,'Pracownik ma mniej niz 16 lat');
    END IF;
END;
/