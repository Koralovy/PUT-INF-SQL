ALTER TABLE opt_pracownicy
ADD CONSTRAINT opt_prac_pk PRIMARY KEY(id_prac);

-- z1
SET AUTOTRACE ON;
SELECT NAZWISKO, PLACA
FROM opt_pracownicy
WHERE id_prac < 10;
-- INDEX RANGE SCAN x1

--z2
SET AUTOTRACE ON;
CREATE INDEX OPT_PRAC_PLACA_DOD_IDX ON OPT_PRACOWNICY(placa_dod);
SET AUTOTRACE ON;
SELECT placa_dod FROM opt_pracownicy WHERE placa_dod IS NULL; --przeszukanie z indeksem
SET AUTOTRACE ON;
SELECT placa_dod FROM opt_pracownicy WHERE placa_dod IS NOT NULL; --przeszukanie ca?o?ci

--z3
SET AUTOTRACE ON;
SELECT id_zesp
FROM opt_zespoly
ORDER BY id_zesp;
-- maleje consistent gets