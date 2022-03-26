-- SetUp
INSERT INTO pracownicy(id_prac, nazwisko) 
VALUES ((SELECT max(id_prac) + 1 FROM pracownicy), 'WOLNY'); 

-- 1.
SELECT p.nazwisko, p.id_zesp, z.nazwa FROM pracownicy p LEFT JOIN zespoly z ON z.id_zesp = p.id_zesp ORDER BY nazwisko;

-- 2.
SELECT z.nazwa, z.id_zesp, COALESCE(p.nazwisko, 'brak pracowników') AS pracownik FROM zespoly z LEFT JOIN pracownicy p ON z.id_zesp = p.id_zesp ORDER BY z.nazwa, p.nazwisko;
  
-- 3.
SELECT CASE WHEN z.nazwa IS NULL THEN 'brak zespołu' ELSE z.nazwa END AS zespol, CASE WHEN  p.nazwisko IS NULL THEN 'brak pracowników' ELSE p.nazwisko END AS pracownik FROM pracownicy p FULL JOIN zespoly z ON z.id_zesp = p.id_zesp ORDER BY (CASE WHEN zespol = 'brak zespołu' THEN 1 ELSE 0 END), pracownik;
  
-- SetUp
DELETE FROM pracownicy WHERE nazwisko = 'WOLNY';

-- 4.
SELECT z.nazwa AS zespol, COUNT(p.id_zesp) AS liczba, SUM(p.placa_pod) AS suma_plac FROM pracownicy p RIGHT JOIN zespoly z ON z.id_zesp = p.id_zesp GROUP BY nazwa ORDER BY nazwa;
 
-- 5.
SELECT z.nazwa FROM pracownicy p RIGHT JOIN zespoly z ON p.id_zesp = z.id_zesp GROUP BY z.nazwa HAVING COUNT(p.id_prac) = 0;
  
-- 6.
SELECT p.nazwisko AS pracownik, p.id_prac, s.nazwisko AS szef, p.id_szefa FROM pracownicy p LEFT JOIN pracownicy s ON p.id_szefa = s.id_prac ORDER BY pracownik;
  
-- 7.
SELECT s.nazwisko AS pracownik, COUNT(p.id_prac) AS liczba_podwladnych FROM pracownicy p RIGHT JOIN pracownicy s ON p.id_szefa = s. id_prac GROUP BY s.nazwisko ORDER BY s.nazwisko;
  
-- 8.
SELECT p.nazwisko, e.nazwa AS etat, p.placa_pod, z.nazwa, s.nazwisko AS szef FROM pracownicy p 
	LEFT JOIN pracownicy s ON p.id_szefa = s. id_prac 
	LEFT JOIN etaty e ON p.etat = e.nazwa 
	LEFT JOIN zespoly z ON p.id_zesp = z.id_zesp
ORDER BY p.nazwisko;
  
-- 9.
SELECT p.nazwisko, z.nazwa FROM pracownicy p CROSS JOIN zespoly z ORDER BY p.nazwisko, z.nazwa;
  
-- 10.
SELECT COUNT(*) FROM etaty CROSS JOIN pracownicy CROSS JOIN zespoly;
  
-- Operatory zbiorowe
-- 11.
SELECT etat FROM pracownicy WHERE EXTRACT(YEAR FROM zatrudniony) = 1992 
  INTERSECT 
SELECT etat FROM pracownicy WHERE EXTRACT(YEAR FROM zatrudniony) = 1993;
  
-- 12.
SELECT id_zesp FROM zespoly 
  MINUS 
SELECT id_zesp FROM pracownicy;
  
-- 13.
SELECT id_zesp, nazwa FROM zespoly
  MINUS
SELECT p.id_zesp, z.nazwa FROM pracownicy p INNER JOIN zespoly z ON z.id_zesp = p.id_zesp;
  
-- 14.
SELECT nazwisko, placa_pod, 'Poniżej 480 złotych' as prog FROM pracownicy WHERE placa_pod < 480 UNION SELECT nazwisko, placa_pod, 'Dokładnie 480 złotych' as prog FROM pracownicy WHERE placa_pod = 480 UNION SELECT nazwisko, placa_pod, 'Powyżej 480 złotych' as prog FROM pracownicy WHERE placa_pod > 480 ORDER BY placa_pod;