-- 1. Zdefiniuj anonimowy blok, w którym za pomocą kursora wyświetlisz na konsoli nazwiska i daty
-- zatrudnienia wszystkich asystentów. Wykorzystaj polecenia OPEN, FETCH, CLOSE.

DECLARE
    CURSOR cPracownicy IS
        SELECT nazwisko, zatrudniony
        FROM Pracownicy
        WHERE ETAT = 'ASYSTENT'
        ORDER BY nazwisko;
    vNazwisko    Pracownicy.nazwisko%TYPE;
    vZatrudniony Pracownicy.zatrudniony%TYPE;
BEGIN
    OPEN cPracownicy;
    LOOP
        FETCH cPracownicy INTO vNazwisko, vZatrudniony;
        EXIT WHEN cPracownicy%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(vNazwisko || ' pracuje od ' || vZatrudniony);
    END LOOP;
    CLOSE cPracownicy;
END;

-- 2. Zdefiniuj anonimowy blok, w którym, przy użyciu kursora, wyświetlisz trzech  najlepiej zarabiających
-- pracowników. Posłuż się atrybutem kursora %ROWCOUNT.

DECLARE
    CURSOR cPracownicy IS
        SELECT nazwisko
        FROM Pracownicy
        ORDER BY placa_pod + coalesce(PLACA_DOD, 0);
    vNazwisko PRACOWNICY.nazwisko%TYPE;
BEGIN
    OPEN cPracownicy;
    LOOP
        FETCH cPracownicy INTO vNazwisko;
        EXIT WHEN cPracownicy%ROWCOUNT = 4;
        DBMS_OUTPUT.PUT_LINE(vNazwisko);
    END LOOP;
    Close cPracownicy;
end;

-- 3. Zdefiniuj  anonimowy  blok  z  kursorem,  który  pozwoli  Ci  zwiększyć  o  20%  płacę  podstawową
-- pracowników zatrudnionych w poniedziałek. Posłuż się pętlą FOR z kursorem.

DECLARE
    CURSOR cPracownicy IS
        SELECT id_prac, nazwisko, placa_pod, zatrudniony
        FROM PRACOWNICY;
BEGIN
    FOR vPracownik IN cPracownicy
        LOOP
            UPDATE Pracownicy
            SET placa_pod = 1.2 * placa_pod
            WHERE id_prac = vPracownik.id_prac
              AND TO_CHAR(vPracownik.zatrudniony, 'DAY') = 'PONIEDZIAŁEK';
        end loop;
end;

-- 4. Zdefiniuj  anonimowy  blok  z  kursorem,  który  posłuży  do  dokonania  następującej  modyfikacji:
-- pracownikom zespołu ALGORYTMY podnieś płacę dodatkową o 100 złotych, pracownikom zespołu
-- ADMINISTRACJA podnieś płacę dodatkową o 150 złotych a z pozostałych zespołów usuń stażystów.

DECLARE
    CURSOR cPracownicy IS
        SELECT P.*, Z.nazwa
        FROM PRACOWNICY P
                 LEFT JOIN ZESPOLY Z on P.ID_ZESP = Z.ID_ZESP
            FOR UPDATE;
BEGIN
    FOR vPracownik in cPracownicy
        LOOP
            IF vPracownik.NAZWA = 'ALGORYTMY' THEN
                UPDATE PRACOWNICY
                SET PLACA_POD = PLACA_POD + 100
                WHERE CURRENT OF cPracownicy;
            ELSIF vPracownik.NAZWA = 'ADMINISTRACJA' THEN
                UPDATE PRACOWNICY
                SET PLACA_POD = PLACA_POD + 150
                WHERE CURRENT OF cPracownicy;
            ELSE
                UPDATE PRACOWNICY
                SET ID_ZESP = ''
                WHERE CURRENT OF cPracownicy;
            END IF;
        end loop;
end;

-- 5. Utwórz procedurę PokazPracownikowEtatu, która dla przekazanej przez parametr nazwy etatu
-- wyświetli na konsoli nazwiska wszystkich pracowników posiadających dany etat. Zastosuj pętlę FOR
-- z kursorem sparametryzowanym.

CREATE OR REPLACE PROCEDURE PokazPracownikowEtatu(vEtat IN PRACOWNICY.Etat%TYPE) IS
    CURSOR cPracownicy(vEtat PRACOWNICY.Etat%TYPE) IS
        SELECT NAZWISKO
        FROM PRACOWNICY
        WHERE ETAT = vEtat;
