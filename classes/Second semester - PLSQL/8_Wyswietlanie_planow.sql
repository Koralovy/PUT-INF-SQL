--Napisz  i  wykonaj  polecenie  SQL, które wy?wietli nazwiska wszystkich pracowników z tabeli 
--OPT_PRACOWNICY  wraz  z  nazwami  zespo?ów  z  tabeli  OPT_ZESPOLY, do których pracownicy 
--nale??. Polecenie mo?e mie? nast?puj?c? posta?:
SELECT nazwisko, nazwa 
FROM opt_pracownicy JOIN opt_zespoly USING(id_zesp);

--Przygotujemy teraz plan wykonania naszego polecenia SQL. Wykonaj poni?sze polecenie. 
EXPLAIN PLAN FOR 
SELECT nazwisko, nazwa 
FROM opt_pracownicy JOIN opt_zespoly USING(id_zesp); 

--W  specjalnej,  predefiniowanej  tabeli  o  nazwie  PLAN_TABLE  zosta?y umieszczone informacje 
--o planie wykonania polecenia SQL, wskazanego w poleceniu EXPLAIN PLAN. Aby te informacje 
--odczyta?, nale?y  u?y?  predefiniowanej  funkcji  tablicowej  DISPLAY z pakietu DBMS_XPLAN 
--w sposób przedstawiony poni?ej
SELECT * FROM TABLE(dbms_xplan.display());

-- Znajd?my ponownie plan wykonania polecenia z po??czeniem, tym razem polecenie  oznaczymy 
--identyfikatorem „zap_1_<nazwa_u?ytk>”. 
EXPLAIN PLAN  
SET STATEMENT_ID = 'zap_1_inf145380' FOR 
SELECT nazwisko, nazwa 
FROM opt_pracownicy JOIN opt_zespoly USING(id_zesp); 

EXPLAIN PLAN  
SET STATEMENT_ID = 'zap_2_inf145380' FOR 
SELECT etat, ROUND(AVG(placa),2) 
FROM opt_pracownicy 
GROUP BY etat ORDER BY etat; 

SELECT * 
FROM TABLE(dbms_xplan.display(statement_id => 'zap_2_inf145380'));

--Poni?sze polecenie wy?wietli tylko plan wykonania (bez ?adnych dodatkowych informacji) dla 
--polecenia oznaczonego identyfikatorem „zap_2_<nazwa_u?ytk>”
SELECT * 
FROM TABLE(dbms_xplan.display( 
           statement_id => 'zap_2_inf145380', 
           format => 'BASIC')); 
           
--1.  Wy?wietl plan  wykonania  polecenia,  oznaczonego  identyfikatorem  „zap_2_<nazwa_u?ytk>”,  z 
--domy?lnym poziomem szczegó?owo?ci prezentowanych informacji. 
SELECT * 
FROM TABLE(dbms_xplan.display( 
           statement_id => 'zap_2_inf145380', 
           format => 'TYPICAL')); 

--2. Wy?wietl  ponownie  plan  dla  zapytania „zap_2_<nazwa_u?ytk>”, tym razem  z  pe?nymi 
--informacjami. 
SELECT * 
FROM TABLE(dbms_xplan.display( 
           statement_id => 'zap_2_inf145380', 
           format => 'ALL')); 

--3. Przygotuj i wykonaj zapytanie, które policzy liczb? pracowników dla ka?dego etatu. Odczytaj plan 
--wykonania tego zapytania pos?uguj?c si? zarówno poleceniem  EXPLAIN PLAN,  jak równie? 
--korzystaj?c z narz?dzia prezentacji planu w formie grafu.
EXPLAIN PLAN FOR
SELECT etat, COUNT(*) FROM OPT_PRACOWNICY GROUP BY etat;

SELECT * FROM TABLE(dbms_xplan.display());

--W Oracle SQL Developer,  b?d?c  przy??czonym  do  konta  bazodanowego u?ytkownika 
--<nazwa_u?ytk>,  w  edytorze  polece?  SQL  ponownie  wpisz  i  wykonaj  polecenie  SQL,  które 
--wy?wietli ?rednie pensja dla etatów w zbiorze pracowników tabeli OPT_PRACOWNICY. 
SELECT etat, ROUND(AVG(placa),2) 
FROM opt_pracownicy 
GROUP BY etat ORDER BY etat;

