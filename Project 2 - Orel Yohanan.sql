-- Project 2  - Orel Yohanan --

			-- Exercise 1

WITH MonthlySales AS (
    SELECT
        YEAR(I.InvoiceDate) AS InvoiceYear
        ,MONTH(I.InvoiceDate) AS InvoiceMonth
        ,SUM(IL.ExtendedPrice - IL.TaxAmount) AS MonthlyRevenue
    FROM Sales.Invoices AS I
    JOIN Sales.InvoiceLines AS IL ON I.InvoiceID = IL.InvoiceID
    WHERE I.IsCreditNote = 0  
    GROUP BY YEAR(I.InvoiceDate), MONTH(I.InvoiceDate)
)
,YearlySummary AS (
    SELECT
        InvoiceYear
        ,COUNT(*) AS NumberOfDistinctrMonth
        ,SUM(MonthlyRevenue) AS IncomePerYear
        ,AVG(MonthlyRevenue) * 12 AS YearlyLinearIncome
    FROM MonthlySales
    GROUP BY InvoiceYear
)
,WithGrowth AS (
    SELECT
        InvoiceYear
        ,IncomePerYear
        ,NumberOfDistinctrMonth
        ,YearlyLinearIncome
        ,LAG(YearlyLinearIncome) OVER (ORDER BY InvoiceYear) AS PrevYearIncome
    FROM YearlySummary
)
SELECT
    InvoiceYear
    ,FORMAT(IncomePerYear, 'N2') AS IncomePerYear
    ,NumberOfDistinctrMonth
    ,FORMAT(YearlyLinearIncome, 'N2') AS YearlyLinearIncome
    ,FORMAT(
        CASE 
            WHEN PrevYearIncome IS NULL THEN NULL
            ELSE ((YearlyLinearIncome - PrevYearIncome) / PrevYearIncome) * 100 
        END, 'N2'
    ) AS GrowthRate
FROM WithGrowth
ORDER BY InvoiceYear;


			-- Exercise 2


WITH QuarterSales AS (
    SELECT
    C.CustomerName
    ,YEAR(I.InvoiceDate) AS TheYear
    ,DATEPART(QUARTER, I.InvoiceDate) AS TheQuarter
    ,SUM(IL.ExtendedPrice - IL.TaxAmount) AS IncomePerQuarterYear
    FROM Sales.Invoices AS I
    JOIN Sales.InvoiceLines AS IL ON I.InvoiceID = IL.InvoiceID
    JOIN Sales.Customers AS C ON I.CustomerID = C.CustomerID
    WHERE I.IsCreditNote = 0  
    GROUP BY
    C.CustomerName
    ,YEAR(I.InvoiceDate)
    ,DATEPART(QUARTER, I.InvoiceDate)
)
,RankedSales AS (
    SELECT *
    ,DENSE_RANK() OVER (
        PARTITION BY TheYear, TheQuarter
        ORDER BY IncomePerQuarterYear DESC
    ) AS DNR
    FROM QuarterSales
)
SELECT
    TheYear
    ,TheQuarter
    ,CustomerName
    ,FORMAT(IncomePerQuarterYear, 'N2') AS IncomePerQuarterYear
    ,DNR
FROM RankedSales
WHERE DNR <= 5
ORDER BY
    TheYear
    ,TheQuarter
    ,DNR


			-- Exercise 3


SELECT TOP 10 IL.StockItemID
    ,SI.StockItemName
    ,SUM(IL.ExtendedPrice - IL.TaxAmount) AS TotalProfit
FROM Sales.InvoiceLines AS IL
JOIN Warehouse.StockItems AS SI ON IL.StockItemID = SI.StockItemID
GROUP BY IL.StockItemID
    ,SI.StockItemName
ORDER BY SUM(IL.ExtendedPrice - IL.TaxAmount) DESC


			-- Exercise 4


SELECT
    SI.StockItemID
    ,SI.StockItemName
    ,SI.UnitPrice
    ,SI.RecommendedRetailPrice
    ,SI.RecommendedRetailPrice - SI.UnitPrice AS NominalProductProfit
    ,DENSE_RANK() OVER (
        ORDER BY SI.RecommendedRetailPrice - SI.UnitPrice DESC
    ) AS DNR
FROM Warehouse.StockItems AS SI
WHERE SI.ValidTo > GETDATE()
ORDER BY NominalProductProfit DESC


			-- Exercise 5


