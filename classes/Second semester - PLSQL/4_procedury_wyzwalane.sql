-- 0. Utwórz ten wyzwalacz w swoim schemacie i zaobserwuj jego działanie (nie zapomnij
-- o włączeniu w narzędziu trybu wypisywania komunikatów na konsoli)
CREATE OR REPLACE TRIGGER PoPoleceniu
    AFTER INSERT OR DELETE OR UPDATE
    ON Pracownicy
DECLARE
    vKomunikat VARCHAR(50);
BEGIN
    CASE
        WHEN INSERTING THEN
            vKomunikat := 'Wstawiono dane do tabeli Pracownicy!';
        WHEN DELETING THEN
            vKomunikat := 'Usunięto dane z tabeli Pracownicy!';
        WHEN UPDATING THEN
            vKomunikat := 'Zmieniono dane tabeli Pracownicy!';
        END CASE;
    DBMS_OUTPUT.PUT_LINE(vKomunikat);
END;

-- test
BEGIN
    UPDATE PRACOWNICY
    SET PLACA_POD = 2226.00
    WHERE NAZWISKO = 'WEGLARZ';
end;

-- 1. Zdefiniuj wyzwalacz polecenia o nazwie LogujOperacje,  który  będzie  zapisywał  w  tablicy
-- DziennikOperacji informacje  o  każdej  operacji  DML,  jaka  została  wykonana  na  tabeli  Zespoly
-- w Twoim  schemacie.  Dla każdej operacji w tabeli DziennikOperacji  powinna pojawić się data jej
-- realizacji, typ operacji (UPDATE, INSERT lub DELETE), nazwa tabeli, której operacja dotyczy (czyli
-- Zespoly)  oraz liczba rekordów w tabeli po wykonaniu operacji. Tabelę DziennikOperacji  zaprojektuj
-- i utwórz  samodzielnie. Sprawdź  działanie  wyzwalacza,  wykonując  kilka  operacji  DML  na  tabeli
-- Zespoly.

CREATE TABLE DziennikOperacji
(
    id      number generated always as identity,
    created date          not null,
    log     varchar2(255) not null
);

CREATE OR REPLACE TRIGGER LogujOperacje
    AFTER UPDATE OR INSERT OR DELETE
    ON ZESPOLY
DECLARE
    vKomunikat DziennikOperacji.log%type;
    vElements  NUMBER;
BEGIN
    SELECT COUNT(*) INTO vElements FROM ZESPOLY;
    CASE
        WHEN INSERTING THEN
            vKomunikat :=
                        'Wstawiono dane do tabeli Zespoły! Po operacji w tabeli została następująca liczba rekordów: ' ||
                        vElements;
        WHEN DELETING THEN
            vKomunikat :=
                        'Usunięto dane z tabeli Zespoły! Po operacji w tabeli została następująca liczba rekordów: ' ||
                        vElements;
        WHEN UPDATING THEN
            vKomunikat := 'Zmieniono dane tabeli Zespoły! Po operacji w tabeli została następująca liczba rekordów: ' ||
                          vElements;
        END CASE;

    Insert Into DziennikOperacji(created, log)
    values (current_date, vKomunikat);
    DBMS_OUTPUT.PUT_LINE(vKomunikat);

end;

-- test
BEGIN
    UPDATE ZESPOLY
    SET ADRES = 'MojAdres'
    WHERE ID_ZESP = 1234;
end;

-- tutorial
CREATE TRIGGER WymuszajPlace
    BEFORE INSERT OR UPDATE OF placa_pod
    ON Pracownicy
    FOR EACH ROW
    WHEN (NEW.etat IS NOT NULL)
DECLARE
    vPlacaMin Etaty.placa_min%TYPE;
    vPlacaMax Etaty.placa_max%TYPE;