--W edytorze polece? SQL wpisz i wykonaj poni?sze polecenie:
SET AUTOTRACE ON EXPLAIN 

--W edytorze polece? SQL wpisz i wykonaj poni?sze polecenie:
SET AUTOTRACE ON STATISTICS 

--Aby narz?dzie prezentowa?o zarówno plan wykonania, jak i statystyki wykonania polecenia SQL, 
--nale?y pos?u?y? si? trzeci? form? dyrektywy AUTOTRACE. Wykonaj w edytorze SQL poni?sze 
--polecenie:
SET AUTOTRACE ON 

--Wy??cz tryb pracy z prezentacj? planów i statystyk, wykonuj?c poni?sze polecenie
SET AUTOTRACE OFF

--W  Oracle  SQL  Developer  przygotuj  i wykonaj zapytanie wy?wietlaj?ce nazwy zespo?ów wraz 
--z liczbami pracuj?cych w nich pracowników. Zapytanie mo?e wygl?da? jak przedstawiono poni?e
SELECT nazwa, COUNT(*) 
FROM opt_pracownicy JOIN opt_zespoly USING(id_zesp) 
GROUP BY nazwa 
ORDER BY nazwa;

-- Wykonaj poni?sze polecenie
SELECT * FROM TABLE(dbms_xplan.display_cursor()); 

SELECT sql_text, sql_id, 
       to_char(last_active_time, 'yyyy.mm.dd hh24:mi:ss') 
         as last_active_time, 
       parsing_schema_name 
FROM v$sql 
WHERE sql_text LIKE  
    'SELECT nazwa%opt_pracownicy JOIN opt_zespoly%ORDER BY nazwa' 
AND sql_text NOT LIKE '%v$sql%';

-- Otrzymany identyfikator polecenia (warto?? w kolumnie sql_id)  przekazujemy  jako  parametr 
--funkcji DBMS_XPLAN.DISPLAY_CURSOR o nazwie sql_id: 
SELECT *  
FROM TABLE(dbms_xplan.display_cursor(sql_id => '06xnctj0zr5w1')); 

SELECT /* MOJE_ZAPYTANIE_inf145380 */ nazwa, count(*) 
FROM opt_pracownicy JOIN opt_zespoly USING(id_zesp) 
GROUP BY nazwa 
ORDER BY nazwa; 

SELECT sql_id 
FROM v$sql 
WHERE sql_text LIKE '%MOJE_ZAPYTANIE_inf145380%' 
AND sql_text NOT LIKE '%v$sql%'; 

--U?yj poni?szego  polecenia  aby  wy?wietli?  plan  wykonania  wskazanego  polecenia,  opis  bloków 
--polecenia, predykatów filtruj?cych i po??czeniowych oraz kolumn zbioru wynikowego.
SELECT * FROM TABLE(dbms_xplan.display_cursor( 
   sql_id => '9qvqhqn038sqq', format => 'ALL'));
   
SELECT *  
FROM TABLE(dbms_xplan.display_cursor( 
   sql_id => '9qvqhqn038sqq', 
   format => 'BASIC +ROWS +BYTES +PREDICATE')); 

--Wy?wietlmy  teraz  pe?ne  informacje  o  planie  wykonanego  w  p.  5. zapytania, ale 
--z pomini?ciem opisu bloków zapytania.
   SELECT *  
FROM TABLE(dbms_xplan.display_cursor( 
   sql_id => '9qvqhqn038sqq', 
   format => 'ALL -ALIAS')); 
   
--Wykonaj ponownie zapytanie z p. 5., tym razem w poni?ej zaprezentowanej postaci: 
SELECT /*+ GATHER_PLAN_STATISTICS MOJE_ZAPYTANIE_2_inf145380*/  
       nazwa, count(*) 
FROM opt_pracownicy JOIN opt_zespoly USING(id_zesp) 
GROUP BY nazwa 
ORDER BY nazwa; 

--Analogicznie jak w punkcie 5. znajd? identyfikator wykonanego polecenia.  Nast?pnie wy?wietl 
--informacje o wykonanym poleceniu pos?uguj?c si? poni?szym zapytaniem (w miejsce XYZ wstaw 
--odczytany identyfikator).
SELECT sql_id 
FROM v$sql 
WHERE sql_text LIKE '%MOJE_ZAPYTANIE_2_inf145380%' 
AND sql_text NOT LIKE '%v$sql%'; 