BEGIN
    FOR vPracownik IN cPracownicy(vEtat)
        LOOP
            DBMS_OUTPUT.PUT_LINE(vPracownik.NAZWISKO);
        end loop;
end PokazPracownikowEtatu;

-- test
BEGIN
    PokazPracownikowEtatu('PROFESOR');
END;

-- 6. Napisz  procedurę RaportKadrowy, która wyświetli na ekranie zestawienie pracowników według
-- etatów w określonym formacie

CREATE OR REPLACE PROCEDURE RaportKadrowy IS
    CURSOR cPracownicy(vEtat PRACOWNICY.etat%TYPE) IS
        SELECT nazwisko, placa_pod, placa_dod
        FROM PRACOWNICY
        WHERE Etat = vEtat;
    CURSOR cEtat IS
        SELECT NAZWA
        FROM ETATY;
    vVal NUMBER := 0;
    vCNT NUMBER := 0;
    vAVG NUMBER := 0;
BEGIN
    FOR vEtat IN cEtat
        LOOP
            DBMS_OUTPUT.PUT_LINE('Etat: ' || vEtat.Nazwa);
            DBMS_OUTPUT.PUT_LINE('------------------------------');
            FOR vPracownik in cPracownicy(vEtat.NAZWA)
                LOOP
                    vVal := vPracownik.PLACA_POD + COALESCE(vPracownik.PLACA_DOD, 0);
                    DBMS_OUTPUT.PUT_LINE(vCNT + 1 || '. ' || vPracownik.NAZWISKO || ', pensja: ' || vVal);
                    vAVG := vAVG + vVal;
                    vCNT := vCNT + 1;
                end loop;
            vAVG := vAVG / vCNT;
            DBMS_OUTPUT.PUT_LINE('Liczba pracowników: ' || vCNT);
            DBMS_OUTPUT.PUT_LINE('Średnia pensja: ' || vAVG);
            DBMS_OUTPUT.PUT_LINE(' ');
            vCNT := 0;
            vAVG := 0;
        end loop;
end RaportKadrowy;

-- test
BEGIN
    RAPORTKADROWY();
END;

-- 7. Zmodyfikuj procedury pakietu IntZespoly, które pozwalają  na  wstawienie,  modyfikację
-- i usuwanie wskazanego zespołu. Używając kursora niejawnego zaimplementuj w tych procedurach
-- mechanizm wypisujący na konsoli odpowiedni komunikat w sytuacji, gdy nie udało się wstawić lub
-- usunąć danych zespołu.

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
        IF SQL%FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Dodanych rekordów: ' || SQL%ROWCOUNT);
        ELSE
            DBMS_OUTPUT.PUT_LINE('Nie wstawiono żadnego rekordu!');
        END IF;
    END DodajZespol;
    PROCEDURE UsunZespol(pId_zesp ZESPOLY.ID_ZESP%TYPE) IS
    BEGIN
        DELETE
        FROM ZESPOLY
        WHERE ID_ZESP = pId_zesp;
        DBMS_OUTPUT.PUT_LINE('Liczba usuniętych rekordów: ' || SQL%ROWCOUNT);
    END UsunZespol;
    PROCEDURE UsunZespol(pNazwa ZESPOLY.NAZWA%TYPE) IS
    BEGIN
        DELETE
        FROM ZESPOLY
        WHERE NAZWA = pNazwa;
        DBMS_OUTPUT.PUT_LINE('Liczba usuniętych rekordów: ' || SQL%ROWCOUNT);
    END UsunZespol;
    PROCEDURE EdytujZespol(pId_zesp ZESPOLY.ID_ZESP%TYPE, pNazwa ZESPOLY.NAZWA%TYPE, pAdres ZESPOLY.ADRES%TYPE) IS
    BEGIN
        UPDATE ZESPOLY
        SET NAZWA = pNazwa,
            ADRES = pAdres
        WHERE ID_ZESP = pId_zesp;
        IF SQL%FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Zmodyfikowanych rekordów: ' || SQL%ROWCOUNT);
        ELSE
            DBMS_OUTPUT.PUT_LINE('Nie zmodyfikowano żadnego rekordu!');
        END IF;
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

-- 8. Zaimplementuj  w  pakiecie  IntZespoly  mechanizm kontroli poprawności parametrów, z jakimi
-- użytkownik wywołuje  poszczególne  funkcje  i  procedury  pakietu.  Zwróć  uwagę  na  następujące
-- sytuacje błędne:
-- a) podanie w wywołaniu procedury lub funkcji nazwy zespołu, który nie istnieje w tabeli Zespoly,
-- b) podanie w wywołaniu procedury lub funkcji identyfikatora zespołu, który nie istnieje w tabeli
-- Zespoly,
-- c) powielenie wartości identyfikatora zespoły przy definicji nowej zespołu.
-- Samodzielnie zaproponuj numerację błędów

