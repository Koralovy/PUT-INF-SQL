-- setup
set serveroutput on

-- 0. Utwórz  w  swoim  schemacie  procedurę Podwyzka.  Upewnij  się,  że  jej  kompilacja  zakończyła  się powodzeniem (nie wystąpiły żadne błędy).

CREATE PROCEDURE Podwyzka IS
BEGIN
    UPDATE Pracownicy
    SET placa_pod = placa_pod * 1.1;
END Podwyzka;

-- 0.1
CREATE OR REPLACE PROCEDURE Podwyzka(pIdPrac IN NUMBER, pProcent IN NUMBER DEFAULT 10) IS
BEGIN
    UPDATE Pracownicy
    SET placa_pod = placa_pod * (1 + pProcent / 100)
    WHERE id_prac = pIdPrac;
END Podwyzka;

-- 0.2
CREATE OR REPLACE PROCEDURE Podwyzka(pIdPrac IN NUMBER,
                                     pProcent IN NUMBER DEFAULT 10,
                                     pPensjaPoPodwyzce OUT NUMBER) IS
BEGIN
    UPDATE Pracownicy
    SET placa_pod = placa_pod * (1 + pProcent / 100)
    WHERE id_prac = pIdPrac
    RETURNING placa_pod INTO pPensjaPoPodwyzce;
END Podwyzka;

-- 0.3
CREATE FUNCTION IluPracownikow(pIdZesp IN NUMBER)
    RETURN NATURAL IS
    vIluPracownikow NATURAL;
BEGIN
    SELECT COUNT(*)
    INTO vIluPracownikow
    FROM Pracownicy
    WHERE id_zesp = pIdZesp;

    RETURN vIluPracownikow;
END IluPracownikow;

-- 1. Utwórz procedurę  NowyPracownik,  która  będzie  służyła  do  wstawiania  danych  nowych
-- pracowników. Procedura powinna przyjmować jako parametr nazwisko nowego pracownika, nazwę
-- zespołu, nazwisko szefa i wartość płacy podstawowej. Domyślną datą zatrudnienia pracownika
-- powinna być bieżąca data, domyślnym etatem STAZYSTA.

CREATE OR REPLACE PROCEDURE NowyPracownik(pNazwisko IN VARCHAR,
                                          pZespol IN VARCHAR,
                                          pSzef IN VARCHAR,
                                          pPlaca_pod IN NUMBER) IS
BEGIN
    INSERT INTO PRACOWNICY (ID_PRAC, NAZWISKO, ETAT, ID_SZEFA, ZATRUDNIONY, PLACA_POD, ID_ZESP)
    VALUES ((Select MAX(ID_PRAC) FROM PRACOWNICY) + 10, pNazwisko, 'STAZYSTA',
            (SELECT id_prac FROM PRACOWNICY WHERE NAZWISKO = pSzef), CURRENT_DATE, pPlaca_pod,
            (SELECT ID_ZESP FROM ZESPOLY WHERE NAZWA = pZespol));
END;

-- test
EXEC NowyPracownik('DYNDALSKI','ALGORYTMY','BLAZEWICZ',250);
SELECT *
FROM Pracownicy
WHERE nazwisko = 'DYNDALSKI';

-- 2. Utwórz funkcję PlacaNetto, która dla podanej płacy brutto (parametr) i podanej stawki podatku
-- (parametr o wartości domyślnej 20%) wyliczy płacę netto.

CREATE OR REPLACE FUNCTION PlacaNetto(pPlaca IN NUMBER,
                                      pPodatek IN NUMBER DEFAULT 20)
    RETURN NUMBER IS
    vNetto NUMBER;
BEGIN
    vNetto := pPlaca * (100 - pPodatek) * 0.01;
    Return vNetto;
END;

-- test
SELECT nazwisko, placa_pod AS BRUTTO, PlacaNetto(placa_pod, 35) AS NETTO
FROM Pracownicy
WHERE etat = 'PROFESOR'
ORDER BY nazwisko;

-- 3. Utwórz funkcję Silnia, która dla danego n obliczy n! = 1 * 2 * ... * n (zastosuj iterację).
CREATE OR REPLACE FUNCTION Silnia(pN IN NUMBER)
    RETURN NUMBER IS
    vValue NUMBER DEFAULT 1;
BEGIN
    FOR i IN 1..pN
        LOOP
            vValue := vValue * i;
        END LOOP;
    Return vValue;
END;

-- test
SELECT Silnia(8)
FROM Dual;

-- 4. Utwórz funkcję SilniaRek, będącą rekurencyjną wersję funkcji Silnia.
CREATE OR REPLACE FUNCTION SilniaRek(pN IN NUMBER)
    RETURN NUMBER IS
BEGIN
    If (pN <= 1) THEN
        Return 1;
    Else
        Return pN * SilniaRek(pN - 1);
    end if;
