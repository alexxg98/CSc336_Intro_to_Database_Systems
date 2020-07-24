DROP DATABASE IF EXISTS assignment1;
CREATE DATABASE assignment1;
use assignment1;

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


INSERT Persons VALUES 
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
(12, "Lily Tucker-Pritchett", '2008-02-19', 'F');

INSERT Family VALUES
(12, 6, 8),
(11, 7, 5),
(10, 7, 5),
(9, 7, 5),
(7, 3, 4),
(6, 1, 2),
(5, 1, 2);

SELECT (SELECT name FROM Persons WHERE id=person) FROM Family;

SELECT * FROM Persons;
SELECT * FROM Family;
SELECT (SELECT name FROM Persons WHERE person = id) as person, 
		(SELECT name FROM Persons WHERE father = id) as father, 
		(SELECT name FROM Persons WHERE mother = id) as mother
FROM Family;


SELECT name, gender FROM Persons INNER JOIN FAMILY ON Persons.id=Family.person WHERE Family.father=7 AND Family.mother=5;

SELECT name AS 'Child',
		gender AS 'Gender',
		(SELECT name FROM Persons WHERE Persons.id = Family.father) AS 'Father',
		(SELECT name FROM Persons WHERE Persons.id = Family.mother) AS 'Mother' 
FROM Persons INNER JOIN Family ON Persons.id=Family.person 
WHERE Family.father=7 AND Family.mother=5;
            
SELECT p.name AS 'Child',
		p.gender AS 'Gender',
		f.name AS 'Father',
        m.name AS 'Mother' FROM Persons p, Persons f, Persons m
WHERE (p.id, f.id, m.id)
IN (SELECT * FROM FAMILY WHERE (father, mother)
	IN (SELECT f.id, m.id FROM Persons f, Persons m WHERE f.name = "Phil Dunphy" AND m.Name = "Claire Dunphy"));
    
SELECT name AS 'Child',
		gender AS 'Gender',
		(SELECT name FROM Persons WHERE Persons.id = Family.father) AS 'Father',
		(SELECT name FROM Persons WHERE Persons.id = Family.mother) AS 'Mother' 
FROM Persons INNER JOIN Family ON Persons.id=Family.person 
WHERE father = (SELECT id FROM Persons WHERE name = "Phil Dunphy") AND mother = (SELECT id FROM Persons WHERE name = "Claire Dunphy");

-- Getting Parents from Child name
SELECT p.name AS 'Child',
		p.gender AS 'Gender',
		f.name AS 'Father',
        m.name AS 'Mother' FROM Persons p, Persons f, Persons m
WHERE (p.id, f.id, m.id)
IN (SELECT * FROM FAMILY WHERE person
	IN (SELECT id FROM Persons WHERE name = "Lily Tucker-Pritchett"));
    
SELECT (SELECT name FROM Persons WHERE p.person = id) AS 'Person',
		(SELECT name FROM Persons WHERE m.mother = id) AS 'Maternal Grandmother',
        (SELECT name FROM Persons WHERE m.father = id) AS 'Maternal Grandfather',
        (SELECT name FROM Persons WHERE f.mother = id) AS 'Paternal Grandmother',
        (SELECT name FROM Persons WHERE f.father = id) AS 'Paternal Grandfather'
FROM (FAMILY p INNER JOIN Family m ON p.mother = m.person INNER JOIN Family f ON p.father = f.person)
WHERE p.person = 10;

SELECT p.name AS 'Person',
		mgm.name AS 'Maternal Grandmother',
        mgf.name AS 'Maternal Grandfather',
        pgm.name AS 'Paternal Grandmother',
        pgf.name AS 'Paternal Grandfather' FROM Persons p, Persons mgm, Persons mgf, Persons pgm, Persons pgf
WHERE (p.id, mgm.id, mgf.id, pgm.id, pgf.id)
	IN (SELECT p.person, f.father, f.mother, m.father, m.mother FROM Family p, Family f, Family m WHERE (p.person, f.person, m.person)
		IN (SELECT person, father, mother FROM Family WHERE person
			IN (SELECT id FROM Persons WHERE name = "Alex Dunphy")));
            
SELECT (SELECT name FROM Persons WHERE p.person = id) AS 'Person',
		(SELECT name FROM Persons WHERE m.mother = id) AS 'Maternal Grandmother',
        (SELECT name FROM Persons WHERE m.father = id) AS 'Maternal Grandfather',
        (SELECT name FROM Persons WHERE f.mother = id) AS 'Paternal Grandmother',
        (SELECT name FROM Persons WHERE f.father = id) AS 'Paternal Grandfather'
FROM (FAMILY p INNER JOIN Family m ON p.mother = m.person INNER JOIN Family f ON p.father = f.person)
WHERE p.person IN (SELECT id FROM Persons WHERE name = "Alex Dunphy");

SELECT (SELECT name FROM Persons WHERE id = p.person) AS 'Person',
		 (SELECT name FROM Persons WHERE id = m.mother) AS 'Maternal Grandmother',
		 (SELECT name FROM Persons WHERE id = m.father) AS 'Maternal Grandfather',
		 (SELECT name FROM Persons WHERE id = f.mother) AS 'Paternal Grandmother',
		 (SELECT name FROM Persons WHERE id = f.father) AS 'Paternal Grandfather'
FROM (FAMILY p INNER JOIN Family m ON p.mother = m.person INNER JOIN Family f ON p.father = f.person)
WHERE p.person IN (SELECT id FROM Persons WHERE name = "Alex Dunphy");

