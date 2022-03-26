-- Techniczne
SET TRANSACTION READ WRITE;
ROLLBACK; 
DROP SEQUENCE PRAC_SEQ;

-- Wstaw do relacji PRACOWNICY trzy nowe rekordy:
INSERT INTO pracownicy VALUES (250, 'KOWALSKI', 'ASYSTENT',Null, DATE '2015-01-13', 1500, null, 10);
INSERT INTO pracownicy VALUES (260, 'ADAMSKI', 'ASYSTENT', Null, DATE '2014-09-10', 1500, null, 10);
INSERT INTO pracownicy VALUES (270, 'NOWAK', 'ADIUNKT', Null, DATE '1990-05-01', 2050, 540, 20);

-- Wykonaj zapytanie, które wyświetli wszystkie informacje o dodanych w p. 1. pracownikach.
SELECT * FROM pracownicy WHERE id_prac >= 250;

-- 2. Dodanym w p. 1. pracownikom zwiększ płacę podstawową o 10% a dodatkową o 20% (jeśli pracownik nie miał do tej pory płacy dodatkowej, ustaw ją na wartość 100). Użyj tylko jednego polecenia!
UPDATE pracownicy 
SET placa_pod = placa_pod * 1.1, placa_dod = coalesce(placa_dod * 1.2, 100) 
WHERE id_prac >= 250;

-- Następnie wykonaj zapytanie, które sprawdzi poprawność modyfikacji.
SELECT * FROM pracownicy WHERE id_prac >= 250;

-- 3. Wstaw do relacji ZESPOLY rekord opisujący nowy zespół o nazwie BAZY DANYCH, identyfikatorze równym 60 i lokalizacji PIOTROWO 2.
INSERT INTO zespoly values(60, 'BAZY DANYCH', 'PIOTROWO 2');

-- Wykonaj zapytanie, które wyświetli wszystkie dane dodanego zespołu
SELECT * FROM zespoly WHERE id_zesp = 60;

-- 4. Przenieś dodanych w punkcie 1. pracowników do zespołu BAZY DANYCH. W poleceniu użyj podzapytania, które wyszuka w relacji ZESPOLY identyfikator zespołu BAZY DANYCH (nie podawaj go wprost w poleceniu!)

UPDATE pracownicy
SET id_zesp = (SELECT id_zesp FROM zespoly WHERE nazwa = 'BAZY DANYCH')
WHERE id_prac >= 250;

-- Sprawdź, wykonując odpowiednie zapytanie, jacy pracownicy należą teraz do zespołu BAZY DANYCH.
SELECT * FROM pracownicy WHERE id_zesp = 60;

-- 5. Ustaw wszystkim pracownikom zespołu BAZY DANYCH pracownika o nazwisku MORZY jako szefa (zapytanie, wyszukujące w relacji PRACOWNICY identyfikator pracownika MORZY powinno być częścią polecenia UPDATE).
UPDATE pracownicy
SET id_szefa = (SELECT id_prac FROM pracownicy WHERE nazwisko = 'MORZY')
WHERE id_zesp = 60;

-- Wyświetl teraz nazwiska wszystkich pracowników, których bezpośrednim przełożonym jest pracownik MORZY.
SELECT * FROM pracownicy WHERE id_szefa = (SELECT id_prac FROM pracownicy WHERE nazwisko = 'MORZY');

-- 6. Spróbuj usunąć z relacji ZESPOLY rekord opisujący zespół o nazwie BAZY DANYCH.
DELETE FROM zespoly WHERE nazwa = 'BAZY DANYCH';
-- ERROR: ORA-02292: naruszono więzy spójności (INF145380.FK_ID_ZESP) - znaleziono rekord podrzędny

-- 7. Usuń wszystkich pracowników, którzy należą do zespołu BAZY DANYCH. Następnie ponów operację usunięcia zespołu BAZY DANYCH.
DELETE FROM pracownicy WHERE id_zesp = (SELECT id_zesp FROM zespoly WHERE nazwa = 'BAZY DANYCH');
DELETE FROM zespoly WHERE nazwa = 'BAZY DANYCH';

-- Sprawdź, wykonując odpowiednie zapytania, czy rekordy z relacji ZESPOLY i PRACOWNICY zostały usunięte.
SELECT * FROM pracownicy WHERE id_prac >= 250;
SELECT * FROM zespoly WHERE id_zesp = 60;

-- 8. Skonstruuj zapytanie, które dla każdego pracownika wyliczy kwotę podwyżki, jaką dostanie. Podwyżka powinna być równa 10% średniej płacy podstawowej w zespole, do którego należy pracownik.
WITH srednie AS (SELECT id_zesp, AVG(placa_pod) AS srednia FROM pracownicy GROUP BY id_zesp)
SELECT nazwisko, placa_pod, 0.1*srednie.srednia AS podwyzka FROM pracownicy NATURAL JOIN srednie ORDER BY nazwisko;

