# Assignment: Family Relations
Write a java application that connects to the Family Relations database and implements the sql queries. The application has the following class inheritance heirarchy:

&nbsp;&nbsp;&nbsp;&nbsp;**Person**;

&nbsp;&nbsp;&nbsp;&nbsp;**Child** *is_a* **Person**;

&nbsp;&nbsp;&nbsp;&nbsp;**Grandparent** *is_a* **Person**;

&nbsp;&nbsp;&nbsp;&nbsp;**SisterInLaw** *is_a* **Person**;

---

**SQLFamily** interface includes all the necessary method signatures, static methods, and/or default methods for the execution of DML statements and SQL queries associated with our database.

Class **Person** (superclass) implements the  **SQLFamily** interface and includes the following methods:

+ setPerson - inserts a Person object into the database

+ get[X]Person - returns attribute X of a Person object (eg. getNamePerson)

+ toString - return the Person objects as a string

Classes **Child**, **GrandParent**, **SisterInLaw** inherits class **Person** and includes the following methods:

+ executeQuery - returns a list of persons who are the either the children, grandparents, or sisters-in-law of a given person (eg. getChildren returns the children of a given Person)

+ print the list from executeQuery