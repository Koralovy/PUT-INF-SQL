-- start
SET TRANSACTION READ WRITE;

-- 1. Zmodyfikuj strukturę relacji PROJEKTY, dodając do niej definicje następujących ograniczeń integralnościowych (użyj kilku poleceń):
-- • klucz podstawowy o nazwie PK_PROJEKTY na atrybucie ID_PROJEKTU,
-- • klucz unikalny o nazwie UK_PROJEKTY na atrybucie OPIS_PROJEKTU,
-- • atrybut OPIS_PROJEKTU nie przyjmuje wartości pustych,
-- • wartość atrybutu DATA_ZAKONCZENIA musi być późniejsza niż wartość atrybutu DATA_ROZPOCZECIA,
-- • atrybut FUNDUSZ akceptuje tylko wartości dodatnie lub wartości puste.
ALTER TABLE projekty ADD CONSTRAINT pk_projekty PRIMARY KEY(id_projektu);
ALTER TABLE projekty ADD CONSTRAINT uk_projekty UNIQUE(opis_projektu);
ALTER TABLE projekty MODIFY opis_projektu NOT NULL;
ALTER TABLE projekty ADD CHECK(data_zakonczenia > data_rozpoczecia);
ALTER TABLE projekty ADD CHECK(fundusz > 0);

-- Następnie sprawdź w słowniku bazy danych informacje o zdefiniowanych w tym punkcie ograniczeniach integralnościowych. Zwróć szczególną uwagę na nazwy ograniczeń, które zostały nadane automatycznie.
SELECT user_constraints.constraint_name, constraint_type, search_condition, column_name FROM user_cons_columns JOIN user_constraints ON user_constraints.owner = user_cons_columns.owner AND user_constraints.constraint_name = user_cons_columns.constraint_name WHERE user_constraints.table_name = 'projekty';

-- 2. Spróbuj wstawić do relacji PROJEKTY rekord, który zduplikuje opis istniejącego już projektu „Indeksy bitmapowe”.
INSERT INTO projekty VALUES (DEFAULT, 'indeksy bitmapowe', DATE '2015-04-12', DATE '2016-09-30', 40000);

-- Czy polecenie zakończyło się powodzeniem? Co jest przyczyną błędu?
-- ORA-00001: naruszono więzy unikatowe (INF145380.UK_PROJEKTY)

-- 3. Utwórz relację o nazwie PRZYDZIALY, użyj jednego polecenia. Uwaga! Kluczem podstawowym relacji PRZYDZIALY jest para atrybutów (ID_PROJEKTU, NR_PRACOWNIKA), nazwa klucza to PK_PRZYDZIALY.
CREATE TABLE przydzialy (
    id_projektu NUMBER(4) NOT NULL CONSTRAINT fk_przydzialy_01 REFERENCES projekty (id_projektu),
    nr_pracownika NUMBER(6) NOT NULL CONSTRAINT fk_przydzialy_02 REFERENCES pracownicy (id_prac),
    od DATE DEFAULT current_date,
    do DATE,
    stawka NUMBER(7, 2) CONSTRAINT chk_przydzialy_stawka CHECK(stawka > 0),
    rola VARCHAR2(20) CONSTRAINT chk_przydzialy_rola CHECK(rola IN ('kierujący','analityk', 'programista')),
    CONSTRAINT pk_przydzialy PRIMARY KEY (id_projektu, nr_pracownika),
    CONSTRAINT chk_przydzialy_daty CHECK(od < do)
);

-- 4. Wstaw do relacji PRZYDZIALY trzy rekordy:
-- Uwaga! Identyfikator wskazanego projektu powinien być pobrany przez zapytanie, umieszczone bezpośrednio w poleceniu wstawiającym rekord.
INSERT INTO przydzialy VALUES ((SELECT id_projektu FROM projekty WHERE opis_projektu = 'indeksy bitmapowe'), 170, DATE '1999-04-10', DATE '1999-05-10', 1000, 'kierujący');
INSERT INTO przydzialy VALUES ((SELECT id_projektu FROM projekty WHERE opis_projektu = 'indeksy bitmapowe'), 140, DATE '2000-12-01', NULL, 1500, 'analityk');
INSERT INTO przydzialy VALUES ((SELECT id_projektu FROM projekty WHERE opis_projektu = 'sieci kręgosłupowe'), 140, DATE '2015-09-14', NULL, 2500, 'kierujący');

