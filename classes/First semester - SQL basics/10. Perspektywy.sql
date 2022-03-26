-- 1. Zdefiniuj perspektywę ASYSTENCI, udostępniającą następujące informacje o asystentach zatrudnionych w Instytucie: nazwisko (kolumna nazwisko), płaca rozumiana jako suma płac: podstawowej i dodatkowej (kolumna placa) oraz staż pracy (kolumna staz; staż pracy ma być wyliczony na dzień 1 stycznia bieżącego roku). Staż pracy ma być prezentowany w postaci interwałów o precyzji od lat do miesięcy.
CREATE OR REPLACE VIEW asystenci (nazwisko, placa, staz) AS 
SELECT nazwisko, placa_pod + coalesce(placa_dod, 0), (DATE  '2020-01-01' - zatrudniony) YEAR TO MONTH FROM pracownicy WHERE etat = 'ASYSTENT';

-- 2. Zdefiniuj perspektywę PLACE udostępniającą następujące dane: numer zespołu, średnią, minimalną i maksymalną płacę w zespole (miesięczna płaca wraz z dodatkami), fundusz płac (suma pieniędzy wypłacanych miesięcznie pracownikom) oraz liczbę wypłacanych pensji i dodatków. Wyświetl całość informacji udostępnianych przez perspektywę
CREATE OR REPLACE VIEW place (id_zesp, srednia, minimum, maximum, fundusz, l_pensji, l_dodatkow) AS
SELECT id_zesp, AVG(placa_pod + coalesce(placa_dod, 0)) srednia, MIN(placa_pod + coalesce(placa_dod, 0)) minimum, MAX(placa_pod + coalesce(placa_dod, 0)) maximum, SUM(placa_pod + coalesce(placa_dod, 0)) fundusz, COUNT(placa_pod) l_pensji, COUNT(placa_dod) l_dodatkow FROM pracownicy GROUP BY id_zesp ORDER BY id_zesp;

-- 3. Korzystając z perspektywy PLACE wyświetl nazwiska i płace tych pracowników, którzy zarabiają mniej niż średnia w ich zespole.
SELECT nazwisko, placa_pod FROM pracownicy JOIN place USING (id_zesp) WHERE srednia > placa_pod ORDER BY nazwisko;

-- 4. Zdefiniuj perspektywę PLACE_MINIMALNE wyświetlającą pracowników zarabiających poniżej 700 złotych. Perspektywa musi zapewniać weryfikację danych, w taki sposób, aby za jej pomocą nie można było podnieść pensji pracownika powyżej pułapu 700 złotych.
CREATE OR REPLACE VIEW place_minimalne (id_prac, nazwisko, etat, placa_pod) AS
SELECT id_prac, nazwisko, etat, placa_pod FROM pracownicy WHERE placa_pod < 700 WITH CHECK OPTION CONSTRAINT za_wysoka_placa;

-- 5. Spróbuj za pomocą perspektywy PLACE_MINIMALNE zwiększyć pensję pracownika HAPKE do 800 złotych.
UPDATE place_minimalne SET placa_pod=800 WHERE nazwisko='HAPKE';
-- failed successfully

-- 6. Stwórz perspektywę PRAC_SZEF prezentującą informacje o pracownikach i ich przełożonych. Zwróć uwagę na to, aby można było przez perspektywę PRAC_SZEF wstawiać nowych pracowników oraz modyfikować i usuwać istniejących pracowników.
CREATE OR REPLACE VIEW prac_szef (id_prac, id_szefa, pracownik, etat, szef) AS
SELECT p.id_prac id_prac, p.id_szefa, p.nazwisko AS pracownik, p.etat, s.nazwisko szef FROM pracownicy p JOIN pracownicy s ON p.id_szefa = s.id_prac ORDER BY pracownik;

-- 6 check
INSERT INTO prac_szef (id_prac, id_szefa, pracownik, etat) VALUES (280, 150, 'MORZY','ASYSTENT');
UPDATE prac_szef SET id_szefa = 130 WHERE id_prac = 280;
DELETE FROM prac_szef WHERE id_prac = 280;
-- passed

-- 7. Stwórz perspektywę ZAROBKI wyświetlającą poniższe informacje o pracownikach. Perspektywa musi zapewniać kontrolę pensji pracownika (pensja pracownika nie może być wyższa niż pensja jego szefa).
CREATE OR REPLACE VIEW zarobki (id_prac, nazwisko, etat, placa_pod) AS
SELECT p.id_prac, p.nazwisko, p.etat, p.placa_pod FROM pracownicy p WHERE p.placa_pod < (SELECT placa_pod FROM pracownicy s WHERE s.id_prac=p.id_szefa) WITH CHECK OPTION;

-- 7 check
UPDATE zarobki SET placa_pod = 2000 WHERE nazwisko = 'BIALY';
-- failed successfully

-- 8. Wyświetl informacje ze słownika bazy danych dotyczące możliwości wstawiania, modyfikowania i usuwania za pomocą perspektywy PRAC_SZEF
SELECT column_name, updatable, insertable, deletable
 FROM user_updatable_columns
 WHERE table_name = 'prac_szef';

