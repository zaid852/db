CREATE DATABASE company;
USE company;

CREATE TABLE DEPARTMENT (
 DNo INT PRIMARY KEY,
 DName VARCHAR(50),
 MgrSSN VARCHAR(20),
 MgrStartDate DATE
);
CREATE TABLE EMPLOYEE (
 SSN VARCHAR(20) PRIMARY KEY,
 Name VARCHAR(50),
 Address VARCHAR(100),
 Sex CHAR(1),
 Salary INT,
 SuperSSN VARCHAR(20),
 DNo INT,
 FOREIGN KEY (SuperSSN) REFERENCES EMPLOYEE(SSN),
 FOREIGN KEY (DNo) REFERENCES DEPARTMENT(DNo)
);
CREATE TABLE DLOCATION (
 DNo INT,
 DLoc VARCHAR(50),
 PRIMARY KEY (DNo, DLoc),
 FOREIGN KEY (DNo) REFERENCES DEPARTMENT(DNo)
);
CREATE TABLE PROJECT (
 PNo INT PRIMARY KEY,
 PName VARCHAR(50),
 PLocation VARCHAR(50),
 DNo INT,
 FOREIGN KEY (DNo) REFERENCES DEPARTMENT(DNo)
);
CREATE TABLE WORKS_ON (
 SSN VARCHAR(20),
 PNo INT,
 Hours INT,
 PRIMARY KEY (SSN, PNo),
 FOREIGN KEY (SSN) REFERENCES EMPLOYEE(SSN),
 FOREIGN KEY (PNo) REFERENCES PROJECT(PNo)
);

INSERT INTO DEPARTMENT VALUES 
(1, 'Research', 'E001', '2020-01-15'),
(2, 'Accounts', 'E002', '2019-06-20'),
(3, 'IT', 'E003', '2021-03-10'),
(4, 'HR', 'E004', '2018-09-05'),
(5, 'Operations', 'E005', '2022-02-14');

INSERT INTO EMPLOYEE VALUES 
('E001', 'John Scott', '123 Main St', 'M', 800000, NULL, 1),
('E002', 'Mary Johnson', '456 Oak Ave', 'F', 700000, 'E001', 2),
('E003', 'Robert Scott', '789 Pine Rd', 'M', 650000, 'E001', 3),
('E004', 'Lisa Brown', '321 Elm St', 'F', 550000, 'E002', 4),
('E005', 'David Wilson', '654 Maple Dr', 'M', 750000, 'E001', 5),
('E006', 'Sarah Davis', '987 Cedar Ln', 'F', 620000, 'E002', 2);

INSERT INTO DLOCATION VALUES 
(1, 'Bangalore'),
(2, 'Mumbai'),
(3, 'Delhi'),
(4, 'Chennai'),
(5, 'Hyderabad');

INSERT INTO PROJECT VALUES 
(1, 'IoT', 'Bangalore', 1),
(2, 'Cloud Computing', 'Mumbai', 3),
(3, 'AI Research', 'Delhi', 1),
(4, 'Data Analytics', 'Chennai', 5),
(5, 'Blockchain', 'Hyderabad', 5);

INSERT INTO WORKS_ON VALUES 
('E001', 1, 20),
('E001', 3, 15),
('E002', 2, 25),
('E003', 1, 30),
('E005', 4, 20),
('E005', 5, 18);

- Query 1: List projects involving employee with last name 'Scott'
SELECT DISTINCT P.PNo
FROM PROJECT P
WHERE P.DNo IN (
 SELECT D.DNo FROM DEPARTMENT D, EMPLOYEE E
 WHERE D.MgrSSN = E.SSN AND E.Name LIKE '% Scott'
)
OR P.PNo IN (
 SELECT W.PNo FROM WORKS_ON W, EMPLOYEE E
 WHERE W.SSN = E.SSN AND E.Name LIKE '% Scott'
);

-- Query 2: Show salaries after 10% raise for IoT project employees
SELECT E.Name, E.Salary * 1.10 AS NewSalary
FROM EMPLOYEE E, WORKS_ON W, PROJECT P
WHERE E.SSN = W.SSN 
AND W.PNo = P.PNo 
AND P.PName = 'IoT';

-- Query 3: Sum, max, min, and average salary for Accounts department
SELECT 
 SUM(E.Salary) AS TotalSalary,
 MAX(E.Salary) AS MaxSalary,
 MIN(E.Salary) AS MinSalary,
 AVG(E.Salary) AS AvgSalary
FROM EMPLOYEE E, DEPARTMENT D
WHERE E.DNo = D.DNo AND D.DName = 'Accounts';

-- Query 4: Retrieve employees working on all projects controlled by dept 5
SELECT E.Name
FROM EMPLOYEE E
WHERE NOT EXISTS (
 SELECT P.PNo
 FROM PROJECT P
 WHERE P.DNo = 5
 AND NOT EXISTS (
 SELECT W.PNo
 FROM WORKS_ON W
 WHERE W.SSN = E.SSN AND W.PNo = P.PNo
 )
);

-- Query 5: Departments with > 5 employees earning > 600000
SELECT E.DNo, COUNT(*) AS HighEarners
FROM EMPLOYEE E
WHERE E.Salary > 600000
GROUP BY E.DNo
HAVING (SELECT COUNT(*) FROM EMPLOYEE WHERE DNo = E.DNo) > 5;

-- Query 6: View showing employee name, dept name, and location
CREATE VIEW EmployeeDetails AS
SELECT E.Name, D.DName, DL.DLoc
FROM EMPLOYEE E, DEPARTMENT D, DLOCATION DL
WHERE E.DNo = D.DNo AND D.DNo = DL.DNo;

-- Query 7: Trigger to prevent deletion of projects being worked on
DELIMITER //
CREATE TRIGGER prevent_project_delete
BEFORE DELETE ON PROJECT
FOR EACH ROW
BEGIN
 IF EXISTS (SELECT 1 FROM WORKS_ON WHERE PNo = OLD.PNo) THEN
 SIGNAL SQLSTATE '45000'
 SET MESSAGE_TEXT = 'Cannot delete project with active employees';
 END IF;
END;//
DELIMITER ;