BEGIN
    SELECT placa_min, placa_max
    INTO vPlacaMin, vPlacaMax
    FROM Etaty
    WHERE nazwa = :NEW.etat;

    IF :NEW.placa_pod NOT BETWEEN vPlacaMin AND vPlacaMax THEN
        RAISE_APPLICATION_ERROR(-20001, 'Płaca poza zakresem dla etatu!');
    END IF;
END;

-- 2. Zmodyfikuj wyzwalacz PokazPlace w taki sposób, aby działał on poprawnie również w sytuacjach,
-- gdy: (a) ustawimy pracownikowi płacę podstawową na wartość pustą (NULL), (b) pracownikowi,
-- który miał wartość pustą płacy podstawowej, ustawimy płacę na wartość różną od pustej.
CREATE OR REPLACE TRIGGER PokazPlace
    BEFORE UPDATE OF placa_pod
    ON Pracownicy
    FOR EACH ROW
    WHEN (OLD.placa_pod <> NEW.placa_pod OR NEW.PLACA_DOD is null OR OLD.PLACA_POD is null)
BEGIN
    DBMS_OUTPUT.PUT_LINE('Pracownik ' || :OLD.nazwisko);
    DBMS_OUTPUT.PUT_LINE('Płaca przed modyfikacją: ' || :OLD.placa_pod);
    DBMS_OUTPUT.PUT_LINE('Płaca po modyfikacji: ' || :NEW.placa_pod);
END;

UPDATE Pracownicy p
SET placa_pod =
        (SELECT MAX(placa_pod)
         FROM Pracownicy
         WHERE id_zesp = p.id_zesp)
WHERE id_zesp = 20;

-- 3. Zdefiniuj wierszowy wyzwalacz DML o nazwie UzupelnijPlace.  Wyzwalacz  będzie  "dbał"
-- o właściwe  wartości  płac:  podstawowej  i  dodatkowej  pracowników,  wstawianych  do  tabeli
-- Pracownicy. Jeśli użytkownik w poleceniu INSERT,  kierowanym  do  tabeli  Pracownicy,  nie  poda
-- wartości dla kolumn placa_pod lub placa_dod, wyzwalacz ma w tych kolumnach umieścić wartości,
-- odpowiednio: minimalną wartość płacy dla etatu, na którym zatrudniono pracownika, oraz  0.
-- Uwaga! Wyzwalacz powinien obsługiwać sytuację, w którym etat pracownika jest pusty. Wówczas
-- nie powinien weryfikować wartości płacy podstawowej. Sprawdź działanie wyzwalacza, wstawiając
-- kilka rekordów do tabeli Pracownicy.

CREATE OR REPLACE TRIGGER UzupelnijPlace
    AFTER INSERT
    ON PRACOWNICY
    FOR EACH ROW
    WHEN (new.PLACA_POD is null)
BEGIN
    IF :NEW.ETAT is not null then
        update PRACOWNICY
        set PLACA_pod = (Select min(placa_pod) from PRACOWNICY where ETAT = :NEW.ETAT),
            PLACA_DOD = 0

        WHERE ID_PRAC = :NEW.ID_PRAC;
    Else
        update PRACOWNICY
        set PLACA_pod = 0,
            PLACA_DOD = 0
        WHERE ID_PRAC = :NEW.ID_PRAC;
    end if;
end;

-- Sprawdź w tabeli Zespoly,  jaka  jest  obecnie  największa wartość  w  kolumnie  id_zesp. Następnie
-- utwórz  sekwencję  SEQ_Zespoly w  taki  sposób,  aby  generowała  kolejne  liczby  z krokiem 1,
-- rozpoczynając od liczby o 1 większej od tej, którą odczytałaś/eś z tabeli Zespoly.  Teraz  zdefiniuj
-- wyzwalacz  wierszowy  DML  o  nazwie UzupelnijID  dla  tabeli  Zespoly  dla  operacji  INSERT.
-- Wyzwalacz ma umożliwić definicję nowego zespołu w tabeli Zespoly  bez konieczności podawania
-- przez  użytkownika  wartości  dla  id_zesp (wyzwalacz ma ją  pobrać  z sekwencji SEQ_Zespoly).
-- Przetestuj działanie wyzwalacza dla poniższego polecenia:
-- INSERT INTO Zespoly(nazwa, adres) VALUES('NOWY', 'brak');

