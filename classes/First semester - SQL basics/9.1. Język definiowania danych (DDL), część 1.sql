-- start
SET TRANSACTION READ WRITE;

-- 1. Utwórz relację o nazwie PROJEKTY
CREATE TABLE projekty (
	id_projektu NUMBER(4) GENERATED ALWAYS AS IDENTITY,
	opis_projektu VARCHAR2(20),
	data_rozpoczecia DATE DEFAULT current_date,
	data_zakonczenia DATE,
	fundusz NUMBER(7,2)
);

-- 2. Wstaw do relacji PROJEKTY
INSERT INTO projekty VALUES (DEFAULT, 'indeksy bitmapowe', DATE '1999-04-02', DATE '2001-08-31', 25000);
INSERT INTO projekty VALUES (DEFAULT, 'sieci kręgosłupowe', DEFAULT, NULL, 19000);

-- 3. Sprawdź, wykonując odpowiednie zapytanie, jakie wartości zostały umieszczone w atrybucie ID_PROJEKTU relacji PROJEKTY w dodanych rekordach.
SELECT id_projektu, opis_projektu FROM projekty;

-- 4. Spróbuj wstawić do relacji PROJEKTY trzeci rekord, tym razem jawnie podaj wartość dla atrybutu ID_PROJEKTU:
INSERT INTO projekty VALUES (10, 'indeksy drzewiaste', DATE '2013-12-24', DATE '2014-01-01', 1200);

-- Czy polecenie zakończyło się sukcesem? Jeśli nie, wykonaj je w taki sposób, aby definicja projektu zakończyła się powodzeniem (pomiń podanie wartości dla ID_PROJEKTU)
-- ORA-32795: nie można wstawić do kolumny tożsamości utworzonej jako GENERATED ALWAYS

INSERT INTO projekty VALUES (DEFAULT, 'indeksy drzewiaste', DATE '2013-12-24', DATE '2014-01-01', 1200);

SELECT id_projektu, opis_projektu FROM projekty;

-- 5. Spróbuj zmienić aktualną wartość w atrybucie ID_PROJEKTU relacji PROJEKTY w rekordzie opisującym projekt o nazwie „Indeksy drzewiaste” na wartość 10. Czy operacja się powiodła?
UPDATE projekty SET id_projektu = 10 WHERE opis_projektu = 'indeksy drzewiaste';
-- ORA-32796: nie można zaktualizować kolumny tożsamości utworzonej jako GENERATED ALWAYS


-- 6. Utwórz kopię relacji PROJEKTY o nazwie PROJEKTY_KOPIA. Nowa relacja ma być identyczna zarówno pod względem struktury i jak i danych z relacją PROJEKTY. Użyj polecenia CREATE TABLE … AS SELECT …. Sprawdź zawartość nowo utworzonej relacji.
CREATE TABLE projekty_kopia AS SELECT * FROM projekty;

SELECT * FROM projekty_kopia;

-- 7. Do relacji PROJEKTY_KOPIA dodaj nowy rekord:
INSERT INTO projekty_kopia VALUES (10, 'sieci lokalne', current_date, current_date+INTERVAL '1' YEAR, 24500);

SELECT * FROM projekty_kopia;

-- Dlaczego to polecenie zakończyło się sukcesem (porównaj z p. 4.)?
-- Brak reguł kolumn w kopii - AS SELECT przenosi tylko wartości.

-- 8. Usuń z relacji PROJEKTY rekord opisujący projekt o nazwie „Indeksy drzewiaste”. 
DELETE FROM projekty WHERE opis_projektu = 'indeksy drzewiaste';

SELECT * FROM projekty_kopia;

-- Czy rekord, opisujący usunięty projekt, został również automatycznie usunięty z relacji PROJEKTY_KOPIA?
-- Nie, bo PROJEKTY_KOPIA to fizyczna kopia danych, nie dowiązanie.

-- 9. Sprawdź w słowniku bazy danych, jakie relacje posiadasz w swoimi schemacie
SELECT table_name FROM user_tables;

-- end
ROLLBACK;
DROP TABLE projekty;
DROP TABLE projekty_kopia;