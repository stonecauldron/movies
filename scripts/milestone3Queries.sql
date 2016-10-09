-- f) Compute the average number of episodes per season
-- (7,25 sec)
SELECT seasonnum, AVG(c) FROM
    (SELECT seasonnum, COUNT(*) AS c FROM Production
    WHERE kind LIKE 'episode'
    AND seasonnum IS NOT NULL GROUP BY seriesid, seasonnum) AS T
GROUP BY seasonnum;

-- g) Compute the average number of seasons per series
-- (6,83 sec)
SELECT AVG(c) FROM
    (SELECT COUNT(*) as c FROM
            (SELECT DISTINCT seriesid, seasonnum FROM Production
            WHERE kind LIKE 'episode' AND seasonnum IS NOT NULL) AS T
    GROUP BY seriesid) as G;

-- h) Compute the top ten tv-series (by number of seasons)
-- (6,24 sec)
SELECT title, c
    FROM (SELECT seriesid as id, COUNT(*) as c FROM
        (SELECT DISTINCT seriesid, seasonnum FROM Production
        WHERE kind LIKE 'episode' AND seasonnum IS NOT NULL) AS T
    GROUP BY seriesid ORDER BY c DESC LIMIT 10) as G
JOIN Production as P2 ON id = P2.prodid;

-- i) Compute the top ten tv-series (by number of episodes per season)
-- (6,04 sec)
SELECT title, c FROM
    (SELECT seriesid as id, COUNT(*) AS c FROM Production
    WHERE kind LIKE 'episode'
    AND seasonnum IS NOT NULL
    GROUP BY seriesid, seasonnum ORDER BY c DESC LIMIT 10) as G
JOIN Production as P2 ON id = P2.prodid;

-- j) Find actors, actresses and directors who have movies (incl. tv and video
-- movies) released after their death (14,06 sec) without index
SELECT DISTINCT first_name, last_name FROM Production
NATURAL JOIN PersonParticipatesProduction
NATURAL JOIN Person WHERE death_date IS NOT NULL
AND YEAR(death_date) < Production.year
AND role IN ('director', 'actor', 'actress')
AND kind IN ('tv movie', 'movie', 'video movie');
