BEGIN
    --sprzątanie
    IF OBJECT_ID ('dbo.eventservices', 'U') IS NOT NULL
        DROP TABLE eventservices;
    IF OBJECT_ID ('dbo.funeral', 'U') IS NOT NULL
        DROP TABLE funeral;
    IF OBJECT_ID ('dbo.payment', 'U') IS NOT NULL
        DROP TABLE payment;
    IF OBJECT_ID ('dbo.guests', 'U') IS NOT NULL
        DROP TABLE guests;
    IF OBJECT_ID ('dbo.event', 'U') IS NOT NULL
        DROP TABLE event;
    IF OBJECT_ID ('dbo.churches', 'U') IS NOT NULL
        DROP TABLE churches;
    IF OBJECT_ID ('dbo.coffinsandcaskets', 'U') IS NOT NULL
        DROP TABLE coffinsandcaskets;
    IF OBJECT_ID ('dbo.restinggrounds', 'U') IS NOT NULL
        DROP TABLE restinggrounds;
    IF OBJECT_ID ('dbo.extraservices', 'U') IS NOT NULL
        DROP TABLE extraservices;
    IF OBJECT_ID ('dbo.guests', 'U') IS NOT NULL
        DROP TABLE guests;

    IF OBJECT_ID ('dbo.admin', 'U') IS NOT NULL
        DROP TABLE admin;
    IF OBJECT_ID ('dbo.clients', 'U') IS NOT NULL
        DROP TABLE clients;

    -- logowanie
    CREATE TABLE admin (
        id_admin INTEGER IDENTITY(1,1) PRIMARY KEY,
        username VARCHAR(32) NOT NULL,
        password VARCHAR(32) NOT NULL
    );

    Insert INTO admin(username, password)
    VALUES ('admin', 'admin')

    CREATE TABLE clients (
        id_client      INTEGER IDENTITY(1,1) PRIMARY KEY,
        name           VARCHAR(64) NOT NULL,
        username       VARCHAR(32) NOT NULL UNIQUE,
        password       VARCHAR(32) NOT NULL,
        address        VARCHAR(256),
        phone_number   VARCHAR(12),
        mail           VARCHAR(64) NOT NULL UNIQUE,
        constraint chk_phone_c check (phone_number like '[+][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
        constraint chk_mail_c check (mail like '%_@__%.__%')
    );

    Insert Into clients(name, username, password, mail)
    VALUES ('Jan Kowalski', 'client', 'client', 'jan.kowalski@gmail.com');

    Insert Into clients(name, username, password, mail, phone_number)
    VALUES ('Jan Kowalski', 'client2', 'client', 'jan.kowalski2@gmail.com', '+48123456789');

    -- elementy pogrzebu
    CREATE TABLE churches (
        id_church INTEGER IDENTITY(1,1) PRIMARY KEY,
        name      VARCHAR(256) NOT NULL,
        address   VARCHAR(256) NOT NULL,
        cost      NUMERIC(6, 2) NOT NULL,
        photo     VARCHAR(999),
        isAvailable bit NOT NULL
    );

    INSERT INTO churches(name, address, cost, photo, isAvailable)
    VALUES (N'Bazylika kolegiacka Matki Bożej Nieustającej Pomocy, św. Marii Magdaleny i św. St.Biskupa',
            N'Klasztorna 11, 61-779 Poznań', 2500.00, 'https://upload.wikimedia.org/wikipedia/commons/7/79/Fara_od_ulicy_Podg%C3%B3rnej.jpg', 1),
           (N'Kościół Najświętszego Zbawiciela w Poznaniu',
            N'Fredry 11, 61-701 Poznań', 2000.00, 'https://upload.wikimedia.org/wikipedia/commons/e/ea/Ko%C5%9Bci%C3%B3%C5%82_Naj%C5%9Bwi%C4%99tszego_Zbawiciela_Pozna%C5%84.JPG', 1),
           (N'Dowolny kościół',
            N'Poznań', 1500.00, '', 1);


    CREATE TABLE coffinsandcaskets (
        id_cnc INTEGER IDENTITY(1,1) PRIMARY KEY,
        name      VARCHAR(256) NOT NULL,
        material  VARCHAR(256) NOT NULL,
        cost      NUMERIC(6, 2) NOT NULL,
        photo     VARCHAR(999),
        isAvailable bit NOT NULL
    );

    Insert Into coffinsandcaskets (name, material, cost, isAvailable, photo)
    VALUES ('TD53c', N'dąb', 2499.99, 1, 'https://media.istockphoto.com/photos/oak-coffin-casket-isolated-on-white-with-clipping-path-picture-id176905622?k=20&m=176905622&s=170667a&w=0&h=JOs0EkBGtHxvfUVY5U7cXq6l7njcaIir40sW_4xa8-k='),
           ('TO8b', 'olcha', 1899.99, 1, 'https://vitoluad.lv/assets/Z%C4%81rki/gatavs-zarki--61.jpg'),
           (N'TDZ30 (dziecięca)', 'sosna', 999.99, 1, 'https://trappistcaskets.com/wp-content/uploads/2018/11/Simple-Shaped-Pine_lg.jpg'),
           ('TS44ci', 'sosna', 1399.99, 1, 'https://naturalendings.co.uk/wp/wp-content/uploads/2019/02/pine-coffin.png'),
           ('UC1m', 'ceramiczna', 1299.99, 1, 'https://www.butterworthurns.com/wp/wp-content/uploads/2017/04/Blossom-Ceramic-1810BC.jpg'),
           ('UMK3', 'granitowa', 1299.99, 1, 'https://aestheticurns.co.uk/wp-content/uploads/2019/09/U21C-MB_1.jpg');

    CREATE TABLE restinggrounds (
        id_restinggrounds INTEGER IDENTITY(1,1) PRIMARY KEY,
        name         VARCHAR(256) NOT NULL,
        cost         NUMERIC(6, 2) NOT NULL,
        isAvailable bit NOT NULL
    );

    Insert Into restinggrounds (name, cost, isAvailable)
    VALUES ('Miejski I', 899.99, 1),
           ('Miejski II', 799.99, 1);

    CREATE TABLE extraservices (
        id_service         INTEGER IDENTITY(1,1) PRIMARY KEY,
        name               VARCHAR(256) NOT NULL,
        description        VARCHAR(256),
        cost               NUMERIC(6, 2) NOT NULL,
        isAvailable bit NOT NULL
    );

    Insert Into extraservices (name, description, cost, isAvailable)
    VALUES (N'Usługa przyśpieszona', 'realizacja nawet w 72h', 800.00, 1),
           ('Organista', N'muzyka podczas ostatnej podróży', 700.00, 1),
           (N'Własne ubrania', N'zapewnienie własnych ubrań dla zmarłego', 0.00, 1);

    -- wydarzenia
    CREATE TABLE event (
        id_event                    INTEGER IDENTITY(1,1) PRIMARY KEY,
        client_id_client            INTEGER NOT NULL FOREIGN KEY REFERENCES clients(id_client),
        name                        VARCHAR(256),
        restinggrounds_id_cementary INTEGER NOT NULL FOREIGN KEY REFERENCES restinggrounds(id_restinggrounds),
        churches_id_church          INTEGER NOT NULL FOREIGN KEY REFERENCES churches(id_church)
    );

    Insert Into event (client_id_client, name, restinggrounds_id_cementary, churches_id_church)
    VALUES (1, '', 1, 1),
           (1, N'Wydarzenie z nazwą', 2, 2);


    CREATE TABLE eventservices ( --n:m
        id_event INT NOT NULL,
        id_service INT NOT NULL,
        constraint pk_es PRIMARY KEY (id_event, id_service),
        constraint fk_es_e FOREIGN KEY (id_event) REFERENCES event(id_event) ON DELETE CASCADE ,
        constraint fk_es_s FOREIGN KEY (id_service) REFERENCES extraservices(id_service) ON DELETE CASCADE
    );

    Insert INTO eventservices (id_event, id_service)
    VALUES (1, 1), (1, 2), (2, 3);

    CREATE TABLE funeral (
        id_funeral                  INTEGER IDENTITY(1,1) PRIMARY KEY,
        name                        VARCHAR(64) NOT NULL,
        surname                     VARCHAR(64) NOT NULL,
        date_of_death             	DATETIME2 NOT NULL,
        event_id_event              INTEGER NOT NULL FOREIGN KEY REFERENCES event(id_event) ON DELETE CASCADE ,
        coffinsandcaskets_id_cnc    INTEGER NOT NULL FOREIGN KEY REFERENCES coffinsandcaskets(id_cnc)
    );

    Insert Into funeral(name, surname, date_of_death, event_id_event, coffinsandcaskets_id_cnc)
    VALUES ('Jan', 'Pierwszy Kowalski', CURRENT_TIMESTAMP, 1, 1),
           ('Jan', 'Drugi Kowalski', CURRENT_TIMESTAMP, 1, 2),
           ('Jan', 'Trzeci Kowalski', CURRENT_TIMESTAMP, 2, 5);

    CREATE TABLE payment (
        id_payment     INTEGER IDENTITY(1,1) PRIMARY KEY,
        date_paid      DATETIME2,
        amount         NUMERIC(6, 2) NOT NULL,
        event_id_event INTEGER NOT NULL FOREIGN KEY REFERENCES event(id_event)
    );

    Insert Into payment (date_paid, amount, event_id_event)
    VALUES (CURRENT_TIMESTAMP, 1.00, 1);

    Insert Into payment (amount, event_id_event)
    VALUES (2.00, 1);

    CREATE TABLE guests (
        id_guest       INTEGER IDENTITY(1,1) PRIMARY KEY,
        name           VARCHAR(64) NOT NULL,
        mail           VARCHAR(64) NOT NULL,
        event_id_event INTEGER NOT NULL FOREIGN KEY REFERENCES event(id_event) ON DELETE CASCADE ,
        constraint chk_mail_g check (mail like '%_@__%.__%')
    );

    DROP INDEX IF EXISTS idx_payment_event ON payment
    Create INDEX idx_payment_event On payment(event_id_event);

    DROP INDEX IF EXISTS idx_funeral_event ON payment
    Create INDEX idx_funeral_event On funeral(event_id_event);

End;

GO
Create or alter function dbo.Login (@login VARCHAR(32), @pwd VARCHAR(32))
RETURNS VARCHAR(3) AS
Begin

    If EXISTS(SELECT id_admin FROM admin WHERE username=@login and password=@pwd)
        return 'adm';
    else
    If EXISTS(SELECT id_client FROM clients WHERE (username=@login or mail=@login) and password=@pwd)
       return 'usr';

    return 'nul'
end;

GO
Create or alter function dbo.SumPayment (@event_id INT)
RETURNS FLOAT AS
Begin
    Declare @id_restinggrounds int, @id_church int;

    SELECT @id_restinggrounds = restinggrounds_id_cementary, @id_church = churches_id_church
    from dbo.event WHERE id_event = @event_id;

    return
        IsNull((SELECT cost from churches WHERE id_church = @id_church), 0) +
        IsNull((SELECT cost from restinggrounds WHERE id_restinggrounds = @id_restinggrounds), 0) +
        IsNull((Select SUM(cost) cost FROM (SELECT COUNT(1) * cost cost FROM funeral left join coffinsandcaskets c on c.id_cnc = funeral.coffinsandcaskets_id_cnc  WHERE event_id_event = 1 GROUP BY coffinsandcaskets_id_cnc, cost) cst), 0) +
        IsNull((SELECT Sum(cost) cost FROM eventservices left join extraservices e on e.id_service = eventservices.id_service Where id_event = @event_id), 0);
end;

GO
Create or alter procedure dbo.AddPayment (@event_id INT) AS
Begin
    Declare @payment FLOAT = dbo.SumPayment(@event_id);
    Insert Into payment(amount, event_id_event)
    values (@payment, @event_id);
end;

PRINT dbo.Login ('admin1', 'admin');
PRINT dbo.Login ('client', 'client');

PRINT dbo.SumPayment(1);
PRINT dbo.SumPayment(14);

EXEC AddPayment 1;
