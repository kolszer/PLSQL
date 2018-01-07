--Krzysztof Olszer 219090



CREATE TABLE dostawa (
    id                INTEGER NOT NULL,
    dostawca_id       INTEGER NOT NULL,
    oddzial_id        INTEGER NOT NULL,
    data              DATE NOT NULL,
    koszt_dostawy     NUMBER(8,2) NOT NULL,
    koszt_produktow   NUMBER(8,2) NOT NULL
);

COMMENT ON TABLE dostawa IS
    'Tabela';

ALTER TABLE dostawa ADD CONSTRAINT dostawa_ck_1 CHECK ( koszt_dostawy >= 0 );

ALTER TABLE dostawa ADD CONSTRAINT dostawa_ck_2 CHECK ( koszt_produktow >= 0 );

ALTER TABLE dostawa ADD CONSTRAINT dostawa_pk PRIMARY KEY ( id );

CREATE TABLE dostawaprodukt (
    id           INTEGER NOT NULL,
    dostawa_id   INTEGER NOT NULL,
    produkt_id   INTEGER NOT NULL,
    ilosc        NUMBER(12,2) NOT NULL
);

COMMENT ON TABLE dostawaprodukt IS
    'Tabela';

ALTER TABLE dostawaprodukt ADD CONSTRAINT dostawaprodukt_ck_1 CHECK ( ilosc > 0 );

ALTER TABLE dostawaprodukt ADD CONSTRAINT dostawaprodukt_pk PRIMARY KEY ( id );

CREATE TABLE dostawca (
    id           INTEGER NOT NULL,
    kontakt_id   INTEGER NOT NULL,
    nazwa        VARCHAR2(40 CHAR) NOT NULL
);

COMMENT ON TABLE dostawca IS
    'Tabela';

ALTER TABLE dostawca ADD CONSTRAINT dostawca_pk PRIMARY KEY ( id );

ALTER TABLE dostawca ADD CONSTRAINT dostawca__un UNIQUE ( kontakt_id );

CREATE TABLE faktura (
    id              INTEGER NOT NULL,
    numer_faktury   VARCHAR2(30 CHAR) NOT NULL,
    kwota           NUMBER(8,2) NOT NULL,
    zamowienie_id   INTEGER NOT NULL
);

COMMENT ON TABLE faktura IS
    'Tabela';

ALTER TABLE faktura ADD CONSTRAINT faktura_ck_1 CHECK ( kwota > 0 );

ALTER TABLE faktura ADD CONSTRAINT faktura_pk PRIMARY KEY ( id );

ALTER TABLE faktura ADD CONSTRAINT faktura__un UNIQUE ( numer_faktury );

CREATE TABLE kategoria (
    id          INTEGER NOT NULL,
    kategoria   VARCHAR2(50 CHAR) NOT NULL
);

COMMENT ON TABLE kategoria IS
    'Tabela';

ALTER TABLE kategoria ADD CONSTRAINT kategoria_pk PRIMARY KEY ( id );

ALTER TABLE kategoria ADD CONSTRAINT kategoria__un UNIQUE ( kategoria );

CREATE TABLE klient (
    id           INTEGER NOT NULL,
    nazwa        VARCHAR2(50) NOT NULL,
    rabat        NUMBER(5,2) NOT NULL,
    kontakt_id   INTEGER NOT NULL,
    konto_id     INTEGER NOT NULL
);

COMMENT ON TABLE klient IS
    'Tabela';

ALTER TABLE klient ADD CONSTRAINT klient_pk PRIMARY KEY ( id );

ALTER TABLE klient ADD CONSTRAINT klient__un UNIQUE ( kontakt_id,
konto_id );

CREATE TABLE kontakt (
    id            INTEGER NOT NULL,
    telefon       VARCHAR2(20 CHAR),
    e_mail        VARCHAR2(30 CHAR),
    ulica         VARCHAR2(50 CHAR),
    nr_domu       VARCHAR2(6 CHAR),
    nr_lokalu     VARCHAR2(6 CHAR),
    miejscowosc   VARCHAR2(50 CHAR),
    kod           VARCHAR2(5 CHAR)
);

COMMENT ON TABLE kontakt IS
    'Tabela';

ALTER TABLE kontakt
    ADD CONSTRAINT kontakt_ck_1 CHECK ( LENGTH(telefon) > 8 );

ALTER TABLE kontakt
    ADD CONSTRAINT kontakt_ck_2 CHECK ( LENGTH(e_mail) > 5 );

ALTER TABLE kontakt
    ADD CONSTRAINT kontakt_ck_3 CHECK ( LENGTH(ulica) > 2 );