-- Sprawdź, czy rekordy zostały poprawnie wstawione
SELECT * FROM przydzialy;

-- 5. Dodaj do relacji PRZYDZIALY atrybut GODZINY, będący liczbą całkowitą o maksymalnej wartości równej 9999. Atrybut nie może przyjmować wartości pustych.
ALTER TABLE przydzialy ADD godziny NUMBER NOT NULL CHECK (godziny <= 9999);

-- Czy udało się dodać atrybut? Co jest powodem błędu?
-- ORA-01758: aby dodać obowiązkową kolumnę (NOT NULL) tabela musi być pusta

-- 6. Operację z poprzedniego punktu wykonaj w następujący sposób:
-- • dodaj definicję atrybutu GODZINY bez wskazania wymagalności wartości,
ALTER TABLE przydzialy ADD godziny NUMBER;

-- • ustaw wartości atrybutu GODZINY w poszczególnych rekordach relacji PRZYDZIALY na wybrane przez siebie wartości,
UPDATE przydzialy SET godziny = id_projektu + nr_pracownika;

-- • nałóż na atrybut GODZINY wymagalność wartości.
ALTER TABLE przydzialy ADD CHECK (godziny <= 9999);

-- 7. Wyłącz (nie usuwaj!) sprawdzanie unikalności opisów projektów w relacji PROJEKTY.
-- Sprawdź status ograniczenia zapytaniem do perspektywy USER_CONSTRAINTS.
ALTER TABLE projekty DISABLE CONSTRAINT uk_projekty;
SELECT constraint_name, status FROM user_constraints WHERE table_name = 'projekty' AND constraint_name = 'uk_projekty';

-- 8. Wstaw do relacji PROJEKTY rekord, który zduplikuje opis istniejącego już projektu „Indeksy bitmapowe”.
INSERT INTO projekty VALUES (DEFAULT, 'indeksy bitmapowe', DATE '2015-04-12', DATE '2016-09-30', 40000);

-- Czy teraz polecenie się powiodło? Wykonaj zapytanie wyświetlające zawartość relacji PROJEKTY.
-- tak
SELECT * FROM projekty;

-- 9. Spróbuj włączyć wyłączone przed chwilą ograniczenie.
ALTER TABLE projekty ENABLE CONSTRAINT uk_projekty;

-- Czy polecenie się powiodło?
-- ORA-02299: nie można zweryfikować poprawności (INF145380.UK_PROJEKTY) - znaleziono zduplikowane klucze

-- 10. Zmień opis dodanego przed chwilą projektu z „Indeksy bitmapowe” na „Inne indeksy” (zwróć uwagę, że teraz w relacji PROJEKTY mamy dwa projekty z opisem „Indeksy bitmapowe” – masz zmienić opis tylko jednego, dodanego przed chwilą).
UPDATE projekty SET opis_projektu='inne indeksy' WHERE id_projektu = (SELECT MAX(id_projektu) FROM projekty);

--  Następnie spróbuj ponownie włączyć wyłączone ograniczenie.
ALTER TABLE projekty ENABLE CONSTRAINT uk_projekty;

-- Czy teraz udało się włączyć ograniczenie?
-- tak

-- 11. Spróbuj zmienić maksymalny rozmiar atrybutu OPIS_PROJEKTU w relacji PROJEKTY na 10 znaków.
ALTER TABLE projekty MODIFY opis_projektu VARCHAR2(10);

-- Czy zmiana się udała? Jeśli nie, dlaczego?
-- ORA-01441: nie można zmniejszyć długości kolumny, ponieważ niektóre wartości są zbyt duże

-- 12. Spróbuj usunąć z relacji PROJEKTY rekord opisujący projekt z opisem „Sieci kręgosłupowe”.
DELETE FROM projekty WHERE opis_projektu='sieci kręgosłupowe';

-- Czy operacja usunięcia zakończyła się sukcesem? Jeśli nie – dlaczego?
-- ORA-02292: naruszono więzy spójności (INF145380.FK_PRZYDZIALY_01) - znaleziono rekord podrzędny