END;

-- test
SELECT SilniaRek(10)
FROM DUAL;

-- 5. Utwórz funkcję IleLat, która wyliczy, ile lat upłynęło od daty, przekazanej jako parametr, do dnia
-- dzisiejszego. Następnie użyj tej funkcji do wyliczenia stażu pracy pracowników.
CREATE OR REPLACE FUNCTION IleLat(pData DATE)
    RETURN NUMBER IS
BEGIN
    Return Round((CURRENT_DATE - pData) / 365);
END;

-- test
SELECT nazwisko, zatrudniony, IleLat(zatrudniony) AS staz
FROM Pracownicy
WHERE placa_pod > 1000
ORDER BY nazwisko

-- 6. Utwórz pakiet Konwersja, zawierający funkcje Cels_To_Fahr (konwertującą skalę Celsjusza na
-- skalę  Fahrenheita)  i  Fahr_To_Cels (konwertującą  skalę  Fahrenheita  na  skalę  Celsjusza).

CREATE OR REPLACE PACKAGE Konwersja IS
    FUNCTION Cels_To_Fahr(pTemp NUMBER)
        RETURN DOUBLE PRECISION;
    FUNCTION Fahr_To_Cels(pTemp NUMBER)
        RETURN DOUBLE PRECISION;
END Konwersja;

CREATE OR REPLACE PACKAGE BODY Konwersja IS
    FUNCTION Cels_To_Fahr(pTemp NUMBER)
        RETURN DOUBLE PRECISION IS
        vRetTemp DOUBLE PRECISION;
    BEGIN
        vRetTemp := 9 / 5 * pTemp + 32;
        Return vRetTemp;
    END Cels_To_Fahr;

    FUNCTION Fahr_To_Cels(pTemp NUMBER)
        RETURN DOUBLE PRECISION IS
        vRetTemp DOUBLE PRECISION;
    BEGIN
        vRetTemp := 5 / 9 * (pTemp - 32);
        Return vRetTemp;
    END Fahr_To_Cels;
END Konwersja;

-- test
SELECT Konwersja.Fahr_To_Cels(212) AS CELSJUSZ
FROM Dual;
SELECT Konwersja.Cels_To_Fahr(0) AS FAHRENHEIT
FROM Dual;

-- 7. Przetestuj działanie zmiennych pakietowych. W tym celu utwórz pakiet o nazwie Zmienne, w  jego
-- specyfikacji zadeklaruj:
-- zmienną pakietową vLicznik typu numerycznego, zmienną zainicjalizuj wartością 0,
-- procedury: ZwiekszLicznik, ZmniejszLicznik oraz funkcję PokazLicznik

CREATE OR REPLACE PACKAGE Zmienne IS
    PROCEDURE ZwiekszLicznik;
    PROCEDURE ZmniejszLicznik;
    FUNCTION PokazLicznik
        RETURN NUMERIC;
END Zmienne;

CREATE OR REPLACE PACKAGE BODY Zmienne IS
    vLicznik NUMERIC;
    PROCEDURE ZwiekszLicznik IS
    BEGIN
        vLicznik := vLicznik + 1;
        DBMS_OUTPUT.PUT_LINE('Zwiększono');
    END ZwiekszLicznik;
    PROCEDURE ZmniejszLicznik IS
    BEGIN
        vLicznik := vLicznik - 1;
        DBMS_OUTPUT.PUT_LINE('Zmniejszono');
    END ZmniejszLicznik;
    FUNCTION PokazLicznik
        RETURN NUMERIC IS
    BEGIN
        RETURN vLicznik;
    END PokazLicznik;
BEGIN
    vLicznik := 1;
    DBMS_OUTPUT.PUT_LINE('Zainicjalizowano');
END Zmienne;

-- test
BEGIN
    Zmienne.ZwiekszLicznik;
    DBMS_OUTPUT.PUT_LINE(Zmienne.PokazLicznik);
    Zmienne.ZwiekszLicznik;
    DBMS_OUTPUT.PUT_LINE(Zmienne.PokazLicznik);
END;

-- 8. Zaprojektuj  i  zaimplementuj  pakiet  IntZespoly. Pakiet ten będzie swego rodzaju interfejsem
-- użytkownika  do  tabeli  Zespoly.  Używając  podprogramów  z  tego  pakietu  użytkownik,  bez
-- konieczności użycia poleceń SQL, ma mieć możliwość:
-- dodania nowego zespołu (procedura),
-- usunięcia zespołu o wskazanym identyfikatorze (procedura),
-- usunięcia zespołu o wskazanej nazwie (procedura),
-- modyfikacji danych (nazwy i adresu) wskazanego przez identyfikator zespołu (procedura),
-- uzyskania identyfikatora zespołu o podanej nazwie (funkcja),
-- uzyskania nazwy zespołu o podanym identyfikatorze (funkcja),
-- uzyskania adresu zespołu o podanym identyfikatorze (funkcja).

