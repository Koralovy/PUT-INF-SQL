-- 1. Wyświetl informacje o zespołach, które nie zatrudniają pracowników. Rozwiązanie powinno korzystać z podzapytania skorelowanego.
SELECT id_zesp, nazwa, adres FROM zespoly z WHERE NOT EXISTS (SELECT id_zesp FROM pracownicy WHERE id_zesp = z.id_zesp);

-- 2. Wyświetl nazwiska, płace podstawowe i nazwy etatów pracowników zarabiających więcej niż średnia pensja dla ich etatu. Wynik uporządkuj malejąco wg wartości płac podstawowych. Czy da się ten problem rozwiązać podzapytaniem zwykłym (bez korelacji)?
SELECT nazwisko, placa_pod, etat FROM pracownicy p WHERE placa_pod > (SELECT AVG(placa_pod) FROM pracownicy WHERE etat = p.etat) ORDER BY placa_pod DESC;

-- 3. Wyświetl nazwiska i pensje pracowników którzy zarabiają co najmniej 75% pensji swojego szefa. Wynik uporządkuj wg nazwisk.
SELECT nazwisko, placa_pod FROM pracownicy p WHERE placa_pod/0.75 >= (SELECT placa_pod FROM pracownicy WHERE id_prac = p.id_szefa) ORDER BY nazwisko;

-- 4. Wyświetl nazwiska tych profesorów, którzy wśród swoich podwładnych nie mają żadnych stażystów. Użyj podzapytania skorelowanego.
SELECT nazwisko, id_prac FROM pracownicy p WHERE etat = 'PROFESOR' AND NOT EXISTS (SELECT id_prac FROM pracownicy WHERE etat = 'STAZYSTA' AND id_szefa = p.id_prac);

-- 5. Wyświetl zespół z najwyższą sumaryczną pensją wśród zespołów. Użyj tylko podzapytań w klauzuli FROM: pierwsze ma znaleźć maksymalną sumaryczną płacę wśród zespołów (pojedyncza wartość), drugie wyliczy sumę płac w każdym zespole (zbiór rekordów, struktura zbioru: identyfikator zespołu, suma płac w zespole). Zapytanie główne ma wykonać dwa połączenia: pierwsze połączy zbiory wynikowe obu podzapytań do znalezienia szukanego zespołu, drugie, z tabelą Zespoly, uzupełni zbiór wynikowy o nazwę zespołu.
SELECT nazwa, maks_suma_plac FROM (SELECT MAX(SUM(placa_pod)) AS maks_suma_plac FROM pracownicy GROUP BY id_zesp) msum JOIN (SELECT SUM(placa_pod) AS sum_zespoly, id_zesp FROM pracownicy GROUP BY id_zesp) gsum ON msum.maks_suma_plac = gsum.sum_zespoly JOIN (SELECT id_zesp, nazwa FROM zespoly) z ON z.id_zesp = gsum.id_zesp;

-- 6. Wyświetl nazwiska i pensje trzech najlepiej zarabiających pracowników. Uporządkuj ich zgodnie z wartościami pensji w porządku malejącym. Zastosuj podzapytanie skorelowane.
SELECT nazwisko, placa_pod FROM pracownicy p WHERE 2>=(SELECT COUNT(placa_pod) FROM pracownicy WHERE p.placa_pod<placa_pod) ORDER BY placa_pod DESC;

-- 7. Wyświetl dla każdego roku liczbę zatrudnionych w nim pracowników. Wynik uporządkuj zgodnie z malejącą liczbą zatrudnionych.
SELECT EXTRACT(YEAR FROM zatrudniony) AS rok, (SELECT COUNT(*) FROM pracownicy where EXTRACT(YEAR FROM zatrudniony) = EXTRACT(YEAR FROM p.zatrudniony)) AS liczba FROM pracownicy p ORDER BY liczba DESC;

-- 8. Zmodyfikuj powyższe zapytanie w ten sposób, aby wyświetlać tylko rok, w którym przyjęto najwięcej pracowników
SELECT rok, COUNT(*) AS liczba FROM (SELECT EXTRACT(YEAR FROM zatrudniony) AS rok FROM pracownicy) GROUP BY rok HAVING count(*) = (SELECT max(count(*)) AS liczba FROM (SELECT EXTRACT(YEAR FROM zatrudniony) AS rok FROM pracownicy) GROUP BY rok);

