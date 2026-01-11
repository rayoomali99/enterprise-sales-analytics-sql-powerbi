USE AdventureWorksDW2019;
GO
-- 01_SQL_Deep_Dive.sql
-- Dataset: dbo.vw_Sales_Analysis (AdventureWorks)
--Goal: Showcase advanced analytical SQL skills

-- 1) Revenue Concentration (Top 1% / 5% / 10% share)
WITH ranked AS (
    SELECT
        SalesAmount,
        NTILE(100) OVER (ORDER BY SalesAmount DESC) AS pct_bucket
    FROM dbo.vw_Sales_Analysis
)
SELECT
    SUM(SalesAmount) AS total_sales,

    SUM(CASE WHEN pct_bucket <= 1 THEN SalesAmount ELSE 0 END) AS top_1pct_sales,
    CAST(1.0 * SUM(CASE WHEN pct_bucket <= 1 THEN SalesAmount ELSE 0 END)
         / NULLIF(SUM(SalesAmount),0) AS decimal(10,4)) AS top_1pct_share,

    SUM(CASE WHEN pct_bucket <= 5 THEN SalesAmount ELSE 0 END) AS top_5pct_sales,
    CAST(1.0 * SUM(CASE WHEN pct_bucket <= 5 THEN SalesAmount ELSE 0 END)
         / NULLIF(SUM(SalesAmount),0) AS decimal(10,4)) AS top_5pct_share,

    SUM(CASE WHEN pct_bucket <= 10 THEN SalesAmount ELSE 0 END) AS top_10pct_sales,
    CAST(1.0 * SUM(CASE WHEN pct_bucket <= 10 THEN SalesAmount ELSE 0 END)
         / NULLIF(SUM(SalesAmount),0) AS decimal(10,4)) AS top_10pct_share
FROM ranked;

-- 2) Customer Segmentation (vip/regular)

WITH cust AS (
    SELECT
        CustomerKey,
        COUNT(DISTINCT SalesOrderNumber) AS orders_cnt,
        SUM(SalesAmount) AS total_sales,
        SUM(GrossProfit) AS total_profit,
        CAST(1.0 * SUM(GrossProfit) / NULLIF(SUM(SalesAmount),0) AS decimal(10,4)) AS margin
    FROM dbo.vw_Sales_Analysis
    GROUP BY CustomerKey
),
seg AS (
    SELECT
        CustomerKey,
        orders_cnt,
        total_sales,
        total_profit,
        margin,
        CASE
            WHEN orders_cnt >= 5 AND total_sales >= 5000 THEN 'VIP'
            WHEN orders_cnt >= 2 THEN 'Regular'
            ELSE 'Occasional'
        END AS customer_segment
    FROM cust
)
SELECT
    customer_segment,
    COUNT(*) AS customers_cnt,
    AVG(orders_cnt) AS avg_orders,
    AVG(total_sales) AS avg_sales_per_customer,
    SUM(total_sales) AS segment_total_sales,
    SUM(total_profit) AS segment_total_profit,
    CAST(1.0 * SUM(total_profit) / NULLIF(SUM(total_sales),0) AS decimal(10,4)) AS segment_margin
FROM seg
GROUP BY customer_segment
ORDER BY segment_total_sales DESC;

-- 3) Top 10 Products by PROFIT

SELECT TOP 10
    ProductKey,
    EnglishProductName,
    ProductLine,
    SUM(SalesAmount) AS total_sales,
    SUM(GrossProfit) AS total_profit,
    CAST(1.0 * SUM(GrossProfit) / NULLIF(SUM(SalesAmount),0) AS decimal(10,4)) AS margin
FROM dbo.vw_Sales_Analysis
GROUP BY ProductKey, EnglishProductName, ProductLine
ORDER BY total_profit DESC;

-- 4) Best Sales Territory (sales+profit+margin)

SELECT
    st.SalesTerritoryKey,
    st.SalesTerritoryRegion AS territory_region,  
    st.SalesTerritoryCountry AS country,
    SUM(v.SalesAmount) AS total_sales,
    SUM(v.GrossProfit) AS total_profit,
    CAST(1.0 * SUM(v.GrossProfit) / NULLIF(SUM(v.SalesAmount),0) AS decimal(10,4)) AS margin
FROM dbo.vw_Sales_Analysis v
LEFT JOIN dbo.DimSalesTerritory st
    ON v.SalesTerritoryKey = st.SalesTerritoryKey
GROUP BY st.SalesTerritoryKey, st.SalesTerritoryRegion, st.SalesTerritoryCountry
ORDER BY total_profit DESC;

-- 5) YoY Growth(sales+profit)

WITH yearly AS (
    SELECT
        OrderYear,
        SUM(SalesAmount) AS total_sales,
        SUM(GrossProfit) AS total_profit
    FROM dbo.vw_Sales_Analysis
    GROUP BY OrderYear
)
SELECT
    OrderYear,
    total_sales,
    total_profit,
    LAG(total_sales) OVER (ORDER BY OrderYear) AS prev_year_sales,
    CAST(
        1.0 * (total_sales - LAG(total_sales) OVER (ORDER BY OrderYear))
        / NULLIF(LAG(total_sales) OVER (ORDER BY OrderYear),0)
        AS decimal(10,4)
    ) AS yoy_sales_growth
FROM yearly;

-- 5) Product Line Performance (R / M / T / S)

