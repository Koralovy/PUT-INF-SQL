 -- 1. Użytkownik A próbuje odczytać dane z relacji pracownicy należącej do użytkownika B i 
-- vice versa. 
SELECT * FROM INF145441.Pracownicy;

-- 2. Użytkownik B nadaje użytkownikowi A prawo odczytu danych z wasnej relacji 
--pracownicy.
GRANT SELECT ON INF145380.Pracownicy TO INF145441;

-- 3. Użytkownik  A  ponownie  próbujee  odczytać  dane z relacji pracownicy należącej do 
-- użytkownika B.
SELECT * FROM INF145441.Pracownicy;

-- 4. Użytkownik  A  nadaje  u?ytkownikowi B prawo modyfikowania atrybutów placa_pod  i 
-- placa_dod we własnej relacji pracownicy.
GRANT UPDATE(placa_pod, placa_dod) ON Pracownicy to INF145441;

-- 5. Użytkownik  B  próbuje  zwiększyć  o  100%  pace  podstawowe  pracowników  relacji  
-- pracownicy, nale??cej do u?ytkownika A. Czy mo?e to zrobi?? Nast?pnie u?ytkownik B 
-- pr??e ustawi? warto?? p?acy pracownika MORZY w relacji pracownicy u?ytkownika A 
-- na 2000. Czy ta operacja zako?czy?a si? sukcesem? Ostatecznie u?ytkownik B pr??e 
-- ustawi? wszystkim pracownikom w relacji pracownicy  u?ytkownika A p?ac? dodatkow? 
-- na 700. Czy operacja si? uda?a?

UPDATE INF145380.Pracownicy
SET placa_pod = placa_pod*2, placa_dod = placa_dod*2;
-- dziala

UPDATE INF145380.Pracownicy
SET placa_pod = 2000
WHERE nazwisko = 'MORZY';
-- dziala

UPDATE INF145380.Pracownicy
SET placa_dod = 700;
-- dziala

-- 6. Użytkownik B tworzy prywatny synonim dla relacji pracownicy nale??cej do A i ponawia 
-- ostatni? modyfikacj? z poprzedniego punktu, ustawiaj?c p?ace dodatkowe na 800, tym 
-- razem jednak u?ywaj?c w poleceniu synonimu.  Po zako?czeniu modyfikacji u?ytkownik 
-- B zatwierdza swoje zmiany poleceniem COMMIT.

CREATE SYNONYM synprac FOR INF145380.Pracownicy;

UPDATE synprac
SET placa_dod = 800;

Commit;

-- 7. Użytkownik  B  pr??e  odczyta?  dokonane  przez  siebie  zmiany  w  relacji  pracownicy 
-- u?ytkownika A
SELECT * FROM INF145380.Pracownicy;

-- 8. U?ytkownicy A i B ogl?daj? informacje ze s?ownika bazy danych dotycz?ce przyznanych 
-- uprawnie? obiektowych: 
select owner, table_name, grantee, grantor, privilege 
from   user_tab_privs; 
 
select table_name, grantee, grantor, privilege 
from   user_tab_privs_made;

select owner, table_name, grantor, privilege 
from   user_tab_privs_recd; 
 
select owner, table_name, column_name, grantee, grantor, privilege 
from   user_col_privs; 
 
select table_name, column_name, grantee, grantor, privilege 
from   user_col_privs_made; 
 
select owner, table_name, column_name, grantor, privilege 
from   user_col_privs_recd; 

-- 9. Użytkownik A odbiera u?ytkownikowi  B prawo  modyfikacji w?asnej relacji pracownicy. 
-- B nast?pnie  pr??e  modyfikowa?  (bezpo?rednio i za pomoc?  synonimu) relacj? 
-- pracownicy nale??c? do A. 
Revoke UPDATE ON Pracownicy FROM INF145441;

-- 10. U?ytkownicy tworz? role i nadaj? tym rolom prawo odczytu i modyfikowania danych we 
-- w?asnych relacjach pracownicy. Rola u?ytkownika A powinna by? chroniona has?em, rola 
-- u?ytkownika  B  jest  rol?  bez  has?a.  Nazwy  r??powinny  zosta?  skonstruowane  przez 
-- dodanie do s?owa ROLA_  numeru  indeksu  studenta,  np.  ROLA_12345  dla u?ytkownika 
-- INF12345.
CREATE ROLE ROLA_145380 IDENTIFIED BY password;

-- 11. Użytkownik A nadaje stworzon? przez siebie rol? u?ytkownikowi B. B pr??e odczyta? 
-- zawarto?? relacji pracownicy nale??cej do A.
GRANT ROLA_145380 TO INF145441;

-- 12. Użytkownik  B  w??cza  rol?  przyznan?  mu  przez  u?ytkownika  A.  B  pr??e  odczyta? 
-- zawarto?? relacji  pracownicy  nale??cej  do  A.  B  przegl?da  informacje  ze  s?ownika  bazy 
-- danych dotycz?c? uprawnie? zwi?zanych z rolami
SET ROLE ROLA_145380 IDENTIFIED BY password;