CREATE OR REPLACE PACKAGE IntZespoly IS
    PROCEDURE DodajZespol(pId_zesp ZESPOLY.ID_ZESP%TYPE, pNazwa ZESPOLY.NAZWA%TYPE, pAdres ZESPOLY.ADRES%TYPE);
    PROCEDURE UsunZespol(pId_zesp ZESPOLY.ID_ZESP%TYPE);
    PROCEDURE UsunZespol(pNazwa ZESPOLY.NAZWA%TYPE);
    PROCEDURE EdytujZespol(pId_zesp ZESPOLY.ID_ZESP%TYPE, pNazwa ZESPOLY.NAZWA%TYPE, pAdres ZESPOLY.ADRES%TYPE);
    FUNCTION PodajZespolId(pNazwa ZESPOLY.NAZWA%TYPE) RETURN ZESPOLY.ID_ZESP%TYPE;
    FUNCTION PodajZespolNazwa(pId_zesp ZESPOLY.ID_ZESP%TYPE) RETURN ZESPOLY.NAZWA%TYPE;
    FUNCTION PodajZespolAdres(pId_zesp ZESPOLY.ID_ZESP%TYPE) RETURN ZESPOLY.NAZWA%TYPE;
    exNoTeamData EXCEPTION;
END IntZespoly;

CREATE OR REPLACE PACKAGE BODY IntZespoly IS
    PROCEDURE DodajZespol(pId_zesp ZESPOLY.ID_ZESP%TYPE, pNazwa ZESPOLY.NAZWA%TYPE, pAdres ZESPOLY.ADRES%TYPE) IS
    BEGIN
        INSERT INTO ZESPOLY(ID_ZESP, NAZWA, ADRES)
        VALUES (pId_zesp, pNazwa, pAdres);
        IF SQL%FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Dodanych rekordów: ' || SQL%ROWCOUNT);
        ELSE
            DBMS_OUTPUT.PUT_LINE('Nie wstawiono żadnego rekordu!');
            Raise exNoTeamData;
        END IF;
    EXCEPTION
        WHEN exNoTeamData THEN
            DBMS_OUTPUT.PUT_LINE('ID występujące w bazie danych');
    END DodajZespol;
    PROCEDURE UsunZespol(pId_zesp ZESPOLY.ID_ZESP%TYPE) IS
    BEGIN
        DELETE
        FROM ZESPOLY
        WHERE ID_ZESP = pId_zesp;
        DBMS_OUTPUT.PUT_LINE('Liczba usuniętych rekordów: ' || SQL%ROWCOUNT);
        IF SQL%NOTFOUND THEN
            Raise exNoTeamData;
        end if;
    EXCEPTION
        WHEN exNoTeamData THEN
            DBMS_OUTPUT.PUT_LINE('ID nie występuje w bazie danych');
    END UsunZespol;
    PROCEDURE UsunZespol(pNazwa ZESPOLY.NAZWA%TYPE) IS
    BEGIN
        DELETE
        FROM ZESPOLY
        WHERE NAZWA = pNazwa;
        DBMS_OUTPUT.PUT_LINE('Liczba usuniętych rekordów: ' || SQL%ROWCOUNT);
        IF SQL%NOTFOUND THEN
            Raise exNoTeamData;
        end if;
    EXCEPTION
        WHEN exNoTeamData THEN
            DBMS_OUTPUT.PUT_LINE('Nazwa nie występuje w bazie danych');
    END UsunZespol;
    PROCEDURE EdytujZespol(pId_zesp ZESPOLY.ID_ZESP%TYPE, pNazwa ZESPOLY.NAZWA%TYPE, pAdres ZESPOLY.ADRES%TYPE) IS
    BEGIN
        UPDATE ZESPOLY
        SET NAZWA = pNazwa,
            ADRES = pAdres
        WHERE ID_ZESP = pId_zesp;
        IF SQL%FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Zmodyfikowanych rekordów: ' || SQL%ROWCOUNT);
        ELSE
            DBMS_OUTPUT.PUT_LINE('Nie zmodyfikowano żadnego rekordu!');
            Raise exNoTeamData;
        END IF;
    EXCEPTION
        WHEN exNoTeamData THEN
            DBMS_OUTPUT.PUT_LINE('ID nie występuje w bazie danych');
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