-- 13. Zmień w relacji PRZYDZIALY definicję klucza obcego o nazwie FK_PRZYDZIALY_01 w taki sposób, aby usunięcie projektu z relacji PROJEKTY automatycznie powodowało usunięcie związanych z usuwanym projektem przydziałów z relacji PRZYDZIALY (wykonaj to przy pomocy dwóch poleceń ALTER TABLE).
ALTER TABLE przydzialy DROP CONSTRAINT fk_przydzialy_01;
ALTER TABLE przydzialy MODIFY id_projektu NUMBER(4) CONSTRAINT fk_przydzialy_01 REFERENCES projekty (id_projektu) ON DELETE CASCADE;

-- Następnie ponownie spróbuj usunąć z relacji PROJEKTY rekord opisujący projekt „Sieci kręgosłupowe”.
DELETE FROM projekty WHERE opis_projektu = 'sieci kręgosłupowe';

-- Tym razem usunięcie powinno zakończyć się sukcesem. Sprawdź, czy w relacjach PROJEKTY i PRZYDZIALY usunięte zostały odpowiednie rekordy.
SELECT * FROM projekty;
SELECT * FROM przydzialy;
-- start
SET TRANSACTION READ WRITE;

-- 1. Zmodyfikuj strukturę relacji PROJEKTY, dodając do niej definicje następujących ograniczeń integralnościowych (użyj kilku poleceń):
-- • klucz podstawowy o nazwie PK_PROJEKTY na atrybucie ID_PROJEKTU,
-- • klucz unikalny o nazwie UK_PROJEKTY na atrybucie OPIS_PROJEKTU,
-- • atrybut OPIS_PROJEKTU nie przyjmuje wartości pustych,
-- • wartość atrybutu DATA_ZAKONCZENIA musi być późniejsza niż wartość atrybutu DATA_ROZPOCZECIA,
-- • atrybut FUNDUSZ akceptuje tylko wartości dodatnie lub wartości puste.
ALTER TABLE projekty ADD CONSTRAINT pk_projekty PRIMARY KEY(id_projektu);
ALTER TABLE projekty ADD CONSTRAINT uk_projekty UNIQUE(opis_projektu);
ALTER TABLE projekty MODIFY opis_projektu NOT NULL;
ALTER TABLE projekty ADD CHECK(data_zakonczenia > data_rozpoczecia);
ALTER TABLE projekty ADD CHECK(fundusz > 0);

-- Następnie sprawdź w słowniku bazy danych informacje o zdefiniowanych w tym punkcie ograniczeniach integralnościowych. Zwróć szczególną uwagę na nazwy ograniczeń, które zostały nadane automatycznie.
SELECT user_constraints.constraint_name, constraint_type, search_condition, column_name FROM user_cons_columns JOIN user_constraints ON user_constraints.owner = user_cons_columns.owner AND user_constraints.constraint_name = user_cons_columns.constraint_name WHERE user_constraints.table_name = 'projekty';

-- 2. Spróbuj wstawić do relacji PROJEKTY rekord, który zduplikuje opis istniejącego już projektu „Indeksy bitmapowe”.
INSERT INTO projekty VALUES (DEFAULT, 'indeksy bitmapowe', DATE '2015-04-12', DATE '2016-09-30', 40000);

-- Czy polecenie zakończyło się powodzeniem? Co jest przyczyną błędu?
-- ORA-00001: naruszono więzy unikatowe (INF145380.UK_PROJEKTY)

-- 3. Utwórz relację o nazwie PRZYDZIALY, użyj jednego polecenia. Uwaga! Kluczem podstawowym relacji PRZYDZIALY jest para atrybutów (ID_PROJEKTU, NR_PRACOWNIKA), nazwa klucza to PK_PRZYDZIALY.
CREATE TABLE przydzialy (
    id_projektu NUMBER(4) NOT NULL CONSTRAINT fk_przydzialy_01 REFERENCES projekty (id_projektu),
    nr_pracownika NUMBER(6) NOT NULL CONSTRAINT fk_przydzialy_02 REFERENCES pracownicy (id_prac),
    od DATE DEFAULT current_date,
    do DATE,
    stawka NUMBER(7, 2) CONSTRAINT chk_przydzialy_stawka CHECK(stawka > 0),
    rola VARCHAR2(20) CONSTRAINT chk_przydzialy_rola CHECK(rola IN ('kierujący','analityk', 'programista')),
    CONSTRAINT pk_przydzialy PRIMARY KEY (id_projektu, nr_pracownika),
    CONSTRAINT chk_przydzialy_daty CHECK(od < do)
);