-- 13. Użytkownik A odbiera u?ytkownikowi B rol?. Użytkownik B pr??e  odczyta? 
-- informacje z relacji pracownicy nale??cej do u?ytkownika A. 
REVOKE ROLA_145380 FROM INF145441;

-- 14. Użytkownik  B  od??cza  si?  od  bazy  danych,  przy??cza  ponownie  i  pr??e  dokona? 
-- odczytu danych z relacji pracownicy u?ytkownika A.
-- brak dost?pu

-- 15. Użytkownik A pr??e dokona? modyfikacji danych relacji pracownicy u?ytkownika B.
UPDATE INF145380.Pracownicy
SET placa_pod = 2000
WHERE nazwisko = 'MORZY';

-- 16.  Użytkownik  B  nadaje  u?ytkownikowi  A  rol?,  jak?  utworzy?  w  p.  10.  Użytkownik  A 
-- ponownie pr??e dokona? modyfikacji danych relacji pracownicy u?ytkownika B.
GRANT ROLA_145441 TO INF145380;

-- 17. Użytkownik A od??cza si? od bazy danych, przy??cza ponownie i znowu pr??e dokona? 
-- modyfikacji danych relacji pracownicy u?ytkownika B.
UPDATE INF145380.Pracownicy
SET placa_pod = 2000
WHERE nazwisko = 'MORZY';

-- 18. Użytkownik  B  odbiera  swojej  roli  prawo  modyfikowania  w?asnej  relacji  pracownicy. 
-- Użytkownik A  ponownie  pr??e  dokona?  modyfikacji danych relacji pracownicy 
-- nale??cej do u?ytkownika B
UPDATE INF145380.Pracownicy
SET placa_pod = 2000
WHERE nazwisko = 'MORZY';

-- 19. Obaj u?ytkownicy usuwaj? utworzone przez siebie role.
DROP ROLE ROLE_145380;

-- 20. Użytkownik A nadaje u?ytkownikowi B prawo odczytu w?asnej relacji pracownicy wraz z  
-- prawem  dalszego  przyznawania  tego  uprawnienia.  Użytkownik  B  przekazuje  to  prawo 
-- dalej  u?ytkownikowi  C.  Użytkownik  C  pr??e  odczyta?  dane  z  relacji  pracownicy 
-- nale??cej do u?ytkownika A. 
GRANT SELECT ON INF145380.Pracownicy TO INF145441 with grant option;

-- 21.  Wszyscy  u?ytkownicy  (A,  B  i  C)  ogl?daj? zawarto?? s?ownika  bazy  danych  dotycz?c? 
-- nadanych i otrzymanych uprawnie? obiektowych.

-- 22. Użytkownik A pr??e odebra? uprawnienia do swojej relacji pracownicy u?ytkownikowi 
-- C.  Nast?pnie pr??e odebra? te  same  uprawnienia  u?ytkownikowi  B.  U?ytkownicy  raz 
-- jeszcze ogl?daj? s?ownik bazy danych. 
REVOKE ALL ON INF145380.Pracownicy FROM INF145379;
REVOKE ALL ON INF145380.Pracownicy FROM INF145441;

-- 23. Użytkownik A tworzy perspektyw? prac20 udost?pniaj?c? nazwiska i p?ace pracownik??-- zespo?u  20.  Nast?pnie  przenosi  ca?o??  uprawnie?  do  odczytu  i  modyfikacji  z  relacji 
-- pracownicy na utworzon?  perspektyw?  prac20. Użytkownik B modyfikuje relacj? 
-- pracownicy u?ytkownika A za pomoc? udost?pnionej mu perspektywy. 
CREATE OR REPLACE VIEW prac20 AS
    SELECT nazwisko, placa_pod
    FROM INF145380.Pracownicy
    WHERE ID_ZESP = 20;
    
GRANT ALL ON INF145380.prac20 TO INF145441;

-- 24. Użytkownik A tworzy w swoim schemacie funkcj? PL/SQL o nazwie funLiczEtaty, kt??
-- policzy liczb? rekord??elacji etaty  i zwr??j? jako wynik. Nast?pnie nadaje prawo 
-- wykonywania tej funkcji u?ytkownikowi B.

CREATE OR REPLACE FUNCTION funLiczEtaty
RETURN NUMBER IS
vResult NUMBER;
BEGIN 
    SELECT COUNT(*)
    INTO vResult
    FROM INF145380.ETATY;
    RETURN vResult;
END funLiczEtaty;

GRANT EXECUTE ON INF145380.funLiczEtaty TO INF145441;

-- 25.  Użytkownik  B  wykonuje  funkcj?  funLiczEtaty, a  nast?pnie  pr??e  zweryfikowa? 
-- poprawno??  jej  wyniku  licz?c  za  pomoc?  zapytania  SQL  rekordy  w  relacji  etaty 
-- u?ytkownika A.
DECLARE 
    x NUMBER;
BEGIN
    x := funLiczEtaty();
    DBMS_OUTPUT.put_line(x);
