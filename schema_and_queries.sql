// 1

create database pandemic;
use pandemic

// 2

CREATE TABLE countries (
	country_id int auto_increment,
    Entity VARCHAR(100) NOT NULL,
    Code VARCHAR(10) NULL,
    PRIMARY KEY (country_id)
);

INSERT INTO countries (Entity, Code)
SELECT DISTINCT entity, code
FROM infectious_cases
ON DUPLICATE KEY UPDATE Entity = VALUES(Entity), Code = VALUES(Code);

CREATE TABLE diseases (
    DiseaseID INT AUTO_INCREMENT PRIMARY KEY,
    DiseaseName VARCHAR(100) NOT NULL
);

INSERT INTO diseases (DiseaseName) VALUES ('Yaws');
INSERT INTO diseases (DiseaseName) VALUES ('Polio');
INSERT INTO diseases (DiseaseName) VALUES ('Guinea Worm');
INSERT INTO diseases (DiseaseName) VALUES ('Rabies');
INSERT INTO diseases (DiseaseName) VALUES ('Malaria');
INSERT INTO diseases (DiseaseName) VALUES ('HIV');
INSERT INTO diseases (DiseaseName) VALUES ('Tuberculosis');
INSERT INTO diseases (DiseaseName) VALUES ('Smallpox');
INSERT INTO diseases (DiseaseName) VALUES ('Cholera');


CREATE TABLE cases (
    CaseID INT AUTO_INCREMENT PRIMARY KEY,
    CountryID INT NOT NULL,
    Year INT NOT NULL,
    DiseaseID INT NOT NULL,
    Number INT NULL,
    FOREIGN KEY (CountryID) REFERENCES countries(country_id),
    FOREIGN KEY (DiseaseID) REFERENCES diseases(DiseaseID)
);

INSERT INTO cases (CountryID, Year, DiseaseID, Number)
SELECT c.country_id AS country_id, 
       ic.Year, 
       1 AS DiseaseID, 
       COALESCE(NULLIF(ic.Number_yaws, ''), null)
FROM infectious_cases ic
INNER JOIN countries c ON ic.Entity = c.Entity

INSERT INTO cases (CountryID, Year, DiseaseID, Number)
SELECT c.country_id AS country_id, 
       ic.Year, 
       2 AS DiseaseID, 
       COALESCE(NULLIF(ic.polio_cases, ''), null)
FROM infectious_cases ic
INNER JOIN countries c ON ic.Entity = c.Entity

INSERT INTO cases (CountryID, Year, DiseaseID, Number)
SELECT c.country_id AS country_id, 
       ic.Year, 
       3 AS DiseaseID, 
       COALESCE(NULLIF(ic.cases_guinea_worm, ''), null)
FROM infectious_cases ic
INNER JOIN countries c ON ic.Entity = c.Entity

INSERT INTO cases (CountryID, Year, DiseaseID, Number)
SELECT c.country_id AS country_id, 
       ic.Year, 
       4 AS DiseaseID, 
       COALESCE(NULLIF(ic.number_rabies, ''), null)
FROM infectious_cases ic
INNER JOIN countries c ON ic.Entity = c.Entity

INSERT INTO cases (CountryID, Year, DiseaseID, Number)
SELECT c.country_id AS country_id, 
       ic.Year, 
       5 AS DiseaseID, 
       COALESCE(NULLIF(ic.number_malaria, ''), null)
FROM infectious_cases ic
INNER JOIN countries c ON ic.Entity = c.Entity

INSERT INTO cases (CountryID, Year, DiseaseID, Number)
SELECT c.country_id AS country_id, 
       ic.Year, 
       6 AS DiseaseID, 
       COALESCE(NULLIF(ic.number_hiv, ''), null)
FROM infectious_cases ic
INNER JOIN countries c ON ic.Entity = c.Entity

INSERT INTO cases (CountryID, Year, DiseaseID, Number)
SELECT c.country_id AS country_id, 
       ic.Year, 
       7 AS DiseaseID, 
       COALESCE(NULLIF(ic.number_tuberculosis, ''), null)
FROM infectious_cases ic
INNER JOIN countries c ON ic.Entity = c.Entity

INSERT INTO cases (CountryID, Year, DiseaseID, Number)
SELECT c.country_id AS country_id, 
       ic.Year, 
       8 AS DiseaseID, 
       COALESCE(NULLIF(ic.number_smallpox, ''), null)
FROM infectious_cases ic
INNER JOIN countries c ON ic.Entity = c.Entity

INSERT INTO cases (CountryID, Year, DiseaseID, Number)
SELECT c.country_id AS country_id, 
       ic.Year, 
       9 AS DiseaseID, 
       COALESCE(NULLIF(ic.number_cholera_cases, ''), null)
FROM infectious_cases ic
INNER JOIN countries c ON ic.Entity = c.Entity

// 3

SELECT 
    c.country_id,
    c.Entity,
    c.Code,
    AVG(ic.Number_rabies) AS avg_rabies,
    MIN(ic.Number_rabies) AS min_rabies,
    MAX(ic.Number_rabies) AS max_rabies,
    SUM(ic.Number_rabies) AS sum_rabies
FROM 
    infectious_cases ic
INNER JOIN 
    countries c ON ic.Entity = c.Entity
where ic.Number_rabies > 0
GROUP BY c.country_id, c.Entity, c.Code
ORDER BY avg_rabies DESC
LIMIT 10;


Normalized:

SELECT distinct
    cs.countryId,
    c.entity,
    c.code,
    AVG(cs.number) AS avg_rabies,
    MIN(cs.number) AS min_rabies,
    MAX(cs.number) AS max_rabies,
    SUM(cs.number) AS sum_rabies
FROM cases cs
INNER JOIN 
    countries c ON cs.CountryID = c.country_id
WHERE 
    cs.diseaseID = 4
GROUP BY 
    cs.countryId, c.entity, c.code
ORDER BY 
    avg_rabies DESC
LIMIT 10;

// 4

SELECT 
    entity,
    code,
    year,
    CONCAT(year, '-01-01') AS first_january_year,
    CURDATE() AS current_dt,
    TIMESTAMPDIFF(YEAR, CONCAT(year, '-01-01'), CURDATE()) AS year_difference
FROM 
    infectious_cases
order by year desc;

Normalized:

SELECT 
    cases.countryId,
    cases.year,
    CONCAT(cases.year, '-01-01') AS first_january_year,
    CURDATE() AS current_dt,
    TIMESTAMPDIFF(YEAR, CONCAT(cases.year, '-01-01'), CURDATE()) AS year_difference
FROM 
    cases
group by 
    cases.countryId,
    cases.year
order by cases.year desc;

// 5

DELIMITER $

CREATE FUNCTION year_difference(input_year INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE result INT;
    SET result = TIMESTAMPDIFF(YEAR, CONCAT(input_year, '-01-01'), CURDATE());
    RETURN result;
END$

DELIMITER ;

SELECT 
    cases.countryId,
    cases.year,
    year_difference(cases.year) AS year_difference
FROM 
    cases
group by 
    cases.countryId,
    cases.year
order by cases.year desc;