-- 4. Wstaw do relacji PRZYDZIALY trzy rekordy:
-- Uwaga! Identyfikator wskazanego projektu powinien być pobrany przez zapytanie, umieszczone bezpośrednio w poleceniu wstawiającym rekord.
INSERT INTO przydzialy VALUES ((SELECT id_projektu FROM projekty WHERE opis_projektu = 'indeksy bitmapowe'), 170, DATE '1999-04-10', DATE '1999-05-10', 1000, 'kierujący');
INSERT INTO przydzialy VALUES ((SELECT id_projektu FROM projekty WHERE opis_projektu = 'indeksy bitmapowe'), 140, DATE '2000-12-01', NULL, 1500, 'analityk');
INSERT INTO przydzialy VALUES ((SELECT id_projektu FROM projekty WHERE opis_projektu = 'sieci kręgosłupowe'), 140, DATE '2015-09-14', NULL, 2500, 'kierujący');

-- Sprawdź, czy rekordy zostały poprawnie wstawione
SELECT * FROM przydzialy;

-- 5. Dodaj do relacji PRZYDZIALY atrybut GODZINY, będący liczbą całkowitą o maksymalnej wartości równej 9999. Atrybut nie może przyjmować wartości pustych.
ALTER TABLE przydzialy ADD godziny NUMBER NOT NULL CHECK (godziny <= 9999);

-- Czy udało się dodać atrybut? Co jest powodem błędu?
-- ORA-01758: aby dodać obowiązkową kolumnę (NOT NULL) tabela musi być pusta

-- 6. Operację z poprzedniego punktu wykonaj w następujący sposób:
-- • dodaj definicję atrybutu GODZINY bez wskazania wymagalności wartości,
ALTER TABLE przydzialy ADD godziny NUMBER;

-- • ustaw wartości atrybutu GODZINY w poszczególnych rekordach relacji PRZYDZIALY na wybrane przez siebie wartości,
UPDATE przydzialy SET godziny = id_projektu + nr_pracownika;

-- • nałóż na atrybut GODZINY wymagalność wartości.
ALTER TABLE przydzialy ADD CHECK (godziny <= 9999);

-- 7. Wyłącz (nie usuwaj!) sprawdzanie unikalności opisów projektów w relacji PROJEKTY.
-- Sprawdź status ograniczenia zapytaniem do perspektywy USER_CONSTRAINTS.
ALTER TABLE projekty DISABLE CONSTRAINT uk_projekty;
SELECT constraint_name, status FROM user_constraints WHERE table_name = 'projekty' AND constraint_name = 'uk_projekty';

-- 8. Wstaw do relacji PROJEKTY rekord, który zduplikuje opis istniejącego już projektu „Indeksy bitmapowe”.
INSERT INTO projekty VALUES (DEFAULT, 'indeksy bitmapowe', DATE '2015-04-12', DATE '2016-09-30', 40000);

-- Czy teraz polecenie się powiodło? Wykonaj zapytanie wyświetlające zawartość relacji PROJEKTY.
-- tak
SELECT * FROM projekty;

-- 9. Spróbuj włączyć wyłączone przed chwilą ograniczenie.
ALTER TABLE projekty ENABLE CONSTRAINT uk_projekty;

-- Czy polecenie się powiodło?
-- ORA-02299: nie można zweryfikować poprawności (INF145380.UK_PROJEKTY) - znaleziono zduplikowane klucze

-- 10. Zmień opis dodanego przed chwilą projektu z „Indeksy bitmapowe” na „Inne indeksy” (zwróć uwagę, że teraz w relacji PROJEKTY mamy dwa projekty z opisem „Indeksy bitmapowe” – masz zmienić opis tylko jednego, dodanego przed chwilą).
UPDATE projekty SET opis_projektu='inne indeksy' WHERE id_projektu = (SELECT MAX(id_projektu) FROM projekty);

--  Następnie spróbuj ponownie włączyć wyłączone ograniczenie.
ALTER TABLE projekty ENABLE CONSTRAINT uk_projekty;

-- Czy teraz udało się włączyć ograniczenie?
-- tak

