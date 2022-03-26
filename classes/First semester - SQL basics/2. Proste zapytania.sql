-- 1. 
SELECT * FROM zespoly;
-- 2. 
SELECT * FROM pracownicy ORDER BY id_prac;
-- 3. 
SELECT nazwisko, 12*placa_pod AS roczna_placa FROM pracownicy ORDER BY nazwisko;
-- 4. 
SELECT nazwisko, etat, placa_pod + COALESCE(placa_dod,0) AS miesieczne_zarobki FROM pracownicy ORDER BY miesieczne_zarobki DESC;
-- 5. 
SELECT * FROM zespoly ORDER BY nazwa;
-- 6. 
SELECT UNIQUE etat FROM pracownicy ORDER BY etat;
-- 7. 
SELECT * FROM pracownicy WHERE etat = 'ASYSTENT' ORDER BY nazwisko;
-- 8. 
SELECT id_prac, nazwisko, etat, placa_pod, id_zesp FROM pracownicy WHERE id_zesp IN (30,40) ORDER BY placa_pod DESC;
-- 9. 
SELECT nazwisko, id_zesp, placa_pod FROM pracownicy WHERE placa_pod BETWEEN 300 AND 800 ORDER BY nazwisko;
-- 10.
SELECT nazwisko, etat, id_zesp FROM pracownicy WHERE nazwisko LIKE '%SKI' ORDER BY nazwisko;
-- 11.
SELECT id_prac, id_szefa, nazwisko, placa_pod FROM pracownicy WHERE placa_pod > 1000  AND id_szefa IS NOT NULL;
-- 12.
SELECT nazwisko, id_zesp FROM pracownicy WHERE id_zesp = 20 AND (nazwisko LIKE 'M%' OR nazwisko LIKE '%SKI') ORDER BY nazwisko;
-- 13.
SELECT nazwisko, etat, placa_pod/(20*8) AS stawka FROM pracownicy WHERE etat NOT IN ('ADIUNKT', 'ASYSTENT', 'STAZYSTA') AND placa_pod NOT BETWEEN 400 AND 800 ORDER BY stawka;
-- 14.
SELECT nazwisko, etat, placa_pod, placa_dod FROM pracownicy WHERE placa_pod + COALESCE(placa_dod,0) > 1000 ORDER BY etat, nazwisko;
-- 15.
SELECT nazwisko||' PRACUJE OD '||zatrudniony||' I ZARABIA '||placa_pod AS profesorowie FROM pracownicy WHERE etat = 'PROFESOR';