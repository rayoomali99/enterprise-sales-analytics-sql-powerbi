USE AdventureWorksDW2019;
GO
--DATA VALIDATION AND FAMILIRIZATION--
--Explore the core tables (sanity check)--
select top 10 *
from dbo.DimCustomer

select top 10 *
from dbo.DimProduct

select top 10 *
from dbo.DimDate

select top 10 *
from dbo.FactInternetSales

--Row count for main tables (data size)--
SELECT 'DimCustomer' AS table_name, COUNT(*) AS rows_count FROM dbo.DimCustomer
UNION ALL SELECT 'DimProduct', COUNT(*) FROM dbo.DimProduct
UNION ALL SELECT 'DimDate', COUNT(*) FROM dbo.DimDate
UNION ALL SELECT 'FactInternetSales', COUNT(*) FROM dbo.FactInternetSales;

--Date range of sales data--
SELECT 
    MIN(OrderDateKey) AS min_order_datekey,
    MAX(OrderDateKey) AS max_order_datekey
FROM dbo.FactInternetSales;
GO

---- Create a consolidated analytical view for sales analysis--
CREATE OR ALTER VIEW dbo.vw_Sales_Analysis
AS
SELECT
    /* -----------------------------
       Sales identifiers (FACT)
       ----------------------------- */
    s.SalesOrderNumber,
    s.SalesOrderLineNumber,
    s.SalesTerritoryKey,

    /* -----------------------------
       Order Date fields (DimDate)
       ----------------------------- */
    s.OrderDateKey,
    d.FullDateAlternateKey        AS OrderDate,
    d.CalendarYear                AS OrderYear,
    d.MonthNumberOfYear           AS OrderMonthNumber,
    d.EnglishMonthName            AS OrderMonthName,
    d.CalendarQuarter             AS OrderQuarter,
    d.EnglishDayNameOfWeek        AS OrderDayName,

    /* -----------------------------
       Customer fields (DimCustomer)
       ----------------------------- */
    s.CustomerKey,
    c.CustomerAlternateKey,
    c.FirstName,
    c.LastName,
    c.Gender,
    c.EmailAddress,
    c.YearlyIncome,
    c.EnglishEducation,
    c.EnglishOccupation,
    c.TotalChildren,
    c.NumberCarsOwned,
    c.CommuteDistance,

    /* -----------------------------
       Product fields (DimProduct)
       ----------------------------- */
    s.ProductKey,
    p.ProductAlternateKey,
    p.EnglishProductName,
    p.Color,
    p.Size,
    p.ProductLine,
    p.ModelName,
    p.StandardCost,
    p.ListPrice,

    /* -----------------------------
       Measures (FACT)
       ----------------------------- */
    s.OrderQuantity,
    s.UnitPrice,
    s.ExtendedAmount,
    s.UnitPriceDiscountPct,
    s.DiscountAmount,
    s.TotalProductCost,
    s.SalesAmount,
    s.TaxAmt,
    s.Freight,

    /* -----------------------------
       Derived metric
       ----------------------------- */
    (s.SalesAmount - s.TotalProductCost) AS GrossProfit

FROM dbo.FactInternetSales AS s

LEFT JOIN dbo.DimCustomer AS c
    ON s.CustomerKey = c.CustomerKey

LEFT JOIN dbo.DimProduct AS p
    ON s.ProductKey = p.ProductKey

LEFT JOIN dbo.DimDate AS d
    ON s.OrderDateKey = d.DateKey

;
GO

SELECT TOP 50 *
FROM dbo.vw_Sales_Analysis
ORDER BY OrderDateKey;

--checks:__
SELECT COUNT(*) AS MissingDateRows
FROM dbo.FactInternetSales s
LEFT JOIN dbo.DimDate d ON s.OrderDateKey = d.DateKey
WHERE d.DateKey IS NULL;

SELECT
    SUM(CASE WHEN c.CustomerKey IS NULL THEN 1 ELSE 0 END) AS MissingCustomerRows,
    SUM(CASE WHEN p.ProductKey  IS NULL THEN 1 ELSE 0 END) AS MissingProductRows
FROM dbo.FactInternetSales s
LEFT JOIN dbo.DimCustomer c ON s.CustomerKey = c.CustomerKey
LEFT JOIN dbo.DimProduct  p ON s.ProductKey  = p.ProductKey

