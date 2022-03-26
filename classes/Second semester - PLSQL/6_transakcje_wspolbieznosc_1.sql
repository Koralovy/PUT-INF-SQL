-- DML
--2. Rozpocznij now? transakcj?  poleceniem  SQL,  które  w  relacji  PRACOWNICY  zmieni  pracownikowi  o 
--nazwisku MATYSIAK etat na ADIUNKT. 
UPDATE PRACOWNICY
    SET ETAT = 'ADIUNKT'
    WHERE NAZWISKO = 'MATYSIAK';

--3. Kolejnym  poleceniem  usu? z relacji PRACOWNICY  wszystkie  informacje  o  pracownikach  na  etacie 
--ASYSTENT.

DELETE
    FROM PRACOWNICY
    WHERE ETAT = 'ASYSTENT';
    
--4. Sprawd? za pomoc? odpowiedniego zapytania, czy wprowadzone przez Ciebie w dwóch poprzednich 
--krokach zmiany zawarto?ci bazy danych rzeczywi?cie si? dokona?y. 
SELECT * FROM PRACOWNICY WHERE ETAT = 'ASYSTENT';

--5. Zako?cz  transakcj?  z  wycofaniem  efektów  wszystkich  operacji,  jakie  mia?y  miejsce  
--w transakcji. Sprawd?, czy zmiany, wprowadzone w ramach transakcji, zosta?y anulowane.
ROLLBACK;
SELECT * FROM PRACOWNICY WHERE ETAT = 'ASYSTENT';

-- DDL
--1. Rozpocznij  now?  transakcj?,  wykonuj?c  polecenie  zwi?kszenia  p?acy  podstawowej  wszystkim 
--adiunktom  o  10%.  Sprawd?, czy  operacja zosta?a poprawnie wykonana (wykonaj odpowiednie 
--zapytanie). 
UPDATE PRACOWNICY
    SET PLACA_POD = PLACA_POD*1.1
    WHERE ETAT = 'ADIUNKT';
    
SELECT * FROM PRACOWNICY WHERE ETAT = 'ADIUNKT';

--2. Wykonaj  kolejne  polecenie,  które  dokona  modyfikacji  typu  kolumny  placa_dod w relacji 
--PRACOWNICY na number(7,2). 
ALTER TABLE PRACOWNICY
    MODIFY PLACA_DOD number(7,2);

--3. Spróbuj anulowa? zmiany, wprowadzone w punktach 1. i 2., wykonuj?c polecenie rollback. 
--Sprawd? efekty wykonania tego polecenia
ROLLBACK;

-- Punkty bezpiecze?stwa transakcji 

--1. Rozpocznij now? transakcj? poleceniem, które pracownikowi MORZY doda do p?acy dodatkowej 200 
--z?otych.  
UPDATE PRACOWNICY
    SET PLACA_DOD = PLACA_DOD + 200
    WHERE NAZWISKO = 'MORZY';
    
--2. Utwórz punkt bezpiecze?stwa S1. 
SAVEPOINT S1;

--3. Ustaw pracownikowi BIALY p?ac? dodatkow? w wysoko?ci 100 z?otych. 
UPDATE PRACOWNICY
    SET PLACA_DOD = 100
    WHERE NAZWISKO = 'BIALY';

--4. Utwórz punkt bezpiecze?stwa S2. 
SAVEPOINT S2;

--5. Usu? pracownika o nazwisku JEZIERSKI. 
DELETE 
    FROM PRACOWNICY
    WHERE NAZWISKO = 'JEZIERSKI';
    
--6. Wycofaj transakcj? do punktu S1 i zobacz zawarto?? relacji PRACOWNICY. 
ROLLBACK TO S1;
SELECT * FROM PRACOWNICY;

--7. Spróbuj wycofa? transakcj? do punktu S2. Czy polecenie zako?czy?o si? sukcesem? 
ROLLBACK TO S2;
-- nie, bo zosta? utworzony po S1

--8. Wycofaj ca?? transakcj?. 
ROLLBACK;

--9. Zako?cz sesj? bazodanow? w programie Oracle SQL Developer.
