-- 1.
SELECT nazwisko, etat, id_zesp FROM pracownicy WHERE id_zesp = (SELECT id_zesp FROM pracownicy WHERE nazwisko = 'BRZEZINSKI') ORDER BY nazwisko;

-- 2.
SELECT nazwisko, etat, id_zesp, nazwa FROM pracownicy NATURAL INNER JOIN zespoly WHERE id_zesp = (SELECT id_zesp FROM pracownicy WHERE nazwisko = 'BRZEZINSKI') ORDER BY nazwisko;

-- 3.
SELECT nazwisko, etat, zatrudniony FROM pracownicy WHERE etat = 'PROFESOR' AND zatrudniony = (SELECT MIN(zatrudniony) FROM pracownicy WHERE etat = 'PROFESOR');

-- 4.
SELECT nazwisko, zatrudniony, id_zesp FROM pracownicy WHERE (zatrudniony, id_zesp) IN (SELECT MAX(zatrudniony), id_zesp FROM pracownicy GROUP BY id_zesp) ORDER BY zatrudniony;

-- 5.
SELECT id_zesp, nazwa, adres FROM zespoly WHERE id_zesp NOT IN (SELECT DISTINCT(id_zesp) FROM pracownicy);

-- 6.
SELECT nazwisko FROM pracownicy WHERE etat = 'PROFESOR' AND id_prac NOT IN (SELECT id_szefa FROM pracownicy WHERE etat = 'STAZYSTA');

-- 7.
SELECT id_zesp, sum(placa_pod) AS suma_plac FROM pracownicy GROUP BY id_zesp HAVING sum(placa_pod) = (SELECT max(sum(placa_pod)) FROM pracownicy GROUP BY id_zesp);

-- 8.
SELECT nazwa, sum(placa_pod) AS suma_plac FROM pracownicy NATURAL INNER JOIN zespoly GROUP BY nazwa HAVING sum(placa_pod) = (SELECT max(sum(placa_pod)) FROM pracownicy GROUP BY id_zesp);

-- 9.
SELECT nazwa, count(*) AS ilu_pracownikow FROM zespoly NATURAL INNER JOIN pracownicy GROUP BY nazwa HAVING count(*) > (SELECT count(*) FROM zespoly NATURAL INNER JOIN pracownicy WHERE nazwa='ADMINISTRACJA') ORDER BY nazwa;

-- 10.
SELECT etat FROM pracownicy GROUP BY etat HAVING count(*) = (SELECT max(count(*)) FROM pracownicy GROUP BY etat);

-- 11.
SELECT etat, LISTAGG(nazwisko || ',') WITHIN GROUP(ORDER BY nazwisko) pracownicy FROM pracownicy GROUP BY etat HAVING count(*) = (SELECT max(count(*)) FROM pracownicy GROUP BY etat);

-- 12.
SELECT p.nazwisko AS pracownik, s.nazwisko AS szef FROM pracownicy p JOIN pracownicy s ON p.id_szefa=s.id_prac WHERE s.placa_pod-p.placa_pod = (SELECT min(s.placa_pod-p.placa_pod) FROM pracownicy p JOIN pracownicy s ON p.id_szefa=s.id_prac);