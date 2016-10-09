-- DROP TABLES

DROP TABLE IF EXISTS ActorPlaysProduction;
DROP TABLE IF EXISTS PersonParticipatesProduction;
DROP TABLE IF EXISTS Persona;
DROP TABLE IF EXISTS CompanyContributesProduction;
DROP TABLE IF EXISTS Company;
DROP TABLE IF EXISTS Episode;
DROP TABLE IF EXISTS TV_Series;
DROP TABLE IF EXISTS ProductionAltName;
DROP TABLE IF EXISTS Production;
DROP TABLE IF EXISTS PersonAltName;
DROP TABLE IF EXISTS Person;

-- CREATE TABLES

CREATE TABLE Person
    (pid INTEGER NOT NULL AUTO_INCREMENT,
    first_name CHAR(100) NULL,
    last_name CHAR(127) NOT NULL,
    gender BOOLEAN NOT NULL,
    trivia TEXT NULL,
    quotes TEXT NULL,
    birth_date DATE NULL,
    death_date DATE NULL,
    birth_name CHAR(255) NULL,
    bio TEXT NULL,
    spouse CHAR(128) NULL,
    height FLOAT NULL,
    PRIMARY KEY (pid));

CREATE TABLE PersonAltName
    (altid INTEGER NOT NULL AUTO_INCREMENT,
    name CHAR(255) NOT NULL,
	pid INTEGER NOT NULL,
    PRIMARY KEY (altid),
    FOREIGN KEY (pid)
        REFERENCES Person(pid));

CREATE TABLE Production 
    (prodid INTEGER NOT NULL AUTO_INCREMENT,
    title CHAR(255) NOT NULL,
    year INTEGER NULL,
    seriesid INTEGER NULL,
    seasonnum INTEGER NULL,
    epnum INTEGER NULL,
    beginyear INTEGER NULL,
    endyear INTEGER NULL,
    kind ENUM('tv series', 'tv movie', 'episode', 'movie', 
		'video movie', 'video game') NOT NULL,
    genre ENUM('Action', 'Adventure', 'Animation', 'Biography',
		 'Comedy', 'Crime', 'Documentary', 'Drama', 'Family',
		 'Fantasy', 'Film-Noir', 'Game-Show', 'History',
		 'Horror', 'Music', 'Musical', 'Mystery', 'News',
		 'Reality-TV', 'Romance', 'Sci-Fi', 'Short', 'Sport', 
		 'Talk-Show', 'Thriller', 'War', 'Western') NULL,
    PRIMARY KEY (prodid));

CREATE TABLE ProductionAltName
    (altid INTEGER NOT NULL AUTO_INCREMENT,
    title CHAR(255) NOT NULL,
	prodid INTEGER NOT NULL,
    PRIMARY KEY (altid),
    FOREIGN KEY (prodid)
        REFERENCES Production(prodid));

CREATE TABLE Company
    (coid INTEGER NOT NULL AUTO_INCREMENT,
    country_code CHAR(4) NULL,
    name CHAR(255) NOT NULL,
    PRIMARY KEY (coid));

CREATE TABLE CompanyContributesProduction
    (prodid INTEGER NOT NULL,
    coid INTEGER NOT NULL,
	role ENUM('distributors', 'production companies') NOT NULL,
    PRIMARY KEY (prodid, coid, role),
    FOREIGN KEY (prodid) REFERENCES Production(prodid),
    FOREIGN KEY (coid) REFERENCES Company(coid));

CREATE TABLE Persona
    (charid INTEGER NOT NULL,
    name CHAR(100) NOT NULL,
	PRIMARY KEY (charid));

CREATE TABLE PersonParticipatesProduction
	(pppid BIGINT NOT NULL AUTO_INCREMENT,
	pid INTEGER NOT NULL,
	prodid INTEGER NOT NULL,
	role ENUM('actor', 'actress', 'producer', 'writer', 'cinematographer', 'composer', 
		'costume designer', 'director', 'editor',
		'miscellaneous crew', 'production designer') NOT NULL,
	charid INTEGER NULL,
	PRIMARY KEY (pppid),
	FOREIGN KEY (pid) REFERENCES Person(pid),
	FOREIGN KEY (charid) REFERENCES Persona(charid),
	FOREIGN KEY (prodid) REFERENCES Production(prodid));