--UNIVARIATE EDA--
--Sales distribution--
WITH x AS (
    SELECT
        SalesAmount,
        ROW_NUMBER() OVER (ORDER BY SalesAmount) AS rn,
        COUNT(*)    OVER () AS cnt
    FROM dbo.vw_Sales_Analysis
)
SELECT
    (SELECT COUNT(*) FROM x) AS total_rows,
    (SELECT MIN(SalesAmount) FROM x) AS min_sales,
    (SELECT MAX(SalesAmount) FROM x) AS max_sales,
    (SELECT AVG(SalesAmount) FROM x) AS avg_sales,
    AVG(1.0 * SalesAmount) AS median_sales
FROM x
WHERE rn IN ( (cnt + 1)/2, (cnt + 2)/2 );

--order quantity distribution__
SELECT
    OrderQuantity,
    COUNT(*) AS freq
FROM dbo.vw_Sales_Analysis
GROUP BY OrderQuantity
ORDER BY OrderQuantity;

--product price sanity--
SELECT
    MIN(UnitPrice) AS min_price,
    MAX(UnitPrice) AS max_price,
    AVG(UnitPrice) AS avg_price
FROM dbo.vw_Sales_Analysis;

--profit check--
SELECT
    MIN(GrossProfit) AS min_profit,
    MAX(GrossProfit) AS max_profit,
    AVG(GrossProfit) AS avg_profit
FROM dbo.vw_Sales_Analysis;

--negative profit--
SELECT
    COUNT(*) AS negative_profit_orders
FROM dbo.vw_Sales_Analysis
WHERE GrossProfit < 0;

--Time granularity--
SELECT
    OrderYear,
    COUNT(*)        AS orders,
    SUM(SalesAmount) AS total_sales
FROM dbo.vw_Sales_Analysis
GROUP BY OrderYear
ORDER BY OrderYear;

--BIVARIATE EDA
--Price × Quantity--
SELECT
    UnitPrice,
    OrderQuantity
FROM dbo.vw_Sales_Analysis;

--SalesAmount × Time--
SELECT
    OrderYear,
    OrderMonthNumber,
    SUM(SalesAmount) AS total_sales
FROM dbo.vw_Sales_Analysis
GROUP BY OrderYear, OrderMonthNumber
ORDER BY OrderYear, OrderMonthNumber;

--Profit × Product--
SELECT
    EnglishProductName,
    SUM(SalesAmount) AS sales,
    SUM(GrossProfit) AS profit
FROM dbo.vw_Sales_Analysis
GROUP BY EnglishProductName;

--Customer behavior--
SELECT
    CustomerKey,
    COUNT(DISTINCT SalesOrderNumber) AS orders,
    SUM(SalesAmount) AS total_spent
FROM dbo.vw_Sales_Analysis
GROUP BY CustomerKey;

--Segmentation & Patterns--
--Product Segmentation--
SELECT
    ProductLine,
    COUNT(DISTINCT SalesOrderNumber) AS orders,
    SUM(SalesAmount) AS total_sales,
    SUM(GrossProfit) AS total_profit
FROM dbo.vw_Sales_Analysis
GROUP BY ProductLine
ORDER BY total_sales DESC;

--Customer Segmentation--
SELECT
    EnglishOccupation,
    COUNT(DISTINCT CustomerKey) AS customers,
    AVG(SalesAmount) AS avg_sale
FROM dbo.vw_Sales_Analysis
GROUP BY EnglishOccupation;

--Time × Category--
SELECT
    OrderYear,
    ProductLine,
    SUM(SalesAmount) AS sales
FROM dbo.vw_Sales_Analysis
GROUP BY OrderYear, ProductLine
ORDER BY OrderYear;


-- Time Intelligence (Monthly Sales + Profit + MoM growth)--
WITH monthly AS (
    SELECT
        OrderYear,
        OrderMonthNumber,
        MIN(OrderMonthName) AS OrderMonthName,
        SUM(SalesAmount) AS total_sales,
        SUM(GrossProfit) AS total_profit
    FROM dbo.vw_Sales_Analysis
    GROUP BY OrderYear, OrderMonthNumber
),
mom AS (
    SELECT
        OrderYear,
        OrderMonthNumber,
        OrderMonthName,
        total_sales,
        total_profit,
        LAG(total_sales) OVER (ORDER BY OrderYear, OrderMonthNumber) AS prev_month_sales
    FROM monthly
)
SELECT
    OrderYear,
    OrderMonthNumber,
    OrderMonthName,
    total_sales,
    total_profit,
    prev_month_sales,
    CAST(1.0 * (total_sales - prev_month_sales) / NULLIF(prev_month_sales,0) AS decimal(10,4)) AS mom_growth_pct
FROM mom
ORDER BY OrderYear, OrderMonthNumber;


















