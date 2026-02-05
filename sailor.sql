CREATE DATABASE sailor;
USE sailor;


CREATE TABLE SAILORS (
 sid INT PRIMARY KEY,
 sname VARCHAR(50),
 rating INT,
 age INT
);

CREATE TABLE BOAT (
 bid INT PRIMARY KEY,
 bname VARCHAR(50),
 color VARCHAR(30)
);

CREATE TABLE RESERVES (
 sid INT,
 bid INT,
 date DATE,
 PRIMARY KEY (sid, bid, date),
 FOREIGN KEY (sid) REFERENCES SAILORS(sid),
 FOREIGN KEY (bid) REFERENCES BOAT(bid)
);

INSERT INTO SAILORS VALUES 
(1, 'Albert', 7, 25),
(2, 'Bob', 8, 40),
(3, 'Charlie', 9, 45),
(4, 'David', 6, 42),
(5, 'Edward', 10, 48);

INSERT INTO BOAT VALUES 
(101, 'Interlake', 'blue'),
(102, 'Clipper', 'red'),
(103, 'Marine', 'green'),
(104, 'Thunderstorm', 'yellow'),
(105, 'Sunset', 'white');

INSERT INTO RESERVES VALUES 
(1, 101, '2024-01-15'),
(1, 102, '2024-02-20'),
(2, 103, '2024-03-10'),
(3, 101, '2024-04-05'),
(4, 102, '2024-05-12');

SELECT DISTINCT B.color
FROM BOAT B, RESERVES R, SAILORS S
WHERE B.bid = R.bid AND R.sid = S.sid AND S.sname = 'Albert';

Query 2: Sailor IDs with rating >= 8 or reserved boat 103
SELECT DISTINCT S.sid
FROM SAILORS S
LEFT JOIN RESERVES R ON S.sid = R.sid
WHERE S.rating >= 8 OR R.bid = 103;

- Query 3: Sailors who haven't reserved boats with "storm"
SELECT S.sname
FROM SAILORS S
WHERE S.sid NOT IN (
 SELECT R.sid
 FROM RESERVES R, BOAT B
 WHERE R.bid = B.bid AND B.bname LIKE '%storm%'
)
ORDER BY S.sname ASC;

- Query 4: Sailors who reserved all boats
SELECT S.sname
FROM SAILORS S
WHERE NOT EXISTS (
 SELECT B.bid
 FROM BOAT B
 WHERE NOT EXISTS (
 SELECT R.bid
 FROM RESERVES R
 WHERE R.sid = S.sid AND R.bid = B.bid
 )
);

-- Query 5: Name and age of oldest sailor
SELECT sname, age
FROM SAILORS
WHERE age = (SELECT MAX(age) FROM SAILORS);

-- Query 6: Boat ID and avg age for boats reserved by >= 5 sailors aged >= 40
SELECT R.bid, AVG(S.age) AS avg_age
FROM RESERVES R, SAILORS S
WHERE R.sid = S.sid AND S.age >= 40
GROUP BY R.bid
HAVING COUNT(DISTINCT R.sid) >= 5;

-- Query 7: View of boats reserved by sailors with specific rating
CREATE VIEW BoatsByRating AS
SELECT DISTINCT B.bname, B.color, S.rating
FROM BOAT B, RESERVES R, SAILORS S
WHERE B.bid = R.bid AND R.sid = S.sid;

-- Query 8: Trigger to prevent boat deletion with active reservations
DELIMITER //
CREATE TRIGGER prevent_boat_delete
BEFORE DELETE ON BOAT
FOR EACH ROW
BEGIN
 IF EXISTS (SELECT 1 FROM RESERVES WHERE bid = OLD.bid) THEN
 SIGNAL SQLSTATE '45000'
 SET MESSAGE_TEXT = 'Cannot delete boat with active reservations';
 END IF;
END;//
DELIMITER
