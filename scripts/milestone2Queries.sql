SELECT year, COUNT(*) FROM Production WHERE kind NOT IN ('episode', 'tv series', 'video game') GROUP BY year;
SELECT country_code as country, COUNT(*) as number from Company WHERE NOT isNull(country_code) GROUP BY country_code  ORDER BY number DESC LIMIT 10;
SELECT MIN(duration) as min, MAX(duration) as max, AVG(duration) as average from (SELECT MAX(year) - MIN(year) as duration, pid FROM PersonParticipatesProduction as PPP JOIN Production ON PPP.prodid = Production.prodid GROUP BY pid HAVING NOT isNull(duration)) as T;

-- compute the min, max and average number of actors in a production
SELECT MIN(c) as min, MAX(c) as max, AVG(c) as avg FROM 
    (SELECT DISTINCT pid, prodid, COUNT(*) as c FROM PersonParticipatesProduction where role IN ('actor', 'actress') GROUP BY prodid) as A;

-- compute the min, max and average height of female persons
SELECT MIN(height), MAX(height), AVG(height) FROM Person WHERE gender = 0;

--f) Get all the actors that are also directors in a production, excluding tv movies and video movies
SELECT Person.first_name, Person.last_name, Production.title
FROM PersonParticipatesProduction Pers1 
    JOIN PersonParticipatesProduction Pers2 
        ON (Pers1.pid = Pers2.pid AND Pers1.prodid = Pers2.prodid 
            AND Pers1.role IN ('actor', 'actress') AND Pers2.role = 'director') 
        JOIN Production ON (Production.prodid = Pers1.prodid 
        AND Production.kind = 'movie')
        JOIN Person ON (Pers1.pid = Person.pid); 

--g) Get the three most popular character names
SELECT Persona.name, appearances FROM Persona JOIN (SELECT DISTINCT charid, count(*) AS appearances from PersonParticipatesProduction WHERE charid IS NOT NULL GROUP BY charid ORDER BY appearances DESC LIMIT 3) C ON (Persona.charid = C.charid);