SELECT
    ProductLine,
    SUM(SalesAmount) AS total_sales,
    SUM(GrossProfit) AS total_profit,
    CAST(1.0 * SUM(GrossProfit) / NULLIF(SUM(SalesAmount),0) AS decimal(10,4)) AS margin
FROM dbo.vw_Sales_Analysis
GROUP BY ProductLine
ORDER BY total_profit DESC;

-- 6) Income segment x product price tire prefrence

WITH prod_price AS (
    SELECT
        ProductKey,
        AVG(UnitPrice) AS avg_price
    FROM dbo.vw_Sales_Analysis
    GROUP BY ProductKey
),
prod_tier AS (
    SELECT
        ProductKey,
        CASE
            WHEN avg_price < 500 THEN 'Low Price'
            WHEN avg_price BETWEEN 500 AND 2000 THEN 'Mid Price'
            ELSE 'High Price'
        END AS price_tier
    FROM prod_price
)
SELECT
    s.income_segment,
    p.price_tier,
    SUM(v.SalesAmount) AS total_sales
FROM dbo.vw_Sales_Analysis v
JOIN prod_tier p
    ON v.ProductKey = p.ProductKey
JOIN (
    SELECT
        CustomerKey,
        CASE
            WHEN YearlyIncome < 50000 THEN 'Low Income'
            WHEN YearlyIncome BETWEEN 50000 AND 100000 THEN 'Middle Income'
            ELSE 'High Income'
        END AS income_segment
    FROM dbo.DimCustomer
) s
    ON v.CustomerKey = s.CustomerKey
GROUP BY s.income_segment, p.price_tier
ORDER BY s.income_segment, total_sales DESC;

-- 7) Loss-Making Products

SELECT TOP 10
    ProductKey,
    EnglishProductName,
    ProductLine,
    SUM(SalesAmount) AS total_sales,
    SUM(GrossProfit) AS total_profit,
    CAST(1.0 * SUM(GrossProfit) / NULLIF(SUM(SalesAmount),0) AS decimal(10,4)) AS margin
FROM dbo.vw_Sales_Analysis
GROUP BY ProductKey, EnglishProductName, ProductLine
ORDER BY total_profit ASC;

/* ===============================================================
BUSINESS RECOMMENDATIONS
Based on SQL Deep-Dive Analysis Results
===============================================================

1) Revenue Concentration Risk
INSIGHT:
- ~56% of total revenue is generated by the top 10% of transactions.
- This indicates high revenue concentration and dependency on a
  limited subset of high-value sales.

RECOMMENDATION:
- Protect high-value transactions through pricing stability,
  loyalty incentives, and operational reliability.
- Reduce risk by increasing mid-tier transaction volume through
  bundles, promotions, and targeted campaigns.

---------------------------------------------------------------

2) Customer Segmentation Strategy
INSIGHT:
- VIP customers represent a very small portion of the customer base
  but show the highest order frequency and strong profitability.
- Regular customers generate the largest share of revenue through volume.
- Occasional customers contribute minimal long-term value.

RECOMMENDATION:
- Retain VIP customers using exclusive benefits and personalized offers.
- Focus upsell and retention strategies on Regular customers to
  convert them into VIPs.
- Avoid heavy marketing spend on Occasional customers; instead,
  use low-cost activation campaigns.

---------------------------------------------------------------

3) Top 10 Products by Profit
INSIGHT:
- The top 10 products account for a disproportionate share of total profit.
- Road and Mountain product lines dominate profitability with
  consistently strong margins.

RECOMMENDATION:
- Prioritize inventory availability and marketing investment for
  the top 10 most profitable products.
- Use these products as anchor items for cross-selling accessories
  and lower-margin products.
- Avoid stock shortages for these SKUs, as they directly impact profit.

---------------------------------------------------------------

4) Sales Territory Performance
INSIGHT:
- Australia, the Southwest US, and the UK generate the highest profits.
- Some smaller territories show high margins but low sales volume.

RECOMMENDATION:
- Increase marketing and sales investment in top-performing territories.
- Investigate high-margin but low-volume regions for growth potential.
- Avoid expanding into low-profit territories without margin improvement.

---------------------------------------------------------------

5) Year-over-Year Growth Volatility
INSIGHT:
- Strong growth in some years is followed by sharp declines.
- Revenue growth is not stable and shows signs of volatility.

RECOMMENDATION:
- Avoid assuming consistent growth when planning budgets.
- Apply conservative forecasting models and scenario-based planning.
- Investigate external or internal drivers behind abnormal growth years.

---------------------------------------------------------------

6) Income Segment × Product Price Tier
INSIGHT:
- High-income customers prefer high-priced products.
- Middle-income customers drive the largest overall sales volume,
  especially in mid-price products.
- Low-income customers are price-sensitive and focus on low/mid tiers.

RECOMMENDATION:
- Align pricing strategies with income segments by territory.
- Promote premium products primarily to high-income customers.
- Use mid-priced products as the main revenue driver for mass markets.

---------------------------------------------------------------

7) Loss-Making / Low-Profit Products
INSIGHT:
- Several products generate sales volume but deliver weak or
  comparatively low profit contribution.

RECOMMENDATION:
- Re-evaluate pricing, cost structure, or supplier contracts for
  low-profit products.
- Consider bundling low-margin products with high-profit items.
- If margin improvement is not feasible, consider product rationalization.

=============================================================== */