ALTER TABLE kontakt ADD CONSTRAINT kontakt_pk PRIMARY KEY ( id );

ALTER TABLE kontakt ADD CONSTRAINT kontakt__un UNIQUE ( telefon,
e_mail );

CREATE TABLE kontener (
    id           INTEGER NOT NULL,
    sektor_id    INTEGER NOT NULL,
    produkt_id   INTEGER NOT NULL,
    kontener     VARCHAR2(20 CHAR) NOT NULL
);

COMMENT ON TABLE kontener IS
    'Tabela';

ALTER TABLE kontener ADD CONSTRAINT kontener_pk PRIMARY KEY ( id );

CREATE TABLE konto (
    id      INTEGER NOT NULL,
    login   VARCHAR2(20 CHAR) NOT NULL,
    haslo   VARCHAR2(40 CHAR) NOT NULL
);

COMMENT ON TABLE konto IS
    'Tabela';

ALTER TABLE konto
    ADD CONSTRAINT konto_ck_1 CHECK ( LENGTH(login) > 4 );

ALTER TABLE konto
    ADD CONSTRAINT konto_ck_2 CHECK ( LENGTH(haslo) = 40 );

ALTER TABLE konto ADD CONSTRAINT konto_pk PRIMARY KEY ( id );

ALTER TABLE konto ADD CONSTRAINT konto__un UNIQUE ( login );

CREATE TABLE magazyn (
    id           INTEGER NOT NULL,
    oddzial_id   INTEGER NOT NULL
);

COMMENT ON TABLE magazyn IS
    'Tabela';

ALTER TABLE magazyn ADD CONSTRAINT magazyn_pk PRIMARY KEY ( id );

CREATE TABLE oddzial (
    id           INTEGER NOT NULL,
    kontakt_id   INTEGER NOT NULL,
    nazwa        VARCHAR2(30 CHAR) NOT NULL
);

COMMENT ON TABLE oddzial IS
    'Tabela';

ALTER TABLE oddzial ADD CONSTRAINT oddzial_pk PRIMARY KEY ( id );

ALTER TABLE oddzial ADD CONSTRAINT oddzial__un UNIQUE ( kontakt_id );

CREATE TABLE platnosc (
    id           INTEGER NOT NULL,
    kwota        NUMBER(8,2),
    rachunek     VARCHAR2(26 CHAR) NOT NULL,
    data         DATE,
    faktura_id   INTEGER NOT NULL
);

COMMENT ON TABLE platnosc IS
    'Tabela';

ALTER TABLE platnosc ADD CONSTRAINT platnosc_ck_1 CHECK ( kwota > 0 );

ALTER TABLE platnosc ADD CONSTRAINT platnosc_pk PRIMARY KEY ( id );

CREATE TABLE pracownik (
    id           INTEGER NOT NULL,
    imie         VARCHAR2(50 CHAR) NOT NULL,
    nazwisko     VARCHAR2(100 CHAR) NOT NULL,
    pensja       NUMBER(8,2) NOT NULL,
    data_ur      DATE NOT NULL,
    oddzial_id   INTEGER NOT NULL,
    kontakt_id   INTEGER NOT NULL,
    konto_id     INTEGER NOT NULL
);

COMMENT ON TABLE pracownik IS
    'Tabela';

ALTER TABLE pracownik
    ADD CONSTRAINT pracownik_ck_1 CHECK ( LENGTH(imie) > 2 );

ALTER TABLE pracownik
    ADD CONSTRAINT pracownik_ck_2 CHECK ( LENGTH(nazwisko) > 2 );

ALTER TABLE pracownik ADD CONSTRAINT pracownik_ck_3 CHECK ( pensja > 999 );

ALTER TABLE pracownik ADD CONSTRAINT pracownik_pk PRIMARY KEY ( id );

ALTER TABLE pracownik ADD CONSTRAINT pracownik__unv1 UNIQUE ( kontakt_id,
konto_id );

CREATE TABLE producent (
    id           INTEGER NOT NULL,
    kontakt_id   INTEGER NOT NULL,
    nazwa        VARCHAR2(30 CHAR) NOT NULL
);

COMMENT ON TABLE producent IS
    'Tabela';

ALTER TABLE producent ADD CONSTRAINT producent_pk PRIMARY KEY ( id );

ALTER TABLE producent ADD CONSTRAINT producent__un UNIQUE ( kontakt_id );

CREATE TABLE produkt (
    id             INTEGER NOT NULL,
    nazwa          VARCHAR2(50 CHAR) NOT NULL,
    ilosc          NUMBER(14,2) NOT NULL,
    cena           NUMBER(8,2) NOT NULL,
    kategoria_id   INTEGER NOT NULL,
    producent_id   INTEGER NOT NULL
);

