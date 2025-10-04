USE master;
GO

IF EXISTS (SELECT * FROM sysdatabases WHERE name = 'OrelProject')
BEGIN
    ALTER DATABASE OrelProject SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE OrelProject;
END


GO


Create database OrelProject


GO


USE OrelProject;
-- מסד נתונים המקשר בין אלמנטים ממודל תלת מימד תכנון מבנה לבין מערכת הזמנות פריורטי
-- מטרות 
-- מעקב אחר הזמנות רכש לבין אלמנטים מתוכננים 
-- ממשק בין התכנון לבין הזמנות בביצוע
-- הזנת נתונים ומידע כולל מחירים בין שני המערכות
-- פלט של אלמנטים שלא הוזמנו


GO


-- יצירת טבלת SUPPLIERS 
-- מטרה : ניהול פרטי הספקים שעובדים עם הארגון
-- מפתח ראשי - קוד ספק 
-- מפתח משני - אין - זוהי טבלת אב ראשית ואינה תלויה בטבלאות אחרות
-- שיקול - הטבלה מיעודת להיות מקור עיקרי לספקים, לכן אינה תלויה בטבלאות אחרות


CREATE TABLE Suppliers (
    SupplierId VARCHAR(10) NOT NULL PRIMARY KEY,
    SupplierName NVARCHAR(100) NOT NULL,
    ContactPerson NVARCHAR(100),
    PhoneNumber NVARCHAR(20),
    EmailAddress NVARCHAR(100)
);


GO


-- יצירת טבלת CATALOG
-- מטרה : ניהול קטלוג מוצרים/פריטים שמסופקים ע"י ספקים שונים
-- מפתח ראשי - מספר קטלוג 
-- מפתח משני  - קוד ספק, כל פריט משויך לספק אחד בלבד
-- שיקול - מבנה המאפשר מעקב אחרי פריטים לפי ספק


CREATE TABLE Catalog (
    CatalogNumber VARCHAR(10) NOT NULL PRIMARY KEY,
    CatalogName NVARCHAR(100) NOT NULL,
    Unit NVARCHAR(20) NOT NULL,
    BasePrice DECIMAL(10,2) NOT NULL CHECK (BasePrice >= 0),
    SupplierId VARCHAR(10) NOT NULL,
    CONSTRAINT FK_Catalog_Supplier FOREIGN KEY (SupplierId) REFERENCES Suppliers(SupplierId)
);



GO


-- יצירת טבלת ORDERS
-- מטרה : ניהול הזמנות מספקים
-- מפתח ראשי - מספר הזמנה 
-- מפתח משני - קוד ספק, כל פריט משויך לספק אחד בלבד
-- שיקול - קשר ברור בין הזמנה לספק


CREATE TABLE Orders (
    OrderNumber VARCHAR(10) NOT NULL PRIMARY KEY,
    SupplierId VARCHAR(10) NOT NULL,
    OrderDate DATE NOT NULL,
	Status NVARCHAR(20) NOT NULL CHECK (Status IN ('Open', 'Final', 'Cancelled')),
    CONSTRAINT FK_Orders_Supplier FOREIGN KEY (SupplierId) REFERENCES Suppliers(SupplierId)
);


GO


-- יצירת טבלת ORDERITEMS
-- מטרה : ניהול שורות הפריטים בכל הזמנה
-- מפתח ראשי - מורכב ממספר השורה + מספר הזמנה, מאפשר כמה שורות עם אותו מספר הזמנה כל עוד מספר השורה שונה 
-- מפתחות משנים - מספר הזמנה, מספר קטלוג
-- שיקול - מאפשר הזמנה של כמה פריטים שונים תחת אותה הזמנה


CREATE TABLE OrderItems (
    OrderNumber VARCHAR(10) NOT NULL,
    LineNumber INT NOT NULL,
    CatalogNumber VARCHAR(10) NOT NULL,
    Description NVARCHAR(100),
    Quantity INT NOT NULL CHECK (Quantity > 0),
    UnitPrice DECIMAL(10,2) NOT NULL CHECK (UnitPrice >= 0),
    TotalPrice DECIMAL(12,2) NOT NULL CHECK (TotalPrice >= 0),
    DueDate DATE NOT NULL,
    PRIMARY KEY (OrderNumber, LineNumber),
    CONSTRAINT FK_OrderItems_Order FOREIGN KEY (OrderNumber) REFERENCES Orders(OrderNumber),
    CONSTRAINT FK_OrderItems_Catalog FOREIGN KEY (CatalogNumber) REFERENCES Catalog(CatalogNumber)
);