SELECT *  
FROM TABLE(dbms_xplan.display_cursor( 
   sql_id => '7t3g0891wz5ff', 
   format => 'IOSTATS ALL LAST'));
   
--Na koniec poznajmy pewne u?atwienie przy wyszukaniu identyfikatora polecenia SQL, jakie 
--oferuje narz?dzie Oracle SQL Developer. Wykonaj poni?sze polecenie
SELECT etat, count(*) 
FROM opt_pracownicy 
GROUP BY etat;

select * from table(dbms_xplan.display_cursor(sql_id=>'9n9drbq0c3uk5', format=>'ALLSTATS LAST'));

--1. Skonstruuj dwa zapytania: 
--? zapytanie,  które  odszuka  w  tabeli OPT_PRACOWNICY dane  najlepiej  zarabiaj?cego 
--pracownika, 
SELECT /* Z1a_inf145380 */ * FROM OPT_PRACOWNICY WHERE placa = (SELECT MAX(placa) FROM OPT_PRACOWNICY);

--? zapytanie, które dla poszczególnych p?ci pracowników  z  tabeli  OPT_PRACOWNICY  znajdzie 
--liczb? pracowników danej p?ci i ich ?rednie zarobki. 
SELECT /* Z1b_inf145380 */ plec, AVG(placa), COUNT(1) FROM OPT_PRACOWNICY GROUP BY plec;

--Uwaga! Umie?? w tek?cie ka?dego zapytania komentarz, który u?atwi znalezienie planu, wg 
--którego zapytanie zosta?o wykonane. 

--2. Wykonaj oba zapytania. Nast?pnie znajd? ich identyfikatory w perspektywie V$SQL.
SELECT sql_id 
FROM v$sql 
WHERE sql_text LIKE '%Z1%_inf145380%' 
AND sql_text NOT LIKE '%v$sql%'; 
--3. Wykorzystuj?c funkcj?  DBMS_XPLAN.DISPLAY_CURSOR wy?wietl  informacje  o  wykonaniu 
--zapyta?. Zmieniaj?c warto?ci parametru FORMAT i wy?wietl ró?ne zbiory informacji. 
SELECT * FROM TABLE(dbms_xplan.display_cursor( 
   sql_id => '7nfd894zzp4jt', format => 'BASIC'));
   
SELECT * FROM TABLE(dbms_xplan.display_cursor( 
   sql_id => 'guqb8shy7kw6h', format => 'ALL'));
   
--4. Skonstruuj dwa kolejne polecenia: 
--? pierwsze wstawi do relacji OPT_PRACOWNICY rekord opisuj?cy pracownika o identyfikatorze 
--11111 i nazwisku „11111”, 
INSERT /* Z2a_inf145380 */ INTO OPT_PRACOWNICY(id_prac, nazwisko) values(11111, '11111');

--? drugie usunie pracownika, wstawionego przez polecenie pierwsze. 
DELETE /* Z2b_inf145380 */ FROM OPT_PRACOWNICY WHERE id_prac = 11111;
--Oznacz oba polecenia odpowiednimi  komentarzami (komentarze mo?esz umie?ci? bezpo?rednio 
--po klauzulach INSERT i DELETE). 

--5. Wykonaj oba polecenia, nast?pnie poleceniem COMMIT zatwierd? bie??c? transakcj?. 
COMMIT;

--6. Znajd? identyfikatory  wykonanych  w  perspektywie  V$SQL  a nast?pnie, wykorzystuj?c  funkcj? 
--DBMS_XPLAN.DISPLAY_CURSOR, wy?wietl informacje o wykonaniu tych polece?. 
SELECT sql_id 
FROM v$sql 
WHERE sql_text LIKE '%Z2%_inf145380%' 
AND sql_text NOT LIKE '%v$sql%';

SELECT * FROM TABLE(dbms_xplan.display_cursor( 
   sql_id => 'ata31wzzzf7mm', format => 'ALL'));
   
SELECT * FROM TABLE(dbms_xplan.display_cursor( 
   sql_id => '4umadujmyyhju', format => 'ALL'));