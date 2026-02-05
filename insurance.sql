CREATE DATABASE insurance;
USE insurance;



CREATE TABLE PERSON (
 driver_id VARCHAR(20) PRIMARY KEY,
 name VARCHAR(50),
 address VARCHAR(100)
);
CREATE TABLE CAR (
 regno VARCHAR(20) PRIMARY KEY,
 model VARCHAR(30),
 year INT
);
CREATE TABLE ACCIDENT (
 report_number INT PRIMARY KEY,
 acc_date DATE,
 location VARCHAR(100)
);
CREATE TABLE OWNS (
 driver_id VARCHAR(20),
 regno VARCHAR(20),
 PRIMARY KEY (driver_id, regno),
 FOREIGN KEY (driver_id) REFERENCES PERSON(driver_id),
 FOREIGN KEY (regno) REFERENCES CAR(regno)
);
CREATE TABLE PARTICIPATED (
 driver_id VARCHAR(20),
 regno VARCHAR(20),
 report_number INT,
 damage_amount INT,
 PRIMARY KEY (driver_id, regno, report_number),
 FOREIGN KEY (driver_id) REFERENCES PERSON(driver_id),
 FOREIGN KEY (regno) REFERENCES CAR(regno),
 FOREIGN KEY (report_number) REFERENCES ACCIDENT(report_number)
);

INSERT INTO PERSON VALUES 
('D001', 'Smith', '123 Main St'),
('D002', 'Johnson', '456 Oak Ave'),
('D003', 'Williams', '789 Pine Rd'),
('D004', 'Brown', '321 Elm St'),
('D005', 'Davis', '654 Maple Dr');

INSERT INTO CAR VALUES 
('KA01AB1234', 'Honda', 2020),
('KA02CD5678', 'Mazda', 2019),
('KA09MA1234', 'Toyota', 2021),
('KA03EF9012', 'Ford', 2018),
('KA04GH3456', 'Nissan', 2022);

INSERT INTO ACCIDENT VALUES 
(1, '2021-03-15', 'MG Road'),
(2, '2021-06-20', 'Brigade Road'),
(3, '2022-01-10', 'Indiranagar'),
(4, '2021-09-05', 'Koramangala'),
(5, '2023-02-14', 'Whitefield');

INSERT INTO OWNS VALUES 
('D001', 'KA01AB1234'),
('D001', 'KA02CD5678'),
('D002', 'KA09MA1234'),
('D003', 'KA03EF9012'),
('D004', 'KA04GH3456');

INSERT INTO PARTICIPATED VALUES 
('D001', 'KA01AB1234', 1, 25000),
('D001', 'KA02CD5678', 2, 15000),
('D002', 'KA09MA1234', 3, 30000),
('D003', 'KA03EF9012', 4, 20000),
('D004', 'KA04GH3456', 5, 10000);

 Total people who owned cars in accidents in 2021
SELECT COUNT(DISTINCT P.driver_id) AS total_people
FROM PERSON P, OWNS O, PARTICIPATED PA, ACCIDENT A
WHERE P.driver_id = O.driver_id 
AND O.regno = PA.regno 
AND PA.report_number = A.report_number
AND YEAR(A.acc_date) = 2021;


SELECT COUNT(DISTINCT PA.report_number) AS num_accidents
FROM PARTICIPATED PA, OWNS O, PERSON P
WHERE PA.driver_id = O.driver_id 
AND PA.regno = O.regno 
AND O.driver_id = P.driver_id
AND P.name = 'Smith';


INSERT INTO ACCIDENT VALUES (6, '2024-12-30', 'Jayanagar');


DELETE FROM CAR
WHERE regno IN (
 SELECT O.regno
 FROM OWNS O, PERSON P
 WHERE O.driver_id = P.driver_id 
 AND P.name = 'Smith' 
 AND O.regno IN (SELECT regno FROM CAR WHERE model = 'Mazda')
);


UPDATE PARTICIPATED
SET damage_amount = 35000
WHERE regno = 'KA09MA1234';


CREATE VIEW AccidentCars AS
SELECT DISTINCT C.model, C.year
FROM CAR C, PARTICIPATED PA
WHERE C.regno = PA.regno;


DELIMITER //
CREATE TRIGGER limit_accidents
BEFORE INSERT ON PARTICIPATED
FOR EACH ROW
BEGIN
 DECLARE accident_count INT;
 SELECT COUNT(*) INTO accident_count
 FROM PARTICIPATED PA, ACCIDENT A
 WHERE PA.driver_id = NEW.driver_id 
 AND PA.report_number = A.report_number
 AND YEAR(A.acc_date) = (
 SELECT YEAR(acc_date) FROM ACCIDENT WHERE report_number = NEW.report_number
 );
 IF accident_count >= 3 THEN
 SIGNAL SQLSTATE '45000'
 SET MESSAGE_TEXT = 'Driver cannot participate in more than 3 accidents per year';
 END IF;
END;//
DELIMITER ;