GO


-- יצירת טבלת ELEMENTS (BIM-3D)
-- מטרה : ייצוג אלמנטים ממודלים המשויכים לפריטים בקטלוג
-- מפתח ראשי - קוד אלמנט 
-- מפתח משני - מספר קטלוג
-- שיקול - קשר בין אלמנטים למוצרים בפועל

CREATE TABLE Elements (
    ElementId VARCHAR(10) NOT NULL PRIMARY KEY,
    CatalogNumber VARCHAR(10) NOT NULL,
    TypeName NVARCHAR(50) NOT NULL,
    FamilyName NVARCHAR(50),
    Level INT NOT NULL,
    Length DECIMAL(6,2) CHECK (Length >= 0),
    Width DECIMAL(6,2) CHECK (Width >= 0),
    Height DECIMAL(6,2) CHECK (Height >= 0),
    CONSTRAINT FK_Elements_Catalog FOREIGN KEY (CatalogNumber) REFERENCES Catalog(CatalogNumber)
);


GO


-- הכנסת נתונים Suppliers
BEGIN TRANSACTION
INSERT INTO Suppliers (SupplierId, SupplierName, ContactPerson, PhoneNumber, EmailAddress) VALUES
('S001', N'Steel Supplier', N'David Levi', '050-1234567', 'david@supplier1.com'),
('S002', N'Concrete Supplier', N'Roni Cohen', '050-2345678', 'roni@supplier2.com'),
('S003', N'Glass Supplier', N'Michal Israeli', '050-3456789', 'michal@supplier3.com'),
('S004', N'Door Supplier', N'Yossi Ben David', '050-4567890', 'yossi@supplier4.com'),
('S005', N'Electrical Supplier', N'Shlomi Ezra', '050-5678901', 'shlomi@supplier5.com'),
('S006', N'Water Supplier', N'Ilan Raz', '050-6789012', 'ilan@supplier6.com'),
('S007', N'Finish Supplier', N'Yael Levi', '050-7890123', 'yael@supplier7.com'),
('S008', N'Lighting Supplier', N'Liat Cohen', '050-8901234', 'liat@supplier8.com'),
('S009', N'Insulation Supplier', N'Gadi Shalom', '050-9012345', 'gadi@supplier9.com'),
('S010', N'Elevator Supplier', N'Miki Yosef', '050-9123456', 'miki@supplier10.com'),
('S011', N'Aluminium Supplier', N'Roni Barak', '050-2233445', 'roni@supplier11.com'),
('S012', N'Ceramic Supplier', N'Ron Cohen', '050-3344556', 'ron@supplier12.com'),
('S013', N'Paint Supplier', N'Elad Shalev', '050-4455667', 'elad@supplier13.com'),
('S014', N'Tile Supplier', N'Hen Levi', '050-5566778', 'hen@supplier14.com'),
('S015', N'Sealant Supplier', N'Sarit Ezra', '050-6677889', 'sarit@supplier15.com'),
('S016', N'Fire Detection Supplier', N'Daniel Mor', '050-7788990', 'daniel@supplier16.com'),
('S017', N'Carpentry Supplier', N'Tamar Cohen', '050-8899001', 'tamar@supplier17.com'),
('S018', N'Plumbing Supplier', N'Omer Shalev', '050-9900112', 'omer@supplier18.com'),
('S019', N'Air Conditioning Supplier', N'Roni Raz', '050-1011122', 'roni@supplier19.com'),
('S020', N'Hardware Supplier', N'Asaf Levi', '050-2022233', 'asaf@supplier20.com');
COMMIT TRANSACTION


GO


