CREATE DATABASE E_Commerce_2

SELECT*FROM Customers   

SELECT*FROM OrderDetails$  

SELECT*FROM Orders$ 

SELECT*FROM Products   

--WHERE Clause Tasks

SELECT OrderID, OrderDate, TotalAmount
FROM Orders$ 
WHERE TotalAmount > 1000
AND YEAR(OrderDate) = 2023;

--GROUP BY Task

SELECT Category, AVG(Price) AS
AveragePrice
FROM Products
GROUP BY Category;

--ORDER BY Task

SELECT OrderID, OrderDate, TotalAmount
FROM Orders$ 
ORDER BY OrderDate DESC;

--HAVING Clause Task

SELECT Category, AVG(Price) AS AveragePrice
FROM Products
GROUP BY Category
HAVING AVG(Price) > 500;

--ARITHEMETIC OPERATION Task

SELECT Top 10 ProductName, (Price * StockQuantity) AS 
TotalRevenue
FROM Products
ORDER BY TotalRevenue DESC

--WILD CARD Task

  --To check for Customers, whose last name starts with 'S'
SELECT CustomerID, FirstName, LastName, Email
FROM Customers
WHERE LastName LIKE 'S%';

 --To check for Customers, whose email has gmail
SELECT CustomerID, FirstName, LastName, Email
FROM Customers
WHERE Email LIKE '%gmail%';

 --To check for products whose ProductName is exactly 10 characters long
SELECT ProductID, ProductName, Category, Price
FROM Products
WHERE ProductName LIKE '__________';

 /*To check for all customers whose LastName starts with any letter 
from 'A' to 'C':*/
SELECT CustomerID, FirstName, LastName, Email
FROM Customers
WHERE LastName LIKE '[A-C]%';

/*To check for all products whose ProductName does not start with a 
vowel:*/
SELECT ProductID, ProductName, Category, Price
FROM Products
WHERE ProductName LIKE '[^AEIOU]%';

 --To check for all customers whose LastName contains a digit:
SELECT CustomerID, FirstName, LastName, Email
FROM Customers
WHERE LastName LIKE '%[0-9]%';

--TOP CLAUSE Task

  --Retrieving the top 5 most expensive products:
SELECT TOP 5 ProductID, ProductName, Category, Price
FROM Products
ORDER BY Price DESC;
  --Retrieving the top 10 most recent orders:
SELECT TOP 10 OrderID, CustomerID, OrderDate, TotalAmount
FROM Orders$ 
ORDER BY OrderDate DESC;

  --Retrieving the top 3 categories with the highest average product price
SELECT TOP 3 Category, AVG(Price) AS AveragePrice
FROM Products
GROUP BY Category
ORDER BY AveragePrice DESC