-- 9. Zrealizuj podwyżkę z poprzedniego punktu.
UPDATE pracownicy
SET placa_pod = placa_pod + 0.1 * (SELECT AVG(placa_pod) FROM pracownicy p GROUP BY id_zesp HAVING p.id_zesp = pracownicy.id_zesp);

-- 10. Wyświetl dane pracowników, którzy zarabiają najmniej. Weź pod uwagę tylko wartość płacy podstawowej.
SELECT * FROM pracownicy WHERE placa_pod = (SELECT MIN(placa_pod) FROM pracownicy);

-- 11. Daj kolejną podwyżkę, tym razem tylko najmniej zarabiającym pracownikom. Ustaw im płacę podstawową na wartość równą średniej płacy podstawowej wszystkich pracowników (dokonaj zaokrąglenia wartości płacy do dwóch miejsc po przecinku).
UPDATE pracownicy
SET placa_pod = (SELECT ROUND(AVG(placa_pod), 2) FROM pracownicy)
WHERE placa_pod = (SELECT MIN(placa_pod) FROM pracownicy);

-- 12. Uaktualnij płace dodatkowe pracowników zespołu 20. Nowe płace dodatkowe mają być równe średniej płacy podstawowej pracowników, których przełożonym jest pracownik MORZY.
SELECT nazwisko, placa_dod FROM pracownicy WHERE id_zesp = 20 ORDER BY nazwisko;

UPDATE pracownicy
SET placa_dod = (SELECT AVG(placa_pod) FROM pracownicy WHERE id_szefa = (SELECT id_prac FROM pracownicy WHERE nazwisko = 'MORZY'))
WHERE id_zesp = 20;

-- 13. Pracownikom zespołu o nazwie SYSTEMY ROZPROSZONE daj 25% podwyżkę (płaca podstawowa). Tym razem zastosuj modyfikację operacji połączenia.
SELECT nazwisko, placa_pod FROM pracownicy NATURAL JOIN zespoly z WHERE z.nazwa = 'SYSTEMY ROZPROSZONE' ORDER BY nazwisko;

UPDATE (SELECT placa_pod FROM pracownicy NATURAL JOIN zespoly WHERE nazwa = 'SYSTEMY ROZPROSZONE')
SET placa_pod = placa_pod*1.25;

-- 14. Usuń bezpośrednich podwładnych pracownika o nazwisku MORZY. Zastosuj usuwanie krotek z wyniku połączenia relacji.
SELECT p.nazwisko AS pracownik, s.nazwisko AS szef FROM pracownicy p JOIN pracownicy s ON p.id_szefa=s.id_prac WHERE s.nazwisko = 'MORZY';

DELETE FROM (SELECT p.nazwisko AS pracownik, s.nazwisko AS szef FROM pracownicy p JOIN pracownicy s ON p.id_szefa=s.id_prac WHERE s.nazwisko = 'MORZY');

-- 15. Wyświetl aktualną zawartość relacji PRACOWNICY.
select * from PRACOWNICY;

-- Sekwencje - zadania
-- 16. Utwórz sekwencję o nazwie PRAC_SEQ, rozpoczynającą generację wartości od 300 z krokiem 10. Sekwencja będzie używana do generacji wartości dla atrybutu ID_PRAC relacji PRACOWNICY w nowo definiowanych rekordach.
CREATE SEQUENCE PRAC_SEQ START WITH 300 increment by 10;

-- 17. Wykorzystaj utworzoną sekwencję do wstawienia nowego stażysty o nazwisku Trąbczyński i płacy równej 1000 do relacji Pracownicy.
INSERT INTO pracownicy (id_prac, nazwisko, etat, placa_pod) values (PRAC_SEQ.nextval, 'TRĄBCZYŃSKI', 'STAZYSTA', 1000);

-- 18. Zmodyfikuj pracownikowi Trąbczyńskiemu płacę dodatkową na wartość wskazywaną aktualnie (a nie nowo wygenerowaną!) przez sekwencję.
UPDATE pracownicy
SET placa_dod = PRAC_SEQ.currval
WHERE nazwisko = 'TRĄBCZYŃSKI';

-- 19. Usuń pracownika o nazwisku Trąbczyński.
DELETE FROM pracownicy WHERE nazwisko = 'TRĄBCZYŃSKI';

-- 20. Utwórz nową sekwencję MALA_SEQ o niskiej wartości maksymalnej (np. 10). Zaobserwuj, co się dzieje, gdy następuje przekroczenie wartości maksymalnej sekwencji.
CREATE SEQUENCE MALA_SEQ START WITH 1 MAXVALUE 10;
SELECT MALA_SEQ.nextval FROM dual;
--polecenie nie działa w SQL Worksheet - ORA-02287: w tym miejscu numer sekwencji jest niedozwolony

-- 21. Usuń sekwencję MALA_SEQ.
DROP SEQUENCE MALA_SEQ;