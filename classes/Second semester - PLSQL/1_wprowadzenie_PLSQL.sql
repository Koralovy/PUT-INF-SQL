-- Setup
SET serveroutput ON;
SET serveroutput OFF;
BEGIN
    DBMS_OUTPUT.ENABLE();
END;

-- 1. Zadeklaruj  zmienne vTekst i vLiczba o wartościach odpowiednio „Witaj, świecie!” i 1000.456. Następnie wyświetl na konsoli wartości tych zmiennych.
DECLARE
    vtekst  VARCHAR(50)  := 'Witaj, świecie!';
    vliczba NUMBER(7, 3) := 1000.456;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Zmienna vTekst:  ' || vtekst);
    DBMS_OUTPUT.PUT_LINE('Zmienna vLiczba:  ' || vliczba);
END;

--2. Do zmiennych,zadeklarowanych  w  zadaniu 1.,dodaj odpowiednio:  do  zmiennej vTekstwartość „Witaj, nowy dniu!”, do zmiennej vLiczbadodaj wartość 1015. Wyświetl wartości tych zmiennych.
DECLARE
    vtekst  VARCHAR(50) := 'Witaj, świecie!';
    vliczba number      := 1000.456;
BEGIN
    vtekst := vtekst || ' Witaj, nowy dniu!';
    vliczba := vliczba + 10e15;
    DBMS_OUTPUT.PUT_LINE('Zmienna vTekst:  ' || vtekst);
    DBMS_OUTPUT.PUT_LINE('Zmienna vLiczba:  ' || vliczba);
END;

-- 3. Napisz program dodający do siebie dwie liczby. Liczby, które mają być do siebie dodane, powinny być podawane za pomocą odpowiednio zainicjalizowanych zmiennych.
DECLARE
    vnum1 number := 10;
    vnum2 number := 3.14;
    vsuma number := vnum1 + vnum2;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Wynik dodatawania ' || vnum1 || ' i ' || vnum2 || ': ' || vsuma);
END;

-- 4.Napisz program, który oblicza pole powierzchni koła i obwód koła o podanym w  zmiennej promieniu. Wprogramie posłuż się zdefiniowaną przez siebie stałą cPIo wartości 3.14.
DECLARE
    cpi constant number := 3.14;
    cr           number DEFAULT 5;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Obwód koła o promieniu równym ' || cr || ': ' || 2 * cr * cpi);
    DBMS_OUTPUT.PUT_LINE('Pole koła o promieniu równym ' || cr || ': ' || cpi * cr * cr);
END;

-- 5. Napisz program, który wyświetli poniższe informacje o najlepiej zarabiającym pracowniku Instytutu. Program powinien korzystać ze zmiennych vNazwiskoi vEtato  typach  identycznych  z  typami atrybutów, odpowiednio: nazwiskoi etatw relacji Pracownicy.
DECLARE
    vnazwisko pracownicy.nazwisko % type;
    vetat     pracownicy.etat % type;
BEGIN
    SELECT nazwisko,
           etat
    INTO vnazwisko,
        vetat
    FROM pracownicy
    ORDER BY placa_pod DESC
        FETCH FIRST row only;
    DBMS_OUTPUT.PUT_LINE('Najlepiej zarabia pracownik ' || vnazwisko || '.');
    DBMS_OUTPUT.PUT_LINE('Pracuje on jako ' || vetat || '.');
END;

-- 6. Napisz program działający identycznie jak program z zadania poprzedniego, tym razem jednak użyj zmiennych rekordowych.
DECLARE
    vrow pracownicy % rowtype;
BEGIN
    SELECT *
    INTO vrow
    FROM pracownicy
    ORDER BY placa_pod DESC
        FETCH FIRST row only;
    DBMS_OUTPUT.PUT_LINE('Najlepiej zarabia pracownik ' || vrow.nazwisko || '.');
    DBMS_OUTPUT.PUT_LINE('Pracuje on jako ' || vrow.etat || '.');
END;

-- 7. Zdefiniuj w oparciu o typ NUMBERwłasny podtyp o nazwie tPieniadzei zdefiniuj zmienną tego typu. Wczytaj do niej roczne zarobki prof. Słowińskiego.
DECLARE subtype tpieniadze IS NUMBER(7, 2);
    vpieniadze tpieniadze;
BEGIN
    SELECT placa_pod * 12
    INTO vpieniadze
    FROM pracownicy
    WHERE nazwisko = 'SLOWINSKI';
    DBMS_OUTPUT.PUT_LINE('Pracownik SLOWINSKI zarabia rocznie ' || vpieniadze);
END;

-- 8. Napisz program, który będzie działał tak długo, jak długo nie nadejdzie 25 sekunda dowolnej minuty. Na zakończenie program powinien wypisać na konsoli odpowiedni komunikat.
DECLARE
    vtime CHAR(2);
BEGIN
    loop
        EXIT
            WHEN vtime = 25;
        SELECT TO_CHAR(sysdate, 'SS')
        INTO vtime
        FROM dual;
        SYS.DBMS_SESSION.SLEEP(1);
    END loop;
    DBMS_OUTPUT.PUT_LINE('Nadeszła 25 sekunda!');
END;

-- 9. Napisz  program,  który  dla  podanej w zmiennej wartości n obliczy  wartość  wyrażenia n! = 1 * 2 * 3 * ... * n
DECLARE
    vn     number     := 10;
    vvalue NUMBER(10) := 1;
BEGIN
    FOR viter IN 1..vn
        loop
            vvalue := vvalue * viter;
        END loop;
    DBMS_OUTPUT.PUT_LINE('Silnia dla n=' || vn || ': ' || vvalue);
END;

-- 10. Napisz program który wyliczy, kiedy w XXI wieku będą piątki przypadające na 13 dzień miesiąca.
DECLARE
    vday DATE;
BEGIN
    FOR YEAR IN 2001..2100
        loop
            FOR MONTH IN 1..12
                loop
                    vday := TO_DATE(TO_CHAR(YEAR) || '-' || TO_CHAR(MONTH) || '-13', 'YYYY-MM-DD');
                    IF (TO_CHAR(vday, 'D') = 6)
                    THEN
                        DBMS_OUTPUT.PUT_LINE(TO_CHAR(vday, 'YYYY-MM-DD'));
                    END IF;
                END loop;
        END loop;
END;