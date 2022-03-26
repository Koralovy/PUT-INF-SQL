-- Sprawd?, czy rzeczywi?cie pracujesz w dwóch ró?nych sesjach (czy te? nowo otwarta zak?adka nie 
-- nale?y do tej samej sesji co zak?adka, w której do tej pory pracowa?a?/-e?).
select sys_context('USERENV', 'SID') from dual;

-- ID 594 oraz 410

--3. W sesji A rozpocznij now? transakcj? poleceniem, które podniesie p?ac? podstawow? pracownikowi 
--o nazwisku HAPKE o 100 z?. Sprawd?, jakie blokady zosta?y za?o?one przez t? transakcj?. 
UPDATE PRACOWNICY
    SET PLACA_POD = PLACA_POD + 100
    WHERE NAZWISKO = 'HAPKE';

SELECT * FROM table(sbd.blokady);

--4. W  sesji  B  rozpocznij now? transakcj?. Najpierw odczytaj warto?? p?acy podstawowej pracownika 
--o nazwisku  HAPKE.  Czy  zaobserwowa?a?/-e?  zmiany,  wprowadzone przez  aktywn?  transakcj? 
--w sesji 1? Nast?pnie spróbuj pracownikowi HAPKE podnie?? p?ac? dodatkow? o 50 z?. Co teraz si? 
--dzieje z sesj?? Czy obserwujesz efekt „zawieszenia si?” narz?dzia? 
SELECT PLACA_POD
    FROM PRACOWNICY
    WHERE NAZWISKO = 'HAPKE';

UPDATE PRACOWNICY
    SET PLACA_POD = PLACA_POD + 50
    WHERE NAZWISKO = 'HAPKE';

-- Zawieszenie widoczne

--Wró? do sesji A. Wykonaj ponownie zapytanie wy?wietlaj?ce blokady dla sesji A. Czy widzisz ró?nic? 
--(zwró? uwag? na kolumn? czy_blokuje_inna)?  Wykonaj  ponownie  zapytanie  o  blokady,  tym  razem 
--jako parametr podaj identyfikator sesji B. Na uzyskanie jakiej blokady czeka sesja B?
SELECT * FROM table(sbd.blokady);
SELECT * FROM table(sbd.blokady (410));

--W  sesji  A  rozpocznij now? transakcj? i okre?l jej poziom izolacji na READ COMMITED. Nast?pnie 
--odczytaj w tej transakcji warto?? p?acy podstawowej pracownika o nazwisku KONOPKA. Zapami?taj 
--odczytan? warto??. 
ALTER SESSION SET ISOLATION_LEVEL = READ COMMITTED;

SELECT PLACA_POD
    FROM PRACOWNICY
    WHERE NAZWISKO = 'KONOPKA'; --1920
    
--W sesji B równie?  rozpocznij  now?  transakcj?  z  poziomem  izolacji READ COMMITED, 
--a nast?pnie odczytaj warto?? p?acy podstawowej pracownika KONOPKA. W kolejnym poleceniu 
--transakcji  ustaw  p?ac?  podstawow?  pracownika  KONOPKA  na  warto??  wi?ksz?  
--o 300 z? od warto?ci odczytanej przez zapytanie  (Uwaga: docelow? warto?? p?acy oblicz w pami?ci, 
--nie korzystaj z konstrukcji placa_pod=placa_pod+x).  Zako?cz  transakcj?  zatwierdzeniem 
--wprowadzonych zmian.

ALTER SESSION SET ISOLATION_LEVEL = READ COMMITTED;

SELECT PLACA_POD
    FROM PRACOWNICY
    WHERE NAZWISKO = 'KONOPKA';  --1920

UPDATE PRACOWNICY 
    SET PLACA_POD = 2220
    WHERE NAZWISKO = 'KONOPKA';

COMMIT;

--W  sesji  A  wykonaj polecenie, które ustawi pracownikowi KONOPKA p?ac? podstawow? na warto?? 
--mniejsz? o 200 z? od warto?ci odczytanej  w  punkcie  1  (Uwaga: docelow? warto?? p?acy oblicz 
--w pami?ci, nie korzystaj z konstrukcji placa_pod=placa_pod-x).  Czy polecenie zako?czy?o si? 
--powodzeniem? Zako?cz transakcj? zatwierdzeniem wprowadzonych zmian.
UPDATE PRACOWNICY 
    SET PLACA_POD = 1720
    WHERE NAZWISKO = 'KONOPKA';

COMMIT
-- Commit complete.

--Okre?l, jak? anomali? zasymulowa?y operacje w p. 1, 2 i 3. Jaka jest aktualna p?aca podstawowa 
--pracownika  KONOPKA?  Jaka  by?aby  warto??  p?acy  tego  pracownika  w  sytuacji  sekwencyjnego 
--wykonania obu transakcji? 
-- transakcja B nadpisana przez A

--Wykonaj  ponownie  ?wiczenie,  tym  razem  okre?laj?c  poziom  izolacji  transakcji  w  sesji  A na 
--SERIALIZABLE. Skomentuj zaobserwowane wynik

ALTER SESSION SET ISOLATION_LEVEL = SERIALIZABLE;
-- A nie mog?o zaktualizowa? danych


-- Anomalia skro?nego zapisu na poziomie izolacji SERIALIZABLE w Oracle
--1. W sesji A rozpocznij now? transakcj? i okre?l jej poziom izolacji na SERIALIZABLE.  
--2. W sesji B rozpocznij now? transakcj? i okre?l jej poziom izolacji na SERIALIZABLE.
ALTER SESSION SET ISOLATION_LEVEL = SERIALIZABLE;

-- 5. Zatwierd? transakcje w obu sesjach, a nast?pnie sprawd? aktualne p?ace podstawowe pracowników 
--SLOWINSKI i BRZEZINSKI. Czy  taki stan  móg?by zosta? osi?gni?ty  w przypadku sekwencyjnego 
--wykonania transakcji?
SELECT NAZWISKO, PLACA_POD FROM PRACOWNICY;
-- pracownicy zamienili si? p?acami, sekwencyjnie niemo?liwe 


-- ZAKLESZCZENIE
--1. W sesji A podnie? o 10 z? p?ac? podstawow? pracownika o identyfikatorze 210 nie ko?cz?c transakcji. 
UPDATE PRACOWNICY
    SET PLACA_POD = PLACA_POD + 10
    WHERE ID_PRAC = 210;
    
--2. W sesji B podnie? o 10 z? p?ac? podstawow? pracownika o identyfikatorze 220 nie ko?cz?c transakcji. 
UPDATE PRACOWNICY
    SET PLACA_POD = PLACA_POD + 10
    WHERE ID_PRAC = 220;
    
--3. W sesji A spróbuj podnie?? o 10 z? p?ac? podstawow? pracownika o identyfikatorze 220. 
UPDATE PRACOWNICY
    SET PLACA_POD = PLACA_POD + 10
    WHERE ID_PRAC = 220;

--4. W sesji B spróbuj podnie?? o 10 z? p?ac? podstawow? pracownika o identyfikatorze 210. Co si? sta?o? 
UPDATE PRACOWNICY
    SET PLACA_POD = PLACA_POD + 10
    WHERE ID_PRAC = 210;
-- Wyst?pi? b??d "ORA-00060: podczas oczekiwania na zasób wykryto zakleszczenie"
    

--5. Wycofaj transakcj?, w której wykryte zosta?o zakleszczenie. Zatwierd? drug? transakcj?.
ROLLBACK;
COMMIT;
Transakcja A - zakleszczona