-- 9. Dla każdego pracownika podaj jego nazwisko, płacę podstawową oraz różnicę między jego płacą podstawową a średnią płacą podstawową w zespole, do którego pracownik należy. Zaproponuj dwa rozwiązania, wykorzystujące: (1) podzapytanie w klauzuli SELECT (2) podzapytanie w klauzuli FROM.

-- (1)
SELECT nazwisko, placa_pod, (SELECT p.placa_pod - AVG(placa_pod) FROM pracownicy WHERE p.id_zesp = id_zesp) AS roznica FROM pracownicy p ORDER BY nazwisko;

-- (2)
SELECT nazwisko, placa_pod, placa_pod - srednia AS roznica FROM pracownicy p JOIN (SELECT AVG(placa_pod) AS srednia, id_zesp FROM pracownicy GROUP BY id_zesp) p2 ON p.id_zesp=p2.id_zesp ORDER BY nazwisko;

-- 10. Ogranicz poprzedni zbiór tylko do tych pracowników, którzy zarabiają więcej niż średnia w ich zespole (czyli mających dodatnią wartość różnicy między ich płacą podstawową a średnią płacą w ich zespole). Modyfikacji poddaj oba rozwiązania z poprzedniego punktu.

-- (1)
SELECT nazwisko, placa_pod, (SELECT p.placa_pod - AVG(placa_pod) FROM pracownicy WHERE p.id_zesp = id_zesp) AS roznica FROM pracownicy p WHERE (SELECT p.placa_pod - AVG(placa_pod) FROM pracownicy WHERE p.id_zesp = id_zesp) > 0 ORDER BY nazwisko;

-- (2)
SELECT nazwisko, placa_pod, placa_pod - srednia AS roznica FROM pracownicy p JOIN (SELECT AVG(placa_pod) AS srednia, id_zesp FROM pracownicy GROUP BY id_zesp) p2 ON p.id_zesp=p2.id_zesp WHERE placa_pod - srednia > 0 ORDER BY nazwisko;

-- 11. Wyświetl nazwiska profesorów, zatrudnionych na Piotrowie, wraz liczbą ich podwładnych. Wynik uporządkuj wg liczby podwładnych w porządku malejącym. Zastosuj podzapytanie w klauzuli SELECT.
SELECT nazwisko, (SELECT count(*) FROM pracownicy s WHERE id_szefa=p.id_prac) AS podwladni FROM pracownicy p WHERE etat='PROFESOR' AND ID_ZESP in (SELECT ID_ZESP FROM ZESPOLY WHERE adres = 'PIOTROWO 3A') ORDER BY podwladni DESC;

-- 12. Dla każdego zespołu wylicz średnią płacę jego pracowników. Następnie porównaj średnią w zespole z ogólną średnią płac i odpowiednio oznacz nastroje w zespole: umieść :) jeśli średnia w zespole jest wyższa lub równa średniej ogólnej i :( w przeciwnym wypadku. Jeśli zespół nie ma pracowników, nastrój oznacz jako nieokreślony używając ???.
SELECT nazwa, srednia_w_zespole, avgo.srednia_ogolna, CASE WHEN srednia_w_zespole>avgo.srednia_ogolna THEN ':)' WHEN srednia_w_zespole<avgo.srednia_ogolna THEN ':(' ELSE '???' END AS nastroje FROM zespoly z FULL JOIN (SELECT AVG(placa_pod) AS srednia_w_zespole, id_zesp FROM pracownicy GROUP BY id_zesp) avgzsp ON z.id_zesp=avgzsp.id_zesp CROSS JOIN (SELECT avg(PLACA_POD) AS srednia_ogolna FROM PRACOWNICY) avgo ORDER BY nazwa;

-- 13. Wyświetl wszystkie informacje o etatach z tabeli Etaty. Wynik zaprezentuj w porządku malejącym, ustalonym przez liczbę pracowników, zatrudnionych na poszczególnych etatach. Jeśli na dwóch lub więcej etatach pracowałoby tylu samo pracowników, uporządkuj etaty wg ich nazw. Posłuż się podzapytaniem w klauzuli ORDER BY.
SELECT * FROM etaty ORDER BY (SELECT COUNT(*) FROM pracownicy WHERE etat = nazwa) DESC, nazwa;