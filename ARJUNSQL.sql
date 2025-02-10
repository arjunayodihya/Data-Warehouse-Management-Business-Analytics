-- Create the schema (database)
CREATE DATABASE IF NOT EXISTS AmazonMarketplace;

-- Use the schema (database)
USE AmazonMarketplace;

-- Drop all tables in the schema
DROP TABLE IF EXISTS Returns, Shipping, Reviews, OrderDetails, Orders, Products, Vendors, Customers;



-- Create Vendors Table
CREATE TABLE IF NOT EXISTS Vendors (
    VendorID INT AUTO_INCREMENT PRIMARY KEY,
    VendorName VARCHAR(255) NOT NULL,
    VendorRating DECIMAL(3, 2) DEFAULT 0.00
);

-- Create Products Table
CREATE TABLE IF NOT EXISTS Products (
    ProductID INT AUTO_INCREMENT PRIMARY KEY,
    ProductName VARCHAR(255) NOT NULL,
    Category VARCHAR(100),
    Price DECIMAL(10, 2),
    StockQuantity INT,
    VendorID INT,
    FOREIGN KEY (VendorID) REFERENCES Vendors(VendorID)
);

-- Create Customers Table
CREATE TABLE IF NOT EXISTS Customers (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(100),
    LastName VARCHAR(100),
    Email VARCHAR(255) UNIQUE NOT NULL,
    Phone VARCHAR(15),
    ShippingAddress VARCHAR(255),
    BillingAddress VARCHAR(255),
    IsMember BOOLEAN DEFAULT FALSE
);

-- Create Orders Table
CREATE TABLE IF NOT EXISTS Orders (
    OrderID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE,
    Status ENUM('Completed', 'Pending', 'Cancelled', 'Failed') DEFAULT 'Pending',
    TotalAmount DECIMAL(10, 2),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Create OrderDetails Table (Many-to-Many relationship between Orders and Products)
CREATE TABLE IF NOT EXISTS OrderDetails (
    OrderDetailID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    UnitPrice DECIMAL(10, 2),
    TotalPrice DECIMAL(10, 2) AS (Quantity * UnitPrice) STORED,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- Create Reviews Table (Many-to-One relationship between Customers and Products)
CREATE TABLE IF NOT EXISTS Reviews (
    ReviewID INT AUTO_INCREMENT PRIMARY KEY,
    ProductID INT,
    CustomerID INT,
    Rating INT CHECK (Rating >= 1 AND Rating <= 5),
    ReviewText TEXT,
    ReviewDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Create Shipping Table
CREATE TABLE IF NOT EXISTS Shipping (
    ShippingID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT,
    ShippingAddress VARCHAR(255),
    ShippingDate DATE,
    EstimatedArrival DATE,
    ShippingCost DECIMAL(10, 2),
    Status ENUM('Shipped', 'Pending', 'Delivered', 'Returned') DEFAULT 'Pending',
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

-- Create Returns Table
CREATE TABLE IF NOT EXISTS Returns (
    ReturnID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    ReturnReason VARCHAR(255),
    ReturnDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Status ENUM('Requested', 'Approved', 'Denied', 'Completed') DEFAULT 'Requested',
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);


-- For the Customers Table
SELECT * FROM Customers ORDER BY CustomerID LIMIT 10;
SELECT * FROM Customers ORDER BY CustomerID DESC LIMIT 10;


-- For the Products Table
SELECT * FROM Products ORDER BY ProductID LIMIT 10;
SELECT * FROM Products ORDER BY ProductID DESC LIMIT 10;


-- For the Vendors Table
SELECT * FROM Vendors ORDER BY VendorID LIMIT 10;
SELECT * FROM Vendors ORDER BY VendorID DESC LIMIT 10;


-- For the Orders Table
SELECT * FROM Orders ORDER BY OrderID LIMIT 10;
SELECT * FROM Orders ORDER BY OrderID DESC LIMIT 10;


-- For the OrderDetails Table
SELECT * FROM OrderDetails ORDER BY OrderDetailID LIMIT 10;
SELECT * FROM OrderDetails ORDER BY OrderDetailID DESC LIMIT 10;


-- For the Reviews Table
SELECT * FROM Reviews ORDER BY ReviewID LIMIT 10;
SELECT * FROM Reviews ORDER BY ReviewID DESC LIMIT 10;


-- For the Shipping Table
SELECT * FROM Shipping ORDER BY ShippingID LIMIT 10;
SELECT * FROM Shipping ORDER BY ShippingID DESC LIMIT 10;


-- For the Returns Table
SELECT * FROM Returns ORDER BY ReturnID LIMIT 10;
SELECT * FROM Returns ORDER BY ReturnID DESC LIMIT 10;

-- Top Selling Products
SELECT 
    p.ProductID, 
    p.ProductName, 
    SUM(od.Quantity) AS TotalSold, 
    AVG(od.UnitPrice) AS AveragePrice
FROM 
    OrderDetails od
JOIN 
    Products p ON od.ProductID = p.ProductID
GROUP BY 
    p.ProductID, 
    p.ProductName
ORDER BY 
    TotalSold DESC
LIMIT 10;


-- Customer Buying Behavior
SELECT CustomerID, COUNT(DISTINCT OrderID) AS NumberOfOrders, SUM(TotalAmount) AS TotalSpent
FROM Orders
GROUP BY CustomerID
ORDER BY TotalSpent DESC
LIMIT 10;


-- Product Restocking Analysis

SELECT 
    p.ProductID, p.StockQuantity, MIN(o.OrderDate) AS FirstOrderDate, MAX(o.OrderDate) AS LastOrderDate
FROM 
    Products p
JOIN 
    OrderDetails od ON p.ProductID = od.ProductID
JOIN 
    Orders o ON od.OrderID = o.OrderID
WHERE 
    p.StockQuantity < 20
GROUP BY 
    p.ProductID, p.StockQuantity
ORDER BY 
    p.StockQuantity
LIMIT 1000;




-- Stored Procedure: Monthly Report
DELIMITER //

CREATE PROCEDURE MonthlyReport(IN year_param INT, IN month_param INT)
BEGIN
  SELECT SUM(TotalAmount) AS MonthlySalesTotal, COUNT(OrderID) AS TotalOrders
  FROM Orders
  WHERE YEAR(OrderDate) = year_param AND MONTH(OrderDate) = month_param
  GROUP BY YEAR(OrderDate), MONTH(OrderDate);
END //

DELIMITER ;

CALL MonthlyReport(2023, 9);  -- Replace 2023 with the year and 9 with the month you want to report on



-- Optimizing an SQL Query
SELECT 
    DATE_FORMAT(OrderDate, '%Y-%m') AS Month, 
    SUM(TotalAmount) AS MonthlySales
FROM 
    Orders
WHERE 
    OrderDate BETWEEN '2021-01-01' AND '2021-12-31'
GROUP BY 
    Month
ORDER BY 
    Month;




