-- 11. Spróbuj zmienić maksymalny rozmiar atrybutu OPIS_PROJEKTU w relacji PROJEKTY na 10 znaków.
ALTER TABLE projekty MODIFY opis_projektu VARCHAR2(10);

-- Czy zmiana się udała? Jeśli nie, dlaczego?
-- ORA-01441: nie można zmniejszyć długości kolumny, ponieważ niektóre wartości są zbyt duże

-- 12. Spróbuj usunąć z relacji PROJEKTY rekord opisujący projekt z opisem „Sieci kręgosłupowe”.
DELETE FROM projekty WHERE opis_projektu='sieci kręgosłupowe';

-- Czy operacja usunięcia zakończyła się sukcesem? Jeśli nie – dlaczego?
-- ORA-02292: naruszono więzy spójności (INF145380.FK_PRZYDZIALY_01) - znaleziono rekord podrzędny

-- 13. Zmień w relacji PRZYDZIALY definicję klucza obcego o nazwie FK_PRZYDZIALY_01 w taki sposób, aby usunięcie projektu z relacji PROJEKTY automatycznie powodowało usunięcie związanych z usuwanym projektem przydziałów z relacji PRZYDZIALY (wykonaj to przy pomocy dwóch poleceń ALTER TABLE).
ALTER TABLE przydzialy DROP CONSTRAINT fk_przydzialy_01;
ALTER TABLE przydzialy MODIFY id_projektu NUMBER(4) CONSTRAINT fk_przydzialy_01 REFERENCES projekty (id_projektu) ON DELETE CASCADE;

-- Następnie ponownie spróbuj usunąć z relacji PROJEKTY rekord opisujący projekt „Sieci kręgosłupowe”.
DELETE FROM projekty WHERE opis_projektu = 'sieci kręgosłupowe';

-- Tym razem usunięcie powinno zakończyć się sukcesem. Sprawdź, czy w relacjach PROJEKTY i PRZYDZIALY usunięte zostały odpowiednie rekordy.
SELECT * FROM projekty;
SELECT * FROM przydzialy;

-- 14. Spróbuj usunąć relację PROJEKTY. Użyj polecenia, które jednocześnie z usuwaną relacją usunie klucze obce z innych relacji, wskazujące na usuwaną relację.
DROP TABLE projekty CASCADE CONSTRAINTS;

-- Sprawdź w słowniku bazy danych, jakie ograniczenia relacji PRZYDZIALY zostały usunięte wraz z relacją PROJEKTY.
SELECT user_constraints.constraint_name, constraint_type, search_condition, column_name FROM user_cons_columns JOIN user_constraints ON user_constraints.owner = user_cons_columns.owner AND user_constraints.constraint_name = user_cons_columns.constraint_name WHERE user_constraints.table_name = 'projekty';

-- 15. Usuń pozostałe dwie relacje: PRZYDZIALY i PROJEKTY_KOPIA
DROP TABLE przydzialy;
DROP TABLE projekty_kopia;

-- Sprawdź, korzystając ze słownika bazy danych, jakie relacje posiadasz obecnie w swoim schemacie.
SELECT table_name FROM user_tables;

-- end
ROLLBACK;
-- 14. Spróbuj usunąć relację PROJEKTY. Użyj polecenia, które jednocześnie z usuwaną relacją usunie klucze obce z innych relacji, wskazujące na usuwaną relację.
DROP TABLE projekty CASCADE CONSTRAINTS;

-- Sprawdź w słowniku bazy danych, jakie ograniczenia relacji PRZYDZIALY zostały usunięte wraz z relacją PROJEKTY.
SELECT user_constraints.constraint_name, constraint_type, search_condition, column_name FROM user_cons_columns JOIN user_constraints ON user_constraints.owner = user_cons_columns.owner AND user_constraints.constraint_name = user_cons_columns.constraint_name WHERE user_constraints.table_name = 'projekty';

-- 15. Usuń pozostałe dwie relacje: PRZYDZIALY i PROJEKTY_KOPIA
DROP TABLE przydzialy;
DROP TABLE projekty_kopia;

-- Sprawdź, korzystając ze słownika bazy danych, jakie relacje posiadasz obecnie w swoim schemacie.
SELECT table_name FROM user_tables;

-- end
ROLLBACK;