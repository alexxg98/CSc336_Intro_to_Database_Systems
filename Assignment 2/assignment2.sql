DROP DATABASE IF EXISTS assignment2;
CREATE DATABASE assignment2;
use assignment2;

CREATE TABLE Persons(
	id INT PRIMARY KEY,
	name VARCHAR(25),
	dateOfBirth DATE NOT NULL,
	gender ENUM('F', 'M')
);
CREATE TABLE Family(
	person INT PRIMARY KEY,
	father INT,
	mother INT,
	FOREIGN KEY(person) REFERENCES PERSONS(id),
	FOREIGN KEY(father) REFERENCES PERSONS(id),
	FOREIGN KEY(mother) REFERENCES PERSONS(id)
);

CREATE TABLE Brothers(
	c INT REFERENCES Persons(id),
    d INT REFERENCES Persons(id),
    PRIMARY KEY (c, d)
);

CREATE TABLE Sisters(
	g INT REFERENCES Persons(id),
    h INT REFERENCES Persons(id),
    PRIMARY KEY (g, h)
);

CREATE TABLE Brother_Sister(
	e INT REFERENCES Persons(id),
    f INT REFERENCES Persons(id),
    PRIMARY KEY (e, f)
);

CREATE TABLE Husband_Wife(
	a INT REFERENCES Persons(id),
    b INT REFERENCES Persons(id),
    PRIMARY KEY (a, b)
);

CREATE TABLE Sister_in_law(
	x INT REFERENCES Persons(id),
    y INT REFERENCES Persons(id),
    PRIMARY KEY (x, y)
);

INSERT INTO Persons VALUES 
(1, "Jay Pritchett", '1947-05-23', 'M'),
(2, "Gloria Pritchett", '1971-05-10', 'F'),
(3, "Frank Dunphy", '1944-08-01', 'M'),
(4, "Grace Dunphy", '1946-05-12', 'F'),
(5, "Claire Dunphy", '1970-03-03', 'F'),
(6, "Mitchell Pritchett", '1975-06-03', 'M'),
(7, "Phil Dunphy", '1969-04-03', 'M'),
(8, "Cameron Tucker", '1972-02-29', 'M'),
(9, "Haley Dunphy", '1993-12-10', 'F'),
(10, "Alex Dunphy", '1997-01-14', 'F'),
(11, "Luke Dunphy", '1998-11-28', 'M'),
(12, "Lily Tucker-Pritchett", '2008-02-19', 'F'),
(13, "Joe Pritchett", '2013-01-04', 'M'),
(14, "Merle Tucker", '1940-01-05', 'M'),
(15, "Barb Tucker", '1945-07-25', 'F'),
(16, "Manny Delgado", '1998-01-04', 'M'),
(17, "Guy Tucker", '1970-05-14', 'M'),
(18, "Carol Tucker", '1971-04-16', 'F'),
(19, "Pam Tucker", '1972-04-03', 'F'),
(20, "Bo Johnson", '1971-05-17', 'M'),
(21, "Dylan Marshall", '1991-03-23', 'M');

INSERT INTO Family VALUES
(12, 6, 8),
(11, 7, 5),
(10, 7, 5),
(9, 7, 5),
(7, 3, 4),
(6, 1, 2),
(5, 1, 2),
(13, 1, 2),
(14, 1, 2),
(8, 15, 16),
(17, 15, 16),
(19, 15, 16);

INSERT INTO Brothers
SELECT f1.person AS 'c', f2.person AS 'd'
FROM (SELECT * FROM Family WHERE person IN (SELECT id FROM Persons WHERE gender = 'M')) f1,
	(SELECT * FROM Family WHERE person IN (SELECT id FROM Persons WHERE gender = 'M')) f2
WHERE f1.father=f2.father AND f1.mother=f2.mother AND NOT f1.person=f2.person;

