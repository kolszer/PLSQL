--Krzysztof Olszer 219090

--WIDOK1 wyswietla oddzialy i sumy pensji tych pracownikow w danym oddziale ktorzy maja pensje wieksza niz srednia wszystkich pracownikow
CREATE OR REPLACE VIEW widok1 AS
SELECT o.nazwa AS "Nazwa oddzialu", sum(p.pensja) AS "Suma pensji" 
FROM oddzial o INNER JOIN pracownik p ON o.id = p.oddzial_id 
GROUP BY o.id, o.nazwa 
HAVING SUM(p.pensja) > (SELECT AVG(pensja) FROM pracownik);

--WIDOK2 wyswietla sume ilosci dostawy produktow w danym oddziale, gdzie suma porduktow ma byc wieksza niz srednia ilosc wszystkich produkow
CREATE OR REPLACE VIEW widok2 AS
SELECT sum(p.ilosc) AS "Suma", d.oddzial_id AS "Oddzial"
FROM dostawa d INNER JOIN dostawaprodukt p ON d.id = p.dostawa_id
GROUP BY d.oddzial_id
HAVING SUM(p.ilosc) > (SELECT AVG(ilosc) FROM dostawaprodukt);