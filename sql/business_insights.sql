-- INSIGHT METRIC 1: Month-over-Month (MoM) Growth Dynamics
WITH MonthlyAggregates AS (
    SELECT 
        year_month AS reporting_period,
        SUM(sales) AS gross_revenue,
        SUM(profit) AS net_profit
    FROM cleaned_sales_data
    GROUP BY year_month
),
LaggedCalculations AS (
    SELECT 
        reporting_period,
        gross_revenue,
        LAG(gross_revenue, 1) OVER (ORDER BY reporting_period) AS prior_period_revenue,
        net_profit,
        LAG(net_profit, 1) OVER (ORDER BY reporting_period) AS prior_period_profit
    FROM MonthlyAggregates
)
SELECT 
    reporting_period,
    gross_revenue,
    ROUND(((gross_revenue - prior_period_revenue) / prior_period_revenue) * 100, 2) AS revenue_mom_pct,
    net_profit,
    ROUND(((net_profit - prior_period_profit) / prior_period_profit) * 100, 2) AS profit_mom_pct
FROM LaggedCalculations;

-- INSIGHT METRIC 2: Top 3 High-Margin Product Verticals by Global Region
WITH RegionalMarketShares AS (
    SELECT 
        region,
        sub_category,
        SUM(sales) AS revenue_generated,
        SUM(profit) AS optimized_profit,
        DENSE_RANK() OVER (PARTITION BY region ORDER BY SUM(profit) DESC) AS operational_rank
    FROM cleaned_sales_data
    GROUP BY region, sub_category
)
SELECT 
    region,
    sub_category,
    revenue_generated,
    optimized_profit
FROM RegionalMarketShares
WHERE operational_rank <= 3;
