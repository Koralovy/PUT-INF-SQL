-- 1. Napisz zapytanie, które wyświetli nazwiska i pensje trzech najlepiej zarabiających pracowników (ustalając ranking weź pod uwagę wartości płac podstawowych pracowników). Zadanie rozwiąż dwoma sposobami:
-- - używając konstrukcji FETCH FIRST,
SELECT nazwisko, placa_pod FROM pracownicy ORDER BY placa_pod DESC FETCH FIRST 3 ROWS ONLY;

-- - używając podzapytania z pseudokolumną ROWNUM.
SELECT ROWNUM, R.nazwisko, R.placa_pod FROM (SELECT nazwisko, placa_pod FROM pracownicy ORDER BY placa_pod DESC) R WHERE ROWNUM <= 3;

-- 2. Napisz zapytanie, które wyświetli „drugą piątkę” (od pozycji 6. do 10.) pracowników zgodnie z ich zarobkami (płacami podstawowymi). Zadanie rozwiąż dwoma sposobami: 
-- - używając konstrukcji OFFSET,
SELECT nazwisko, placa_pod FROM pracownicy ORDER BY placa_pod DESC OFFSET 5 ROWS FETCH NEXT 5 ROWS ONLY;

-- - używając podzapytań z pseudokolumną ROWNUM.
SELECT * FROM (SELECT ROWNUM AS RN2, R.* FROM (SELECT nazwisko, placa_pod FROM pracownicy ORDER BY placa_pod DESC) R WHERE ROWNUM <= 10) WHERE RN2 >=6;

-- 3. Dla każdego pracownika podaj jego nazwisko, płacę podstawową oraz różnicę między jego płacą podstawową a średnią płacą podstawową w zespole, do którego pracownik należy Ogranicz zbiór tylko do tych pracowników, którzy zarabiają więcej niż średnia w ich zespole (czyli mających dodatnią wartość różnicy między ich płacą podstawową a średnią płacą w ich zespole). Użyj klauzuli WITH do definicji zbioru, wyliczającego średnie płace w poszczególnych zespołach.
WITH roznice (srednia, id_zesp) AS (SELECT AVG(placa_pod), id_zesp FROM pracownicy GROUP BY id_zesp)
SELECT nazwisko, placa_pod, placa_pod-roznice.srednia AS roznica FROM pracownicy p join roznice ON p.ID_ZESP=roznice.id_zesp WHERE placa_pod-srednia>0;

-- 4.. Wyświetl dla każdego roku liczbę zatrudnionych w nim pracowników. Wynik uporządkuj zgodnie z malejącą liczbą zatrudnionych. Użyj klauzuli WITH do zdefiniowania zbioru o nazwie Lata, pokazującego dla każdego roku liczbę zatrudnionych w nim pracowników.
WITH lata(rok, liczba) AS (SELECT EXTRACT(YEAR FROM zatrudniony), COUNT(1) FROM pracownicy GROUP BY EXTRACT(YEAR FROM zatrudniony))
SELECT * FROM lata ORDER BY liczba DESC;

-- 5. Dodaj do powyższego zapytania dodatkowy warunek, który spowoduje, że zostanie wyświetlony tylko ten rok, w którym przyjęto najwięcej pracowników. Posłuż się ponownie zbiorem Lata.
WITH lata(rok, liczba) AS (SELECT EXTRACT(YEAR FROM zatrudniony), COUNT(1) FROM pracownicy GROUP BY EXTRACT(YEAR FROM zatrudniony))
SELECT * FROM lata WHERE liczba = (SELECT MAX(liczba) FROM lata);

-- 6. Wyświetl informacje o asystentach pracujących na Piotrowie. Zastosuj klauzulę WITH, zdefiniuj przy jej pomocy dwa zbiory: Asystenci i Piotrowo, następnie użyj tych zbiorów w zapytaniu wykonując na nich operację połączenia.
WITH asystenci AS (SELECT * FROM pracownicy WHERE etat='ASYSTENT'), piotrowo AS (SELECT * FROM zespoly WHERE adres = 'PIOTROWO 3A')
SELECT nazwisko, etat, nazwa, adres FROM asystenci JOIN piotrowo ON asystenci.id_zesp = piotrowo.id_zesp;

-- 7. Używając klauzuli WITH ponownie znajdź dane zespołu, wypłacającego sumarycznie najwięcej swoim pracownikom.
WITH place (id_zesp, suma) AS (SELECT id_zesp, sum(placa_pod) FROM pracownicy GROUP BY id_zesp), lstzespoly (id, nazwa) AS (SELECT id_zesp, nazwa FROM zespoly)
SELECT nazwa, suma AS maks_suma_plac FROM place JOIN lstzespoly ON id_zesp = id WHERE suma = (SELECT MAX(suma) FROM place);

-- 8. Wyświetl hierarchię szef-podwładny rozpoczynając od pracownika-szefa o nazwisku BRZEZINSKI. Zadanie rozwiąż dwoma sposobami:
-- - używając zapytań hierarchicznych z rekurencyjną klauzulą WITH,
WITH podwladni (id_prac, id_szefa, nazwisko, poziom) AS (SELECT id_prac, ID_SZEFA, nazwisko, 1 FROM pracownicy WHERE NAZWISKO = 'BRZEZINSKI' UNION ALL SELECT p.id_prac, p.id_szefa, p.nazwisko, poziom + 1 FROM podwladni s JOIN pracownicy p on s.id_prac=p.id_szefa) search depth FIRST BY nazwisko SET porzadek_potomkow
SELECT nazwisko, poziom AS pozycja_w_hierarachii FROM podwladni ORDER BY porzadek_potomkow;

-- - używając zapytań hierarchicznych w składni Oracle.
SELECT nazwisko, LEVEL AS pozycja_w_hierarchii FROM pracownicy CONNECT BY id_szefa = PRIOR id_prac START WITH nazwisko = 'BRZEZINSKI' ORDER SIBLINGS BY nazwisko;

-- 9. Przerób zapytania z poprzedniego punktu, aby uzyskać efekt wcięcia przed nazwiskami, zależnego od pozycji pracownika w hierarchii.
-- - używając zapytań hierarchicznych z rekurencyjną klauzulą WITH,
WITH podwladni (id_prac, id_szefa, nazwisko, poziom) AS (SELECT id_prac, ID_SZEFA, nazwisko, 1 FROM pracownicy WHERE NAZWISKO = 'BRZEZINSKI' UNION ALL SELECT p.id_prac, p.id_szefa, p.nazwisko, poziom + 1 FROM podwladni s JOIN pracownicy p on s.id_prac=p.id_szefa) search depth FIRST BY nazwisko SET porzadek_potomkow
SELECT (lpad(' ', poziom - 1, ' ') || nazwisko) AS nazwisko, poziom AS pozycja_w_hierarachii FROM podwladni ORDER BY porzadek_potomkow;

-- - używając zapytań hierarchicznych w składni Oracle.
SELECT (lpad(' ', level - 1, ' ') || p.nazwisko) AS nazwisko, LEVEL AS pozycja_w_hierarchii FROM pracownicy p CONNECT BY id_szefa = PRIOR id_prac START WITH nazwisko = 'BRZEZINSKI' ORDER SIBLINGS BY p.nazwisko;