INSERT INTO Sisters
SELECT f1.person AS 'g', f2.person AS 'h'
FROM (SELECT * FROM Family WHERE person IN (SELECT id FROM Persons WHERE gender = 'F')) f1,
	(SELECT * FROM Family WHERE person IN (SELECT id FROM Persons WHERE gender = 'F')) f2
WHERE f1.father=f2.father AND f1.mother=f2.mother AND NOT f1.person=f2.person;

INSERT INTO Brother_Sister
SELECT f1.person AS 'e', f2.person AS 'f'
FROM (SELECT * FROM Family WHERE person IN (SELECT id FROM Persons WHERE gender = 'M')) f1,
	(SELECT * FROM Family WHERE person IN (SELECT id FROM Persons WHERE gender = 'F')) f2
WHERE f1.father=f2.father AND f1.mother=f2.mother AND NOT f1.person=f2.person;

INSERT INTO Husband_Wife VALUES
(1, 2),
(3, 4),
(7, 5),
(6, 8),
(8, 6),
(17, 18),
(20, 19),
(21, 9);
SET @personY= 17;

INSERT INTO Sister_in_law
SELECT DISTINCT f1.b AS 'x', f2.id AS 'y'
FROM (SELECT b FROM Husband_Wife 
	WHERE a IN (SELECT c FROM Brothers WHERE d=@personY) 
		OR a IN (SELECT e FROM Brother_Sister WHERE f=@personY)
        OR a IN (SELECT c FROM Brothers WHERE d IN (SELECT a FROM Husband_Wife WHERE b=@personY))
		OR a in (SELECT e FROM Brother_Sister WHERE f IN (SELECT b FROM Husband_Wife WHERE a=@personY))
	UNION 
	SELECT f FROM Brother_Sister WHERE e IN (SELECT a FROM Husband_Wife WHERE b = @personY)
	UNION
	SELECT g FROM Sisters WHERE h IN (SELECT b FROM Husband_Wife WHERE a = @personY)) f1,
	(SELECT * FROM Persons WHERE id=@personY) f2
WHERE NOT EXISTS (SELECT * FROM Sister_in_law 
      WHERE x=b AND y=@personY);
Select * FRom Sister_in_law;

SET @personY= 17;
SELECT name AS "Sister-In-Law" FROM Persons 
WHERE id IN (SELECT b FROM Husband_Wife 
	-- Def1
	WHERE a IN (SELECT c FROM Brothers WHERE d=@personY)
		OR a IN (SELECT e FROM Brother_Sister WHERE f=@personY)
	-- Def3
		OR a IN (SELECT c FROM Brothers WHERE d IN (SELECT a FROM Husband_Wife WHERE b=@personY))
		OR a in (SELECT e FROM Brother_Sister WHERE f IN (SELECT b FROM Husband_Wife WHERE a=@personY))
	-- Def2
	UNION 
	SELECT f FROM Brother_Sister WHERE e IN (SELECT a FROM Husband_Wife WHERE b = @personY)
	UNION
	SELECT g FROM Sisters WHERE h IN (SELECT b FROM Husband_Wife WHERE a = @personY));



SET @personY= 20;
SELECT name AS "Sister-In-Law" FROM Persons WHERE id IN (
SELECT distinct sil.b from Husband_wife sil
JOIN Brothers pb_bro ON sil.a=pb_bro.c
JOIN Brother_Sister pf_bro ON sil.a=pf_bro.e
WHERE pb_bro.d=@personY OR pf_bro.f=@personY
UNION
SELECT distinct f from Brother_Sister
JOIN Husband_Wife on a=e
WHERE b=@personY
UNION
SELECT distinct g from Sisters JOIN Husband_Wife on b=h
WHERE a=@personY
UNION
SELECT distinct sil.b from Husband_wife sil
JOIN Brothers hb ON sil.a=hb.c
JOIN Husband_Wife w on hb.d=w.a
JOIN Brother_Sister wb ON sil.a=wb.e
JOIN Husband_Wife h on wb.f=h.b
WHERE w.b=@personY OR h.a=@personY);
