

CREATE TABLE Item (
	ItemName VARCHAR (30) NOT NULL,
  ItemType CHAR(1) NOT NULL,
  ItemColour VARCHAR(10),
  PRIMARY KEY (ItemName));

CREATE TABLE Employee (
  EmployeeNumber SMALLINT UNSIGNED NOT NULL ,
  EmployeeName VARCHAR(10) NOT NULL ,
  EmployeeSalary INTEGER UNSIGNED NOT NULL ,
  DepartmentName VARCHAR(10) NOT NULL REFERENCES Department,
  BossNumber SMALLINT UNSIGNED NOT NULL REFERENCES Employee,
  PRIMARY KEY (EmployeeNumber));

CREATE TABLE Department (
  DepartmentName VARCHAR(10) NOT NULL,
  DepartmentFloor SMALLINT UNSIGNED NOT NULL,
  DepartmentPhone SMALLINT UNSIGNED NOT NULL,
  EmployeeNumber SMALLINT UNSIGNED NOT NULL REFERENCES 
  Employee,
  PRIMARY KEY (DepartmentName));

CREATE TABLE Sale (
  SaleNumber INTEGER UNSIGNED NOT NULL,
  SaleQuantity SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  ItemName VARCHAR(30) NOT NULL REFERENCES Item,
  DepartmentName VARCHAR(10) NOT NULL REFERENCES Department,
  PRIMARY KEY (SaleNumber));

CREATE TABLE Supplier (
  SupplierNumber INTEGER UNSIGNED NOT NULL,
  SupplierName VARCHAR(30) NOT NULL,
  PRIMARY KEY (SupplierNumber));

CREATE TABLE Delivery (
  DeliveryNumber INTEGER UNSIGNED NOT NULL,
  DeliveryQuantity SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  ItemName VARCHAR(30) NOT NULL REFERENCES Item,
  DepartmentName VARCHAR(10) NOT NULL REFERENCES Department,
  SupplierNumber INTEGER UNSIGNED NOT NULL REFERENCES  
  Supplier,
  PRIMARY KEY (DeliveryNumber));

-- using the data in the text files, insert into the tables this information

-- To insert the data SQLite3 commands were used:
-- .separator "\t"
-- .import data_files.txt data_table

SELECT * FROM Item;
SELECT * FROM Employee;
SELECT * FROM Department;
SELECT * FROM Sale;
SELECT * FROM Supplier;
SELECT * FROM Delivery;

-- 1. What are the names of employees in the Marketing Department?
SELECT EmployeeName FROM Employee WHERE DepartmentName = 'Marketing';

-- 2. Find the items sold by the departments on the second floor.
SELECT DISTINCT ItemName FROM Sale, Department 
WHERE Sale.DepartmentName = Department.DepartmentName AND
Department.DepartmentFloor = 2; 

SELECT DISTINCT ItemName
FROM (Sale NATURAL JOIN Department) 
WHERE Department.DepartmentFloor = 2;

SELECT DISTINCT ItemName
FROM (Sale JOIN Department) 
WHERE Department.DepartmentFloor = 2;
-- Natural join outputs the correct result. Join does not.
-- Join gets all combinations

-- 3.
SELECT DISTINCT ItemName, Department.DepartmentFloor AS 'On Floor'
FROM Delivery, Department -- Delivery contains all the items
WHERE Department.DepartmentName = Department.DepartmentName AND
Department.DepartmentFloor <> 2 -- Instead of != we can use minus or more than
ORDER BY Department.DepartmentFloor, ItemName;

-- 4. 
SELECT AVG(EmployeeSalary)
FROM Employee
WHERE DepartmentName = 'Clothes';

-- 5.
SELECT DepartmentName, AVG(EmployeeSalary) AS 'Average Salary'
FROM Employee
GROUP BY DepartmentName
ORDER BY 'Average Salary' DESC;

-- 6.
SELECT ItemName
FROM Delivery
GROUP BY ItemName HAVING COUNT(DISTINCT SupplierNumber) = 1;

-- 7.
SELECT Supplier.SupplierNumber, Supplier.SupplierName
FROM Delivery, Supplier
WHERE Delivery.SupplierNumber = Supplier.SupplierNumber
GROUP BY Supplier.SupplierNumber,
Supplier.SupplierName HAVING COUNT(DISTINCT Delivery.ItemName) >= 10;

-- 8. 
-- The qeustions is reffering to a table that contains the Employee ID
-- the boss ID it's aslo the employee ID, that's why in the second solution
-- uses a copy of the same table
SELECT COUNT(EmployeeName) AS 'Direct of Employees', BossNumber
FROM Employee
WHERE BossNumber IS NOT '\N'
GROUP BY BossNumber;

SELECT Boss.EmployeeNumber, Boss.EmployeeName, COUNT(*) AS 'Employees'
FROM Employee AS 'Worker', Employee AS 'Boss'
WHERE Worker.BossNumber = Boss.EmployeeNumber
GROUP BY Boss.EmployeeNumber, Boss.EmployeeName;