COMMENT ON TABLE produkt IS
    'Tabela';

ALTER TABLE produkt ADD CONSTRAINT produkt_ck_1 CHECK ( cena >= 0 );

ALTER TABLE produkt ADD CONSTRAINT produkt_pk PRIMARY KEY ( id );

CREATE TABLE sektor (
    id           INTEGER NOT NULL,
    magazyn_id   INTEGER NOT NULL,
    sektor       VARCHAR2(20 CHAR) NOT NULL
);

COMMENT ON TABLE sektor IS
    'Tabela';

ALTER TABLE sektor ADD CONSTRAINT sektor_pk PRIMARY KEY ( id );

CREATE TABLE sprzet (
    id             INTEGER NOT NULL,
    nazwa          VARCHAR2(50 CHAR) NOT NULL,
    data_serwisu   DATE,
    oddzial_id     INTEGER NOT NULL
);

COMMENT ON TABLE sprzet IS
    'Tabela';

ALTER TABLE sprzet ADD CONSTRAINT sprzet_pk PRIMARY KEY ( id );

CREATE TABLE wyplata (
    id              INTEGER NOT NULL,
    data_przelewu   DATE NOT NULL,
    kwota           NUMBER(8,2) NOT NULL,
    pracownik_id    INTEGER NOT NULL
);

COMMENT ON TABLE wyplata IS
    'Tabela';

ALTER TABLE wyplata ADD CONSTRAINT wyplata_ck_1 CHECK ( kwota >= 0 );

ALTER TABLE wyplata ADD CONSTRAINT wyplata_pk PRIMARY KEY ( id );

CREATE TABLE zamowienie (
    id          INTEGER NOT NULL,
    klient_id   INTEGER NOT NULL
);

COMMENT ON TABLE zamowienie IS
    'Tabela';

ALTER TABLE zamowienie ADD CONSTRAINT zamowienie_pk PRIMARY KEY ( id );

CREATE TABLE zamowienieprod (
    id              INTEGER NOT NULL,
    produkt_id      INTEGER NOT NULL,
    zamowienie_id   INTEGER NOT NULL
);

COMMENT ON TABLE zamowienieprod IS
    'Tabela';

ALTER TABLE zamowienieprod ADD CONSTRAINT zamowienieprod_pk PRIMARY KEY ( id );

ALTER TABLE dostawa
    ADD CONSTRAINT dostawa_dostawca_fk FOREIGN KEY ( dostawca_id )
        REFERENCES dostawca ( id );

ALTER TABLE dostawa
    ADD CONSTRAINT dostawa_oddzial_fk FOREIGN KEY ( oddzial_id )
        REFERENCES oddzial ( id );

ALTER TABLE dostawaprodukt
    ADD CONSTRAINT dostawaprodukt_dostawa_fk FOREIGN KEY ( dostawa_id )
        REFERENCES dostawa ( id );

ALTER TABLE dostawaprodukt
    ADD CONSTRAINT dostawaprodukt_produkt_fk FOREIGN KEY ( produkt_id )
        REFERENCES produkt ( id );

ALTER TABLE dostawca
    ADD CONSTRAINT dostawca_kontakt_fk FOREIGN KEY ( kontakt_id )
        REFERENCES kontakt ( id );

ALTER TABLE faktura
    ADD CONSTRAINT faktura_zamowienie_fk FOREIGN KEY ( zamowienie_id )
        REFERENCES zamowienie ( id );

ALTER TABLE klient
    ADD CONSTRAINT klient_kontakt_fk FOREIGN KEY ( kontakt_id )
        REFERENCES kontakt ( id );

ALTER TABLE klient
    ADD CONSTRAINT klient_konto_fk FOREIGN KEY ( konto_id )
        REFERENCES konto ( id );

ALTER TABLE kontener
    ADD CONSTRAINT kontener_produkt_fk FOREIGN KEY ( produkt_id )
        REFERENCES produkt ( id );

ALTER TABLE kontener
    ADD CONSTRAINT kontener_sektor_fk FOREIGN KEY ( sektor_id )
        REFERENCES sektor ( id );

ALTER TABLE magazyn
    ADD CONSTRAINT magazyn_oddzial_fk FOREIGN KEY ( oddzial_id )
        REFERENCES oddzial ( id );

ALTER TABLE oddzial
    ADD CONSTRAINT oddzial_kontakt_fk FOREIGN KEY ( kontakt_id )
        REFERENCES kontakt ( id );