SELECT MAX(ID_ZESP)
FROM ZESPOLY;

CREATE SEQUENCE SEQ_Zespoly
    start with 1235
    increment by 1;

CREATE OR REPLACE TRIGGER UzupelnijID
    BEFORE INSERT
    ON ZESPOLY
    FOR EACH ROW
    WHEN (new.ID_ZESP is null)
BEGIN
    :new.ID_Zesp := SEQ_ZESPOLY.nextval;
end;

-- test
INSERT INTO Zespoly(nazwa, adres)
VALUES ('NOWY', 'brak');

-- 5. Zdefiniuj  perspektywę  Szefowie,  zawierającą  nazwisko  szefa  (kolumna  szef)  i  liczbę  jego
-- podwładnych (kolumna pracownicy).  Następnie utwórz  procedurę wyzwalaną,  która umożliwi, za
-- pomocą  powyższej  perspektywy,  usuwanie  szefów  wraz  z  kaskadowym  usunięciem  wszystkich
-- podwładnych danego szefa. Jeśli podwładny usuwanego szefa sam jest szefem innych pracowników,
-- przerwij działanie wyzwalacza błędem o numerze ORA-20001  i komunikacie „Jeden z podwładnych
-- usuwanego pracownika jest szefem innych pracowników. Usuwanie anulowane!”. Sprawdź działanie
-- wyzwalacza, wykorzystując poniższy przykładowy scenariusz


CREATE OR REPLACE VIEW Szefowie
    (szef, pracownicy) AS
SELECT p.nazwisko, Count(p2.nazwisko)
FROM PRACOWNICY p
         left join PRACOWNICY p2 on p.ID_PRAC = p2.ID_SZEFA
GROUP BY p.nazwisko
HAVING Count(p2.nazwisko) > 0
ORDER BY p.NAZWISKO;

CREATE OR REPLACE TRIGGER UsunSzefa
    INSTEAD OF DELETE
    on Szefowie
DECLARE
    non_empty_delete EXCEPTION;
    PRAGMA EXCEPTION_INIT (non_empty_delete, -20001);
    vId PRACOWNICY.ID_prac%Type;
BEGIN
    Select ID_PRAC INTO vId FROM PRACOWNICY Where NAZWISKO like :old.szef;
    for pracownik in (SELECT * FROM PRACOWNICY where ID_SZEFA = vId)
        loop
            delete
            from PRACOWNICY
            where ID_PRAC = pracownik.ID_PRAC;
        end loop;
    delete
    from PRACOWNICY
    WHERE ID_PRAC = vId;
EXCEPTION
    WHEN non_empty_delete then
        DBMS_OUTPUT.PUT_LINE('Jeden z podwładnych usuwanego pracownika jest szefem innych pracowników. Usuwanie anulowane!');
end;

-- test
SELECT *
FROM Szefowie;
SELECT *
FROM Pracownicy
WHERE id_prac = 140
   OR id_szefa = 140;
DELETE
FROM szefowie
WHERE szef = 'MORZY';
SELECT *
FROM pracownicy
WHERE id_prac = 140
   OR id_szefa = 140;

-- 6. Dodaj  do  relacji  Zespoly  nową kolumnę o nazwie liczba_pracownikow. Dla rekordu, opisującego
-- danych zespół, w tej kolumnie ma być przechowywana wartość określająca, ilu pracowników pracuje
-- w tym zespole. Następnie napisz zlecenie SQL (UPDATE), które zainicjuje początkowe wartości
-- dodanej  kolumny.  Napisz  wyzwalacz  wierszowy, który będzie pielęgnował wartość w tej kolumnie
-- przy wykonywaniu następujących operacji: (1) dodanie nowego pracownika do zespołu, (2) usunięcie
-- pracownika z zespołu, oraz (3) przesunięcie pracownika między zespołami. Przetestuj działanie
-- wyzwalacza. Pamiętaj o problemie mutacji tabeli.