-- 9.
SELECT AVG(Employee.EmployeeSalary) AS 'Average Salary', Department.DepartmentName
FROM Employee, Department, Sale, Item
WHERE Employee.DepartmentName = Department.DepartmentName AND
Department.DepartmentName = Sale.DepartmentName AND
Sale.ItemName = Item.ItemName AND
Item.ItemType = 'E'
GROUP BY Department.DepartmentName;

-- TODO: translate into NATURAL JOIN
SELECT AVG(Employee.EmployeeSalary) AS 'Average Salary', Department.DepartmentName
FROM (Department NATURAL JOIN Sale), (Employee NATURAL JOIN Department), (Sale NATURAL JOIN Item)
WHERE Employee.DepartmentName = Department.DepartmentName AND
Department.DepartmentName = Sale.DepartmentName AND
Sale.ItemName = Item.ItemName AND
Item.ItemType = 'E'
GROUP BY Department.DepartmentName;

-- 10.
SELECT SUM(SaleQuantity) AS 'Number of Items', Department.DepartmentName
FROM Item, Department, Sale
WHERE Item.ItemName = Sale.ItemName AND
Department.DepartmentName = Sale.DepartmentName AND
Item.ItemType = 'E' AND
Department.DepartmentFloor = 2;

-- TODO: Translate into natural join

-- 11.
SELECT AVG(DeliveryQuantity) AS 'Average Delivery Quantity', SupplierName, Delivery.ItemName
FROM Delivery, Item, Supplier
WHERE Delivery.SupplierNumber = Supplier.SupplierNumber AND
Delivery.ItemName = Item.ItemName AND
Item.ItemType = 'N'
GROUP BY Delivery.SupplierNumber;

SELECT Delivery.SupplierNumber, SupplierName, Delivery.ItemName, AVG(Delivery.DeliveryQuantity) AS 'Average Quantity'
FROM ((Delivery NATURAL JOIN Supplier) NATURAL JOIN Item) 
WHERE Item.ItemType = 'N'
GROUP BY Delivery.SupplierNumber, SupplierName, Delivery.ItemName 
ORDER BY Delivery.SupplierNumber, SupplierName, 'Average Quantity' DESC, Delivery.ItemName;


-- **************
-- Nested Queries
-- **************


-- 1.
SELECT DISTINCT ItemName
FROM Sale
WHERE DepartmentName IN (
  SELECT DepartmentName
  FROM Department
  WHERE DepartmentFloor = 2
  );

-- 2.
SELECT EmployeeName, EmployeeSalary
FROM Employee
WHERE EmployeeNumber = (
  SELECT BossNumber
  FROM Employee
  WHERE EmployeeName = 'Clare'
  );

-- 3.
SELECT EmployeeName, EmployeeSalary
FROM Employee
WHERE EmployeeNumber IN (
  SELECT BossNumber
  FROM Employee
  GROUP BY BossNumber HAVING COUNT(*) > 2
  ); 

-- 4
SELECT EmployeeName, EmployeeSalary
FROM Employee
WHERE EmployeeSalary > (
  SELECT EmployeeSalary
  FROM Employee
  GROUP BY DepartmentName HAVING MAX(EmployeeSalary) AND DepartmentName = 'Marketing'
  );

SELECT EmployeeName, EmployeeSalary
FROM Employee
WHERE EmployeeSalary > (
  SELECT MAX(EmployeeSalary)
  FROM Employee
  WHERE DepartmentName = 'Marketing'
  );

-- 5.
SELECT DISTINCT DepartmentName 
FROM Sale
WHERE ItemName = 'Stetsons' AND DepartmentName IN
  (SELECT DepartmentName
  FROM Employee
  GROUP BY DepartmentName HAVING SUM(EmployeeSalary) > 25000);

-- 6.
SELECT DISTINCT Delivery.SupplierNumber, Supplier.SupplierName
FROM (Supplier NATURAL JOIN Delivery)
WHERE (ItemName <> 'Compass' AND
  SupplierNumber IN
    (SELECT SupplierNumber
    FROM Delivery
    WHERE ItemName = 'Compass'));

-- 7.
SELECT DISTINCT Delivery.SupplierNumber, Supplier.SupplierName
FROM (Supplier NATURAL JOIN Delivery)
WHERE SupplierNumber IN
  (SELECT SupplierNumber
  FROM Delivery
  WHERE ItemName = 'Compass')
GROUP BY Delivery.SupplierNumber, Supplier.SupplierName HAVING COUNT(DISTINCT ItemName);

-- 8.
SELECT DISTINCT DepartmentName, ItemName
FROM Delivery AS Delivery1
WHERE NOT EXISTS
  (SELECT *
  FROm Delivery AS Delivery2
  WHERE Delivery2.DepartmentName = Delivery1.DepartmentName AND
  ItemName NOT IN
    (SELECT ItemName
    FROM Delivery AS Delivery3
    WHERE Delivery3.DepartmentName <> Delivery1.DepartmentName));