ALTER TABLE platnosc
    ADD CONSTRAINT platnosc_faktura_fk FOREIGN KEY ( faktura_id )
        REFERENCES faktura ( id );

ALTER TABLE pracownik
    ADD CONSTRAINT pracownik_kontakt_fk FOREIGN KEY ( kontakt_id )
        REFERENCES kontakt ( id );

ALTER TABLE pracownik
    ADD CONSTRAINT pracownik_konto_fk FOREIGN KEY ( konto_id )
        REFERENCES konto ( id );

ALTER TABLE pracownik
    ADD CONSTRAINT pracownik_oddzial_fk FOREIGN KEY ( oddzial_id )
        REFERENCES oddzial ( id );

ALTER TABLE producent
    ADD CONSTRAINT producent_kontakt_fk FOREIGN KEY ( kontakt_id )
        REFERENCES kontakt ( id );

ALTER TABLE produkt
    ADD CONSTRAINT produkt_kategoria_fk FOREIGN KEY ( kategoria_id )
        REFERENCES kategoria ( id );

ALTER TABLE produkt
    ADD CONSTRAINT produkt_producent_fk FOREIGN KEY ( producent_id )
        REFERENCES producent ( id );

ALTER TABLE sektor
    ADD CONSTRAINT sektor_magazyn_fk FOREIGN KEY ( magazyn_id )
        REFERENCES magazyn ( id );

ALTER TABLE sprzet
    ADD CONSTRAINT sprzet_oddzial_fk FOREIGN KEY ( oddzial_id )
        REFERENCES oddzial ( id );

ALTER TABLE wyplata
    ADD CONSTRAINT wyplata_pracownik_fk FOREIGN KEY ( pracownik_id )
        REFERENCES pracownik ( id );

ALTER TABLE zamowienie
    ADD CONSTRAINT zamowienie_klient_fk FOREIGN KEY ( klient_id )
        REFERENCES klient ( id );

ALTER TABLE zamowienieprod
    ADD CONSTRAINT zamowienieprod_produkt_fk FOREIGN KEY ( produkt_id )
        REFERENCES produkt ( id );

ALTER TABLE zamowienieprod
    ADD CONSTRAINT zamowienieprod_zamowienie_fk FOREIGN KEY ( zamowienie_id )
        REFERENCES zamowienie ( id );

CREATE SEQUENCE dostawa_id_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER dostawa_id_trg BEFORE
    INSERT ON dostawa
    FOR EACH ROW
    WHEN ( new.id IS NULL )
BEGIN
    :new.id := dostawa_id_seq.nextval;
END;
/

CREATE SEQUENCE dostawaprodukt_id_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER dostawaprodukt_id_trg BEFORE
    INSERT ON dostawaprodukt
    FOR EACH ROW
    WHEN ( new.id IS NULL )
BEGIN
    :new.id := dostawaprodukt_id_seq.nextval;
END;
/

CREATE SEQUENCE dostawca_id_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER dostawca_id_trg BEFORE
    INSERT ON dostawca
    FOR EACH ROW
    WHEN ( new.id IS NULL )
BEGIN
    :new.id := dostawca_id_seq.nextval;
END;
/

CREATE SEQUENCE faktura_id_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER faktura_id_trg BEFORE
    INSERT ON faktura
    FOR EACH ROW
    WHEN ( new.id IS NULL )
BEGIN
    :new.id := faktura_id_seq.nextval;
END;
/

CREATE SEQUENCE kategoria_id_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER kategoria_id_trg BEFORE
    INSERT ON kategoria
    FOR EACH ROW
    WHEN ( new.id IS NULL )
BEGIN
    :new.id := kategoria_id_seq.nextval;
END;
/

CREATE SEQUENCE klient_id_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER klient_id_trg BEFORE
    INSERT ON klient
    FOR EACH ROW
    WHEN ( new.id IS NULL )
BEGIN
    :new.id := klient_id_seq.nextval;
END;
/

CREATE SEQUENCE kontakt_id_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER kontakt_id_trg BEFORE
    INSERT ON kontakt
    FOR EACH ROW
    WHEN ( new.id IS NULL )
BEGIN
    :new.id := kontakt_id_seq.nextval;
END;
/

CREATE SEQUENCE kontener_id_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER kontener_id_trg BEFORE
    INSERT ON kontener
    FOR EACH ROW
    WHEN ( new.id IS NULL )
BEGIN
    :new.id := kontener_id_seq.nextval;
END;
/

CREATE SEQUENCE konto_id_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER konto_id_trg BEFORE
    INSERT ON konto
    FOR EACH ROW
    WHEN ( new.id IS NULL )