END;

-- 26. Użytkownik A ponownie tworzy funkcj? funLiczEtaty, jednak teraz funkcja ma dzia?a? z 
-- prawami u?ytkownika bie??cego (wykonuj?cego) ? z klauzul? AUTHID CURRENT_USER. 
-- Nast?pnie ponownie nadaje prawo wykonywania tej funkcji u?ytkownikowi B. 
CREATE OR REPLACE FUNCTION funLiczEtaty
RETURN NUMBER AUTHID CURRENT_USER IS
vResult NUMBER;
BEGIN 
    SELECT COUNT(*)
    INTO vResult
    FROM ETATY;
    RETURN vResult;
END funLiczEtaty;

GRANT EXECUTE ON INF145380.funLiczEtaty TO INF145441;

-- 27. Użytkownik B ponownie wykonuje funkcj? funLiczEtaty. Czy otrzymany wynik r?? si? 
-- od wyniku wykonania funkcji z punktu 25.? 
-- Tak, ta sama struktura bazy danych; polecenie wykonane po stronie wykonuj?cego

-- 28. Użytkownik  A  dodaje  do  swojej  relacji  etaty  nowy  rekord,  opisuj?cy  etat  o  nazwie 
-- WYK?ADOWCA  i  pensji  od  1000  do  2000  z?.  Po  dodaniu  rekordu  A  zatwierdza 
-- operacj? poleceniem COMMIT.
INSERT INTO ETATY
VALUES('WYK?ADOWCA', 1000, 2000);

-- 29. Użytkownik B ponownie wykonuje funkcj? funLiczEtaty. Dlaczego otrzymany wynik nie 
-- r?? si? wyniku wykonania funkcji z punktu 27.

-- Brak zmian; zmiany na lokalnej bazie danych nie zostaj? odwzierciedlone

-- 30.  Użytkownik B tworzy relacj? test o schemacie: id number(2), tekst varchar2(20) i dodaje 
-- do  niej  dwa  rekordy:  (1,?pierwszy?),  (2,  ?drugi?). Nast?pnie  tworzy  procedur? 
-- procPokazTest, kt?? zadaniem jest wypisanie na konsoli zawarto?ci kolumny tekst  ze 
-- wszystkich rekord??elacji test. (uwaga: odwo?uj?c si? do relacji test w ciele procedury 
-- u?ytkownik  B  NIE  poprzedza  jej  nazwy  swoj?  nazw?  u?ytkownika).  Procedura  ma 
-- dzia?a? z uprawnieniami bie??cego u?ytkownika (klauzula  AUTHID  CURRENT_USER). 
-- Nast?pnie B nadaje u?ytkownikowi A: 
-- a. prawo wykonywania procedury procPokazTest oraz 
-- b. prawo odczytu relacji test, 

CREATE TABLE test (
    id number(2),
    tekst varchar2(20)
);

INSERT INTO test
VALUES (1, 'pierwszy');

INSERT INTO test
VALUES (2, 'drugi');

CREATE OR REPLACE PROCEDURE procPokazTest
AUTHID CURRENT_USER IS 
    x VARCHAR2(9999);
BEGIN
    FOR x IN (SELECT tekst FROM  test)
    LOOP 
        DBMS_OUTPUT.put_line(x.tekst);
    END LOOP;
END procPokazTest;

GRANT EXECUTE ON procPokazTest TO INF145380;
GRANT SELECT ON test TO INF145380;

-- 31. Użytkownik A pr??e uruchomi? procedur? procPokazTest  u?ytkownika B. Dlaczego 
-- operacja ko?czy si? niepowodzeniem? Co mo?e zrobi? u?ytkownik A, aby m??wykona? 
-- procedur? procPokazTest?
EXEC INF145441.procPokazTest();

-- polecenie zostaje odpalone z mojego punktu widzenia - czyli bez tabeli test; Trzeba to zmieni?.

-- 32. Utw??relacj? info_dla_znajomych o poni?szym schemacie: 
-- NAZWA VARCHAR2(20) NOT NULL 
-- INFO VARCHAR2(200) NOT NULL 
-- Wpisz do relacji kilka krotek. Jako warto?ci atrybutu nazwa podaj identyfikatory innych 
-- u?ytkownik?? bazie danych. Utw??perspektyw? info4u i nadaj do niej odpowiednie 
-- prawa w ten spos??aby ka?dy u?ytkownik bazy danych m??odczyta? z perspektywy 
-- info4u informacje przeznaczone tylko i wy??cznie dla siebie. 

CREATE TABLE info_dla_znajomych (
    NAZWA VARCHAR2(20) NOT NULL,
    INFO VARCHAR2(200) NOT NULL 
);

INSERT INTO info_dla_znajomych
VALUES ('INF145380', 'pierwszy');

INSERT INTO info_dla_znajomych
VALUES ('INF145441', 'drugi');

CREATE OR REPLACE VIEW info4u AS 
    SELECT * FROM info_dla_znajomych
    WHERE NAZWA = USER;