SELECT S.SupplierName + ' - ' AS SupplierDetails
    ,STRING_AGG(
        CAST(SI.StockItemID AS VARCHAR) + ' ' + SI.StockItemName
        ,', '
    ) AS ProductDetails
FROM Warehouse.StockItems AS SI
JOIN Purchasing.Suppliers AS S ON SI.SupplierID = S.SupplierID
GROUP BY
    S.SupplierID
    ,S.SupplierName
ORDER BY
    S.SupplierID


			-- Exercise 6


SELECT TOP 5
    C.CustomerID
    ,CT.CityName
    ,CO.CountryName
    ,CO.Continent
    ,CO.Region
    ,SUM(IL.ExtendedPrice) AS TotalExtendedPrice
FROM Sales.Invoices AS I
JOIN Sales.InvoiceLines AS IL ON I.InvoiceID = IL.InvoiceID
JOIN Sales.Customers AS C ON I.CustomerID = C.CustomerID
JOIN Application.Cities AS CT ON C.DeliveryCityID = CT.CityID
JOIN Application.StateProvinces AS SP ON CT.StateProvinceID = SP.StateProvinceID
JOIN Application.Countries AS CO ON SP.CountryID = CO.CountryID
GROUP BY
    C.CustomerID
    ,CT.CityName
    ,CO.CountryName
    ,CO.Continent
    ,CO.Region
ORDER BY
    SUM(IL.ExtendedPrice) DESC


			-- Exercise 7


WITH MonthlySales AS (
    SELECT
        YEAR(I.InvoiceDate) AS InvoiceYear
        ,MONTH(I.InvoiceDate) AS InvoiceMonth
        ,SUM(IL.ExtendedPrice - IL.TaxAmount) AS MonthlyTotal
    FROM Sales.Invoices AS I
    JOIN Sales.InvoiceLines AS IL ON I.InvoiceID = IL.InvoiceID
    WHERE I.IsCreditNote = 0
    GROUP BY
        YEAR(I.InvoiceDate)
        ,MONTH(I.InvoiceDate)
),
WithCumulative AS (
    SELECT
        InvoiceYear
        ,InvoiceMonth
        ,MonthlyTotal
        ,SUM(MonthlyTotal) OVER (
            PARTITION BY InvoiceYear
            ORDER BY InvoiceMonth
        ) AS CumulativeTotal
    FROM MonthlySales
),
FinalResult AS (
    SELECT
        CAST(InvoiceYear AS VARCHAR) AS DisplayYear
        ,CAST(InvoiceMonth AS VARCHAR) AS DisplayMonth
        ,FORMAT(MonthlyTotal, 'N2') AS MonthlyTotalFormatted
        ,FORMAT(CumulativeTotal, 'N2') AS CumulativeTotalFormatted
        ,InvoiceYear AS SortYear
        ,InvoiceMonth AS SortMonth
    FROM WithCumulative

    UNION ALL

    SELECT
        CAST(InvoiceYear AS VARCHAR)
        ,'Grand Total'
        ,FORMAT(SUM(MonthlyTotal), 'N2')
        ,FORMAT(SUM(MonthlyTotal), 'N2')
        ,InvoiceYear
        ,13
    FROM MonthlySales
    GROUP BY InvoiceYear
)
SELECT
    DisplayYear AS InvoiceYear
    ,DisplayMonth AS InvoiceMonth
    ,MonthlyTotalFormatted AS MonthlyTotal
    ,CumulativeTotalFormatted AS CumulativeTotal
FROM FinalResult
ORDER BY
    SortYear
    ,SortMonth


			-- Exercise 8


SELECT 
    MONTH(OrderDate) AS OrderMonth
    ,SUM(CASE WHEN YEAR(OrderDate) = 2013 THEN 1 ELSE 0 END) AS [2013]
    ,SUM(CASE WHEN YEAR(OrderDate) = 2014 THEN 1 ELSE 0 END) AS [2014]
    ,SUM(CASE WHEN YEAR(OrderDate) = 2015 THEN 1 ELSE 0 END) AS [2015]
    ,SUM(CASE WHEN YEAR(OrderDate) = 2016 THEN 1 ELSE 0 END) AS [2016]
FROM Sales.Orders
GROUP BY MONTH(OrderDate)
ORDER BY OrderMonth


			-- Exercise 9 