-- הכנסת נתונים Catalog
BEGIN TRANSACTION
INSERT INTO Catalog (CatalogNumber, CatalogName, Unit, BasePrice, SupplierId) VALUES
('C001', N'Concrete Wall 20cm', N'Meter', 120.00, 'S002'),
('C002', N'Fire Door', N'Unit', 800.00, 'S004'),
('C003', N'Insulated Glass Window', N'Unit', 1500.00, 'S003'),
('C004', N'Water Pipe 4"', N'Meter', 45.00, 'S006'),
('C005', N'Main Electric Board', N'Unit', 2500.00, 'S005'),
('C006', N'LED Light Fixture', N'Unit', 300.00, 'S008'),
('C007', N'Thermal Insulation 5cm', N'Sqm', 60.00, 'S009'),
('C008', N'Passenger Elevator', N'Unit', 100000.00, 'S010'),
('C009', N'Aluminium Frame', N'Meter', 200.00, 'S011'),
('C010', N'Ceramic Wall Tile', N'Sqm', 90.00, 'S012'),
('C011', N'Acrylic Paint', N'Liter', 30.00, 'S013'),
('C012', N'Granite Tile', N'Sqm', 110.00, 'S014'),
('C013', N'Bituminous Sealant', N'Liter', 50.00, 'S015'),
('C014', N'Fire Detection System', N'Unit', 8000.00, 'S016'),
('C015', N'Carpentry Cabinet', N'Unit', 5000.00, 'S017'),
('C016', N'Sink Tap', N'Unit', 250.00, 'S018'),
('C017', N'VRF AC Unit', N'Unit', 15000.00, 'S019'),
('C018', N'Door Handle', N'Unit', 80.00, 'S020'),
('C019', N'Gypsum Wall 10cm', N'Sqm', 100.00, 'S001'),
('C020', N'Wooden Frame', N'Meter', 150.00, 'S017'),
('C021', N'Wall', N'Block', 999.99, 'S001');
COMMIT TRANSACTION


GO


-- הכנסת נתונים Orders
BEGIN TRANSACTION
INSERT INTO Orders (OrderNumber, SupplierId, OrderDate, Status) VALUES
('O1001', 'S002', '2024-06-01', N'Open'),
('O1002', 'S004', '2024-06-02', N'Open'),
('O1003', 'S003', '2024-06-03', N'Final'),
('O1004', 'S005', '2024-06-04', N'Final'),
('O1005', 'S006', '2024-06-05', N'Cancelled'),
('O1006', 'S008', '2024-06-06', N'Open'),
('O1007', 'S009', '2024-06-07', N'Final'),
('O1008', 'S010', '2024-06-08', N'Open'),
('O1009', 'S001', '2024-06-09', N'Cancelled'),
('O1010', 'S003', '2024-06-10', N'Final'),
('O1011', 'S004', '2024-06-11', N'Open'),
('O1012', 'S005', '2024-06-12', N'Final'),
('O1013', 'S006', '2024-06-13', N'Open'),
('O1014', 'S007', '2024-06-14', N'Cancelled'),
('O1015', 'S008', '2024-06-15', N'Final'),
('O1016', 'S009', '2024-06-16', N'Open'),
('O1017', 'S010', '2024-06-17', N'Final'),
('O1018', 'S001', '2024-06-18', N'Cancelled'),
('O1019', 'S002', '2024-06-19', N'Open'),
('O1020', 'S003', '2024-06-20', N'Final');
COMMIT TRANSACTION


GO


-- הכנסת נתונים OrderItems
BEGIN TRANSACTION
INSERT INTO OrderItems (OrderNumber, LineNumber, CatalogNumber, Description, Quantity, UnitPrice, TotalPrice, DueDate) VALUES
('O1001', 1, 'C001', N'Concrete Wall 20cm', 100, 120.00, 12000.00, '2024-07-01'),
('O1002', 2, 'C002', N'Fire Door', 5, 800.00, 4000.00, '2024-07-02'),
('O1003', 1, 'C003', N'Insulated Glass Window', 10, 1500.00, 15000.00, '2024-07-03'),
('O1004', 3, 'C005', N'Main Electric Board', 2, 2500.00, 5000.00, '2024-07-04'),
('O1005', 1, 'C004', N'Water Pipe 4"', 200, 45.00, 9000.00, '2024-07-05'),
('O1006', 2, 'C006', N'LED Light Fixture', 20, 300.00, 6000.00, '2024-07-06'),
('O1007', 2, 'C007', N'Thermal Insulation 5cm', 100, 60.00, 6000.00, '2024-07-07'),
('O1008', 1, 'C008', N'Passenger Elevator', 1, 100000.00, 100000.00, '2024-07-08'),
('O1009', 3, 'C009', N'Aluminium Frame', 50, 200.00, 10000.00, '2024-07-09'),
('O1010', 1, 'C010', N'Ceramic Wall Tile', 70, 90.00, 6300.00, '2024-07-10'),
('O1011', 1, 'C011', N'Acrylic Paint', 30, 30.00, 900.00, '2024-07-11'),
('O1012', 3, 'C012', N'Granite Tile', 60, 110.00, 6600.00, '2024-07-12'),
('O1013', 1, 'C013', N'Bituminous Sealant', 40, 50.00, 2000.00, '2024-07-13'),
('O1014', 1, 'C014', N'Fire Detection System', 1, 8000.00, 8000.00, '2024-07-14'),
('O1015', 3, 'C015', N'Carpentry Cabinet', 2, 5000.00, 10000.00, '2024-07-15'),
('O1016', 1, 'C016', N'Sink Tap', 10, 250.00, 2500.00, '2024-07-16'),
('O1017', 1, 'C017', N'VRF AC Unit', 1, 15000.00, 15000.00, '2024-07-17'),
('O1018', 3, 'C018', N'Door Handle', 20, 80.00, 1600.00, '2024-07-18'),
('O1019', 1, 'C019', N'Gypsum Wall 10cm', 50, 100.00, 5000.00, '2024-07-19'),
('O1020', 2, 'C020', N'Wooden Frame', 30, 150.00, 4500.00, '2024-07-20');
COMMIT TRANSACTION