BEGIN
    :new.id := konto_id_seq.nextval;
END;
/

CREATE SEQUENCE magazyn_id_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER magazyn_id_trg BEFORE
    INSERT ON magazyn
    FOR EACH ROW
    WHEN ( new.id IS NULL )
BEGIN
    :new.id := magazyn_id_seq.nextval;
END;
/

CREATE SEQUENCE oddzial_id_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER oddzial_id_trg BEFORE
    INSERT ON oddzial
    FOR EACH ROW
    WHEN ( new.id IS NULL )
BEGIN
    :new.id := oddzial_id_seq.nextval;
END;
/

CREATE SEQUENCE platnosc_id_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER platnosc_id_trg BEFORE
    INSERT ON platnosc
    FOR EACH ROW
    WHEN ( new.id IS NULL )
BEGIN
    :new.id := platnosc_id_seq.nextval;
END;
/

CREATE SEQUENCE pracownik_id_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER pracownik_id_trg BEFORE
    INSERT ON pracownik
    FOR EACH ROW
    WHEN ( new.id IS NULL )
BEGIN
    :new.id := pracownik_id_seq.nextval;
END;
/

CREATE SEQUENCE producent_id_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER producent_id_trg BEFORE
    INSERT ON producent
    FOR EACH ROW
    WHEN ( new.id IS NULL )
BEGIN
    :new.id := producent_id_seq.nextval;
END;
/

CREATE SEQUENCE produkt_id_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER produkt_id_trg BEFORE
    INSERT ON produkt
    FOR EACH ROW
    WHEN ( new.id IS NULL )
BEGIN
    :new.id := produkt_id_seq.nextval;
END;
/

CREATE SEQUENCE sektor_id_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER sektor_id_trg BEFORE
    INSERT ON sektor
    FOR EACH ROW
    WHEN ( new.id IS NULL )
BEGIN
    :new.id := sektor_id_seq.nextval;
END;
/

CREATE SEQUENCE sprzet_id_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER sprzet_id_trg BEFORE
    INSERT ON sprzet
    FOR EACH ROW
    WHEN ( new.id IS NULL )
BEGIN
    :new.id := sprzet_id_seq.nextval;
END;
/

CREATE SEQUENCE wyplata_id_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER wyplata_id_trg BEFORE
    INSERT ON wyplata
    FOR EACH ROW
    WHEN ( new.id IS NULL )
BEGIN
    :new.id := wyplata_id_seq.nextval;
END;
/

CREATE SEQUENCE zamowienie_id_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER zamowienie_id_trg BEFORE
    INSERT ON zamowienie
    FOR EACH ROW
    WHEN ( new.id IS NULL )
BEGIN
    :new.id := zamowienie_id_seq.nextval;
END;
/

CREATE SEQUENCE zamowienieprod_id_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER zamowienieprod_id_trg BEFORE
    INSERT ON zamowienieprod
    FOR EACH ROW
    WHEN ( new.id IS NULL )
BEGIN
    :new.id := zamowienieprod_id_seq.nextval;
END;
/



-- Oracle SQL Developer Data Modeler Summary Report: 
-- 
-- CREATE TABLE                            20
-- CREATE INDEX                             0
-- ALTER TABLE                             69
-- CREATE VIEW                              0
-- ALTER VIEW                               0
-- CREATE PACKAGE                           0
-- CREATE PACKAGE BODY                      0
-- CREATE PROCEDURE                         0
-- CREATE FUNCTION                          0
-- CREATE TRIGGER                          20
-- ALTER TRIGGER                            0
-- CREATE COLLECTION TYPE                   0
-- CREATE STRUCTURED TYPE                   0
-- CREATE STRUCTURED TYPE BODY              0
-- CREATE CLUSTER                           0
-- CREATE CONTEXT                           0
-- CREATE DATABASE                          0
-- CREATE DIMENSION                         0
-- CREATE DIRECTORY                         0
-- CREATE DISK GROUP                        0
-- CREATE ROLE                              0
-- CREATE ROLLBACK SEGMENT                  0
-- CREATE SEQUENCE                         20
-- CREATE MATERIALIZED VIEW                 0
-- CREATE SYNONYM                           0
-- CREATE TABLESPACE                        0
-- CREATE USER                              0
-- 
-- DROP TABLESPACE                          0
-- DROP DATABASE                            0
-- 
-- REDACTION POLICY                         0
-- 
-- ORDS DROP SCHEMA                         0
-- ORDS ENABLE SCHEMA                       0
-- ORDS ENABLE OBJECT                       0
-- 
-- ERRORS                                   0
-- WARNINGS                                 0