WITH AllOrders AS (
    SELECT 
        o.CustomerID,
        o.OrderDate,
        c.CustomerName
    FROM Sales.Orders o
    JOIN Sales.Customers c ON o.CustomerID = c.CustomerID
),
CustomerStats AS (
    SELECT 
        CustomerID,
        MAX(OrderDate) AS LastCustOrderDate,
        CASE 
            WHEN COUNT(*) > 1 
                THEN ROUND(
                    DATEDIFF(DAY, MIN(OrderDate), MAX(OrderDate)) * 1.0 / (COUNT(*) - 1), 
                    0
                )
            ELSE 0
        END AS AvgDaysBetweenOrders
    FROM AllOrders
    GROUP BY CustomerID
),
LatestOrders2016 AS (
    SELECT 
        o.CustomerID,
        o.CustomerName,
        o.OrderDate,
        LAG(o.OrderDate) OVER (PARTITION BY o.CustomerID ORDER BY o.OrderDate) AS PreviousOrderDate
    FROM AllOrders o
    WHERE o.OrderDate <= '2016-05-31'
),
Final AS (
    SELECT 
        o.CustomerID,
        o.CustomerName,
        o.OrderDate,
        o.PreviousOrderDate,
        cs.AvgDaysBetweenOrders,
        cs.LastCustOrderDate,
        CAST('2016-05-31' AS DATE) AS LastOrderDateAll,
        DATEDIFF(DAY, cs.LastCustOrderDate, '2016-05-31') AS DaysSinceLastOrder,
        CASE 
            WHEN DATEDIFF(DAY, cs.LastCustOrderDate, '2016-05-31') <= cs.AvgDaysBetweenOrders 
                THEN 'Active'
            ELSE 'Potential Churn'
        END AS CustomerStatus
    FROM LatestOrders2016 o
    JOIN CustomerStats cs ON o.CustomerID = cs.CustomerID
)
SELECT *
FROM Final
ORDER BY CustomerID, OrderDate;


			-- Exercise 10 לבדוק


WITH FilteredCustomers AS (
    SELECT *
    FROM Sales.Customers
    WHERE LOWER(CustomerName) NOT LIKE 'tailspin%' 
  AND LOWER(CustomerName) NOT LIKE 'wingtip%'
),
CategoryCounts AS (
    SELECT 
          cc.CustomerCategoryName
        ,COUNT(fc.CustomerID) AS CustomerCount
    FROM FilteredCustomers fc
    JOIN Sales.CustomerCategories cc 
        ON fc.CustomerCategoryID = cc.CustomerCategoryID
    GROUP BY cc.CustomerCategoryName
),
TotalCustomers AS (
    SELECT COUNT(*) AS TotalCustCount 
    FROM FilteredCustomers
)
SELECT 
      cc.CustomerCategoryName
    ,cc.CustomerCount
    ,t.TotalCustCount
    ,CONVERT(VARCHAR, CAST(cc.CustomerCount * 100.0 / t.TotalCustCount AS DECIMAL(5,2))) + '%' AS DistributionFactor
FROM CategoryCounts cc
CROSS JOIN TotalCustomers t
ORDER BY DistributionFactor DESC;

----

WITH FilteredCustomers AS (
    SELECT *
    FROM Sales.Customers
    WHERE LOWER(LTRIM(RTRIM(CustomerName))) NOT LIKE 'tailspin%'
      AND LOWER(LTRIM(RTRIM(CustomerName))) NOT LIKE 'wingtip%'
),
CategoryCounts AS (
    SELECT 
          cc.CustomerCategoryName,
          COUNT(fc.CustomerID) AS CustomerCount
    FROM FilteredCustomers fc
    JOIN Sales.CustomerCategories cc 
        ON fc.CustomerCategoryID = cc.CustomerCategoryID
    GROUP BY cc.CustomerCategoryName
),
TotalCustomers AS (
    SELECT COUNT(*) AS TotalCustCount 
    FROM FilteredCustomers
)
SELECT 
      cc.CustomerCategoryName,
      cc.CustomerCount,
      t.TotalCustCount,
      CONVERT(VARCHAR, CAST(cc.CustomerCount * 100.0 / t.TotalCustCount AS DECIMAL(5,2))) + '%' AS DistributionFactor
FROM CategoryCounts cc
CROSS JOIN TotalCustomers t
ORDER BY DistributionFactor DESC;











