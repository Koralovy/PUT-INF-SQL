--1. 
SELECT MIN(placa_pod) AS minimum, MAX(placa_pod) AS maximum, MAX(placa_pod) - MIN(placa_pod) AS różnica FROM pracownicy;
--2. 
SELECT etat, AVG(placa_pod) AS srednia FROM pracownicy GROUP BY etat ORDER BY srednia DESC;
--3. 
SELECT COUNT(*) AS profesorowie FROM pracownicy WHERE etat='PROFESOR';
--4. 
SELECT id_zesp, SUM(placa_pod)+SUM(placa_dod) as sumaryczne_place FROM pracownicy GROUP BY id_zesp ORDER BY id_zesp;
--5. 
SELECT MAX(SUM(placa_pod)+SUM(placa_dod)) as maks_sum_placa FROM pracownicy GROUP BY id_zesp;
--6. 
SELECT id_szefa, MIN(placa_pod) AS minimalna FROM pracownicy WHERE id_szefa IS NOT NULL GROUP BY id_szefa ORDER BY minimalna DESC;
--7. 
SELECT id_zesp, COUNT(*) AS ilu_pracuje FROM pracownicy GROUP BY id_zesp ORDER BY ilu_pracuje DESC;
--8. 
SELECT id_zesp, COUNT(*) AS ilu_pracuje FROM pracownicy GROUP BY id_zesp HAVING COUNT(*) > 3 ORDER BY ilu_pracuje DESC;
--9. 
SELECT id_prac FROM pracownicy GROUP BY id_prac HAVING COUNT(*) > 1;
--10.
SELECT etat, AVG(placa_pod) AS średnia, COUNT(*) AS liczba FROM pracownicy WHERE EXTRACT(YEAR FROM zatrudniony) <= 1990 GROUP BY etat ORDER BY etat;
--11.
SELECT id_zesp, etat, ROUND(AVG(placa_pod + COALESCE(placa_dod, 0))) AS srednia, ROUND(MAX(placa_pod + COALESCE(placa_dod, 0))) AS maksymalna FROM pracownicy WHERE etat IN ('ASYSTENT', 'PROFESOR') GROUP BY id_zesp, etat ORDER BY id_zesp, etat;
--12.
SELECT EXTRACT(YEAR FROM zatrudniony) AS rok, COUNT(*) AS ilu_pracownikow FROM pracownicy GROUP BY EXTRACT(YEAR FROM zatrudniony) ORDER BY rok;
--13.
SELECT LENGTH(nazwisko) AS "ile liter", COUNT(*) AS "w ilu nazwiskach" FROM pracownicy GROUP BY LENGTH(nazwisko) ORDER BY ile_liter;
--14.
SELECT COUNT(*) AS "Ile nazwisk z a" FROM pracownicy WHERE lower(nazwisko) LIKE '%a%';
--15.
SELECT COUNT(CASE WHEN lower(nazwisko) LIKE '%a%' THEN 1 ELSE NULL END) AS "ile nazwisk z a", COUNT (CASE WHEN lower(nazwisko) LIKE '%e%' THEN 1 ELSE NULL END) AS "ile nazwisk z e" FROM pracownicy;
--16.
SELECT id_zesp, SUM(placa_pod), LISTAGG(nazwisko || ':' || placa_pod, ';') WITHIN GROUP (ORDER BY id_zesp) AS pracownicy FROM pracownicy GROUP BY id_zesp ORDER BY id_zesp;