ALTER TABLE ZESPOLY
    add liczba_pracownikow Number(20);

UPDATE ZESPOLY z
SET LICZBA_PRACOWNIKOW = COALESCE((Select COUNT(*) FROM PRACOWNICY p WhERE p.ID_ZESP = z.ID_ZESP group by p.ID_ZESP),
                                  0);

Select *
FROM ZESPOLY;

create or replace trigger LiczbaPracownikowZespoly
    AFTER INSERT OR DELETE OR UPDATE
    on PRACOWNICY
BEGIN
    Update ZESPOLY z
    SET LICZBA_PRACOWNIKOW = COALESCE(
            (Select COUNT(*) FROM PRACOWNICY p WhERE p.ID_ZESP = z.ID_ZESP group by p.ID_ZESP), 0);
end;

-- 7. W relacji Pracownicy usuń ograniczenie referencyjne FK_ID_SZEFA (klucz obcy między pracownikiem
-- a jego szefem), następnie utwórz je ponownie z cechą usuwania kaskadowego.
alter table PRACOWNICY
    drop constraint FK_ID_SZEFA;

alter table PRACOWNICY
    add constraint FK_ID_SZEFA
        foreign key (ID_SZEFA) references PRACOWNICY
            on delete cascade;

-- Zdefiniuj  teraz  wyzwalacz  wierszowy  o  nazwie  Usun_Prac. Wyzwalacz ma uruchamiać się po
-- wykonaniu operacji DELETE na relacji Pracownicy. Jedynym zadaniem wyzwalacza będzie wypisanie
-- na ekranie, za pomocą procedury DBMS_OUTPUT.PUT_LINE,  nazwiska  usuwanego  pracownika.
-- Przetestuj  działanie  wyzwalacza  usuwając  z  tabeli  Pracownicy rekord  opisujący  pracownika
-- o nazwisku MORZY. Nie zapomnij przed wykonaniem polecenia DELETE ustawić  zmiennej
-- SERVEROUTPUT na wartość ON. Po zakończeniu zadania wycofaj transakcję przy pomocy polecenia
-- ROLLBACK;

create or replace trigger UsunPrac
    BEFORE delete
    on PRACOWNICY
    for each row
begin
    DBMS_OUTPUT.PUT_LINE(:OLD.nazwisko);
end;

delete
from PRACOWNICY
where NAZWISKO like 'WEGLARZ';

-- 8. Wyłącz tymczasowo wszystkie wyzwalacze, jakie zdefiniowałaś/eś dla tabeli Pracownicy. Sprawdź
-- w słowniku bazy danych zawartość kolumny status  perspektywy  User_Triggers  dla  zablokowanych
-- wyzwalaczy. Sprawdź, czy rzeczywiście zablokowane wyzwalacze nie są uruchamiane w sytuacji
-- zajścia operacji dla tabeli Pracownicy.

alter table PRACOWNICY
    disable all triggers;

SELECT *
FROM User_Triggers
WHERE table_name IN ('PRACOWNICY', 'ZESPOLY')
ORDER BY table_name, trigger_name;

-- 9. Odczytaj ze słownika bazy danych nazwy wszystkich wyzwalaczy, jakie zdefiniowałaś/eś dla tabel
-- Zespoly i Pracownicy. Następnie usuń te wyzwalacze z bazy danych.

begin
    for x in (SELECT * FROM User_Triggers WHERE table_name IN ('PRACOWNICY', 'ZESPOLY'))
        loop
            EXECUTE IMMEDIATE 'DROP TRIGGER ' || x.trigger_name;
        end loop;
end;