CREATE OR REPLACE PACKAGE IntZespoly IS
    PROCEDURE DodajZespol(pId_zesp ZESPOLY.ID_ZESP%TYPE, pNazwa ZESPOLY.NAZWA%TYPE, pAdres ZESPOLY.ADRES%TYPE);
    PROCEDURE UsunZespol(pId_zesp ZESPOLY.ID_ZESP%TYPE);
    PROCEDURE UsunZespol(pNazwa ZESPOLY.NAZWA%TYPE);
    PROCEDURE EdytujZespol(pId_zesp ZESPOLY.ID_ZESP%TYPE, pNazwa ZESPOLY.NAZWA%TYPE, pAdres ZESPOLY.ADRES%TYPE);
    FUNCTION PodajZespolId(pNazwa ZESPOLY.NAZWA%TYPE) RETURN ZESPOLY.ID_ZESP%TYPE;
    FUNCTION PodajZespolNazwa(pId_zesp ZESPOLY.ID_ZESP%TYPE) RETURN ZESPOLY.NAZWA%TYPE;
    FUNCTION PodajZespolAdres(pId_zesp ZESPOLY.ID_ZESP%TYPE) RETURN ZESPOLY.NAZWA%TYPE;
END IntZespoly;

CREATE OR REPLACE PACKAGE BODY IntZespoly IS
    PROCEDURE DodajZespol(pId_zesp ZESPOLY.ID_ZESP%TYPE, pNazwa ZESPOLY.NAZWA%TYPE, pAdres ZESPOLY.ADRES%TYPE) IS
    BEGIN
        INSERT INTO ZESPOLY(ID_ZESP, NAZWA, ADRES)
        VALUES (pId_zesp, pNazwa, pAdres);
    END DodajZespol;
    PROCEDURE UsunZespol(pId_zesp ZESPOLY.ID_ZESP%TYPE) IS
    BEGIN
        DELETE
        FROM ZESPOLY
        WHERE ID_ZESP = pId_zesp;
    END UsunZespol;
    PROCEDURE UsunZespol(pNazwa ZESPOLY.NAZWA%TYPE) IS
    BEGIN
        DELETE
        FROM ZESPOLY
        WHERE NAZWA = pNazwa;
    END UsunZespol;
    PROCEDURE EdytujZespol(pId_zesp ZESPOLY.ID_ZESP%TYPE, pNazwa ZESPOLY.NAZWA%TYPE, pAdres ZESPOLY.ADRES%TYPE) IS
    BEGIN
        UPDATE ZESPOLY
        SET NAZWA = pNazwa,
            ADRES = pAdres
        WHERE ID_ZESP = pId_zesp;
    END EdytujZespol;
    FUNCTION PodajZespolId(pNazwa ZESPOLY.NAZWA%TYPE) RETURN ZESPOLY.ID_ZESP%TYPE IS
        vID ZESPOLY.ID_ZESP%TYPE;
    BEGIN
        SELECT ID_ZESP INTO vID FROM ZESPOLY WHERE NAZWA = pNazwa;
        RETURN vID;
    END PodajZespolId;
    FUNCTION PodajZespolNazwa(pId_zesp ZESPOLY.ID_ZESP%TYPE) RETURN ZESPOLY.NAZWA%TYPE IS
        vNazwa ZESPOLY.NAZWA%TYPE;
    BEGIN
        SELECT NAZWA INTO vNazwa FROM ZESPOLY WHERE ID_ZESP = pId_zesp;
        RETURN vNazwa;
    END PodajZespolNazwa;
    FUNCTION PodajZespolAdres(pId_zesp ZESPOLY.ID_ZESP%TYPE) RETURN ZESPOLY.NAZWA%TYPE IS
        vAdres ZESPOLY.ADRES%TYPE;
    BEGIN
        SELECT ADRES INTO vAdres FROM ZESPOLY WHERE ID_ZESP = pId_zesp;
        RETURN vAdres;
    END PodajZespolAdres;
END IntZespoly;

-- 9. Wyświetl listę procedur, funkcji i pakietów ze swojego schematu. Sprawdź ich statusy. Spróbuj
-- wyświetlić ich kody źródłowe.
SELECT object_name, status, object_type
FROM User_Objects
WHERE object_type = 'PROCEDURE'
   OR object_type = 'FUNCTION'
ORDER BY object_name;

-- 10. Usuń  procedury: Silnia, SilniaRek oraz funkcję  IleLat (utworzyłaś/eś  je  w  zadaniach
-- dotyczących procedur i funkcji).
DROP PROCEDURE Silnia;
DROP FUNCTION SilniaRek;
DROP FUNCTION IleLat;

-- 11. Usuń pakiet Konwersja.
DROP PACKAGE Konwersja;