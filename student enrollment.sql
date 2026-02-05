CREATE DATABASE student_enrollment;
USE student_enrollment;

CREATE TABLE STUDENT (
 regno VARCHAR(20) PRIMARY KEY,
 name VARCHAR(50),
 major VARCHAR(30),
 bdate DATE
);

CREATE TABLE COURSE (
 course_num INT PRIMARY KEY,
 cname VARCHAR(50),
 dept VARCHAR(30)
);

CREATE TABLE TEXT (
 book_ISBN INT PRIMARY KEY,
 book_title VARCHAR(100),
 publisher VARCHAR(50),
 author VARCHAR(50)
);

CREATE TABLE ENROLL (
 regno VARCHAR(20),
 course_num INT,
 sem INT,
 marks INT,
 PRIMARY KEY (regno, course_num, sem),
 FOREIGN KEY (regno) REFERENCES STUDENT(regno),
 FOREIGN KEY (course_num) REFERENCES COURSE(course_num)
);

CREATE TABLE BOOK_ADOPTION (
 course_num INT,
 sem INT,
 book_ISBN INT,
 PRIMARY KEY (course_num, sem, book_ISBN),
 FOREIGN KEY (course_num) REFERENCES COURSE(course_num),
 FOREIGN KEY (book_ISBN) REFERENCES TEXT(book_ISBN)
);

INSERT INTO STUDENT VALUES 
('1RV20CS001', 'Amit Kumar', 'CSE', '2002-05-15'),
('1RV20CS002', 'Priya Sharma', 'CSE', '2002-08-20'),
('1RV20CS003', 'Rahul Verma', 'ISE', '2002-03-10'),
('1RV20CS004', 'Sneha Reddy', 'CSE', '2002-11-25'),
('1RV20CS005', 'Vikram Singh', 'ECE', '2002-07-08');

INSERT INTO COURSE VALUES 
(101, 'DBMS', 'CS'),
(102, 'Data Structures', 'CS'),
(103, 'Algorithms', 'CS'),
(104, 'Operating Systems', 'CS'),
(105, 'Networks', 'CS');

INSERT INTO TEXT VALUES 
(1001, 'Database Systems', 'Pearson', 'Elmasri'),
(1002, 'SQL Fundamentals', 'McGraw', 'Date'),
(1003, 'Advanced DBMS', 'Wiley', 'Silberschatz'),
(1004, 'Data Structures in C', 'Pearson', 'Horowitz'),
(1005, 'Algorithm Design', 'MIT Press', 'Cormen');

INSERT INTO ENROLL VALUES 
('1RV20CS001', 101, 5, 85),
('1RV20CS002', 101, 5, 92),
('1RV20CS003', 102, 4, 78),
('1RV20CS004', 101, 5, 92),
('1RV20CS005', 103, 6, 88);

INSERT INTO BOOK_ADOPTION VALUES 
(101, 5, 1001),
(101, 5, 1002),
(101, 5, 1003),
(102, 4, 1004),
(103, 6, 1005);

 Add new textbook and make it adopted
INSERT INTO TEXT VALUES (1006, 'Modern Database Management', 'Pearson', 'Hoffer');
INSERT INTO BOOK_ADOPTION VALUES (101, 6, 1006);


SELECT BA.course_num, T.book_ISBN, T.book_title
FROM BOOK_ADOPTION BA, TEXT T, COURSE C
WHERE BA.book_ISBN = T.book_ISBN 
AND BA.course_num = C.course_num 
AND C.dept = 'CS'
AND BA.course_num IN (
 SELECT course_num
 FROM BOOK_ADOPTION
 GROUP BY course_num, sem
 HAVING COUNT(book_ISBN) > 2
)
ORDER BY T.book_title ASC;


SELECT C.dept
FROM COURSE C
WHERE NOT EXISTS (
 SELECT BA.book_ISBN
 FROM BOOK_ADOPTION BA
 WHERE BA.course_num = C.course_num
 AND BA.book_ISBN NOT IN (
 SELECT book_ISBN FROM TEXT WHERE publisher = 'Pearson'
 )
)
AND EXISTS (
 SELECT 1 FROM BOOK_ADOPTION BA WHERE BA.course_num = C.course_num
);


SELECT S.name, E.marks
FROM STUDENT S, ENROLL E, COURSE C
WHERE S.regno = E.regno 
AND E.course_num = C.course_num 
AND C.cname = 'DBMS'
AND E.marks = (
 SELECT MAX(E2.marks)
 FROM ENROLL E2, COURSE C2
 WHERE E2.course_num = C2.course_num 
 AND C2.cname = 'DBMS'
);


CREATE VIEW StudentCourses AS
SELECT S.regno, S.name, C.cname, E.marks
FROM STUDENT S, ENROLL E, COURSE C
WHERE S.regno = E.regno AND E.course_num = C.course_num;


DELIMITER //
CREATE TRIGGER check_prerequisite
BEFORE INSERT ON ENROLL
FOR EACH ROW
BEGIN
 IF NEW.marks < 40 THEN
 SIGNAL SQLSTATE '45000'
 SET MESSAGE_TEXT = 'Cannot enroll: marks prerequisite must be at least 40';
 END IF;
END;//
DELIMITER ;