GO


-- הכנסת נתונים Elements
BEGIN TRANSACTION
INSERT INTO Elements (ElementId, CatalogNumber, TypeName, FamilyName, Level, Length, Width, Height) VALUES
('E001', 'C001', N'Wall', N'Concrete', 1, 5, 0.2, 3),
('E002', 'C002', N'Door', N'Fire', 1, 1, 1, 2.1),
('E003', 'C003', N'Window', N'Glass', 1, 1.2, 1.2, 1.5),
('E004', 'C004', N'Pipe', N'Water', -1, 6, 0.1, 0.1),
('E005', 'C005', N'Board', N'Electric', 0, 0.8, 0.6, 2),
('E006', 'C006', N'Lighting', N'LED', 1, 0.5, 0.5, 0.2),
('E007', 'C007', N'Insulation', N'Thermal', 2, 10, 1, 0.05),
('E008', 'C008', N'Elevator', N'Passenger', 0, 2, 2, 3),
('E009', 'C009', N'Frame', N'Aluminium', 1, 2, 0.1, 2.1),
('E010', 'C010', N'Cladding', N'Ceramic', 2, 5, 1, 0.01),
('E011', 'C011', N'Paint', N'Acrylic', 2, 0, 0, 0),
('E012', 'C012', N'Flooring', N'Granite', 0, 4, 4, 0.01),
('E013', 'C013', N'Sealant', N'Bituminous', -1, 10, 1, 0.01),
('E014', 'C014', N'Fire Detection', N'System', 0, 1, 1, 0.5),
('E015', 'C015', N'Carpentry', N'Cabinet', 0, 1, 0.6, 2),
('E016', 'C016', N'Plumbing', N'Tap', 0, 0.2, 0.2, 0.15),
('E017', 'C017', N'AC', N'VRF', 0, 1, 1, 0.5),
('E018', 'C018', N'Hardware', N'Handle', 1, 0.2, 0.05, 0.05),
('E019', 'C019', N'Wall', N'Gypsum', 2, 5, 0.1, 3),
('E020', 'C020', N'Frame', N'Wooden', 1, 1, 0.05, 2.1),
('E024', 'C021', N'Wall', N'Block', 1, 2, 0.5, 2);
COMMIT TRANSACTION


SELECT *
FROM OrderItems


-- הצגת כל הפריטים בקטלוג עם שם הספק שלהם
SELECT C.CatalogNumber
	,C.CatalogName
	,C.Unit
	,C.BasePrice
	,S.SupplierName
FROM Catalog C
JOIN Suppliers S ON C.SupplierId = S.SupplierId;

--  סיכום ההזמנות לפי ספק
SELECT S.SupplierName, COUNT(O.OrderNumber) AS TotalOrders
FROM Orders O
JOIN Suppliers S ON O.SupplierId = S.SupplierId
GROUP BY S.SupplierName;

-- הצגת אלמנטים שלא הוזמנו
SELECT E.ElementId, E.TypeName, E.FamilyName, E.CatalogNumber
FROM Elements E
LEFT JOIN OrderItems OI ON E.CatalogNumber = OI.CatalogNumber
WHERE OI.CatalogNumber IS NULL;