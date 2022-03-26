-- 1. 
SELECT nazwisko, SUBSTR(etat, 1, 2)||id_prac AS kod FROM pracownicy;
-- 2. 
SELECT nazwisko, TRANSLATE(nazwisko, 'KLM', 'XXX') AS wojna_literom FROM pracownicy;
-- 3. 
SELECT nazwisko FROM pracownicy WHERE SUBSTR(nazwisko, 1, FLOOR(LENGTH(nazwisko)/2)) like '%L%'
-- 4. 
SELECT nazwisko, ROUND(1.15*placa_pod) AS podwyzka FROM pracownicy;
-- 5. 
SELECT nazwisko, placa_pod, ROUND(0.2*placa_pod) AS inwestycja, ROUND(0.2*placa_pod)*POWER((1+0.1), 10) AS kapital, ROUND(0.2*placa_pod)*(POWER((1+0.1), 10)-1) AS zysk FROM pracownicy;
-- 6. 
SELECT nazwisko, zatrudniony, FLOOR((DATE'2000-01-01' - zatrudniony)/365) AS staz_w_2000 FROM pracownicy;
-- 7. 
SELECT nazwisko, TO_CHAR(zatrudniony,'fmMONTH, DD YYYY') AS data_zatrudnienia FROM pracownicy WHERE id_zesp = 20;
-- 8. 
SELECT TO_CHAR(SYSDATE, 'fmDAY') AS dzis FROM dual;
-- 9. 
SELECT nazwa, adres, CASE adres WHEN 'PIOTROWO 3A' THEN 'NOWE MIASTO' WHEN 'WLODKOWICA 16' THEN 'GRUNWALD' ELSE 'STARE MIASTO' END AS dzielnica FROM zespoly;
-- 10.
SELECT nazwisko, placa_pod, CASE WHEN placa_pod > 480 THEN 'Powyżej 480' WHEN placa_pod = 480 THEN 'Dokładnie 480' ELSE 'Poniżej 480' END AS próg FROM pracownicy;