CREATE DATABASE order_processing;
USE order_processing;

CREATE TABLE Customer (
 Cust INT PRIMARY KEY,
 cname VARCHAR(50),
 city VARCHAR(50)
);
CREATE TABLE Orders (
 order_num INT PRIMARY KEY,
 odate DATE,
 cust INT,
 order_amt INT,
 FOREIGN KEY (cust) REFERENCES Customer(Cust)
);
CREATE TABLE Item (
 item_num INT PRIMARY KEY,
 unitprice INT
);
CREATE TABLE Order_item (
 order_num INT,
 item_num INT,
 qty INT,
 PRIMARY KEY (order_num, item_num),
 FOREIGN KEY (order_num) REFERENCES Orders(order_num),
 FOREIGN KEY (item_num) REFERENCES Item(item_num)
);
CREATE TABLE Warehouse (
 warehouse_num INT PRIMARY KEY,
 city VARCHAR(50)
);
CREATE TABLE Shipment (
 order_num INT,
 warehouse_num INT,
 ship_date DATE,
 PRIMARY KEY (order_num, warehouse_num),
 FOREIGN KEY (order_num) REFERENCES Orders(order_num),
 FOREIGN KEY (warehouse_num) REFERENCES Warehouse(warehouse_num)
);

INSERT INTO Customer VALUES 
(1, 'Kumar', 'Bangalore'),
(2, 'Sharma', 'Mumbai'),
(3, 'Patel', 'Delhi'),
(4, 'Singh', 'Chennai'),
(5, 'Reddy', 'Hyderabad');
INSERT INTO Item VALUES 
(1, 500),
(2, 1200),
(3, 800),
(4, 2000),
(5, 300);
INSERT INTO Orders VALUES 
(101, '2024-01-10', 1, 5000),
(102, '2024-02-15', 2, 3000),
(103, '2024-03-20', 1, 4500),
(104, '2024-04-25', 3, 6000),
(105, '2024-05-30', 4, 2500);
INSERT INTO Order_item VALUES 
(101, 1, 10),
(102, 2, 2),
(103, 3, 5),
(104, 4, 3),
(105, 5, 8);
INSERT INTO Warehouse VALUES 
(1, 'Bangalore'),
(2, 'Mumbai'),
(3, 'Delhi'),
(4, 'Chennai'),
(5, 'Hyderabad');
INSERT INTO Shipment VALUES 
(101, 2, '2024-01-12'),
(102, 2, '2024-02-17'),
(103, 1, '2024-03-22'),
(104, 3, '2024-04-27'),
(105, 5, '2024-06-01');


SELECT order_num, ship_date
FROM Shipment
WHERE warehouse_num = 2;


SELECT S.order_num, S.warehouse_num
FROM Shipment S, Orders O, Customer C
WHERE S.order_num = O.order_num 
AND O.cust = C.Cust 
AND C.cname = 'Kumar';


SELECT C.cname, COUNT(O.order_num) AS num_orders, AVG(O.order_amt) AS avg_order_amt
FROM Customer C, Orders O
WHERE C.Cust = O.cust
GROUP BY C.cname;


DELETE FROM Orders
WHERE cust = (SELECT Cust FROM Customer WHERE cname = 'Kumar');


SELECT item_num, unitprice
FROM Item
WHERE unitprice = (SELECT MAX(unitprice) FROM Item);


DELIMITER //
CREATE TRIGGER update_order_amount
AFTER INSERT ON Order_item
FOR EACH ROW
BEGIN
 UPDATE Orders
 SET order_amt = (
 SELECT SUM(OI.qty * I.unitprice)
 FROM Order_item OI, Item I
 WHERE OI.item_num = I.item_num 
 AND OI.order_num = NEW.order_num
 )
 WHERE order_num = NEW.order_num;
END;//
DELIMITER ;


CREATE VIEW Warehouse5Shipments AS
SELECT order_num, ship_date
FROM Shipment
WHERE warehouse_num = 5;
