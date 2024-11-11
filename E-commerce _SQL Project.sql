select * from customers;
## Problem statement
## You can analyze all the tables by describing their contents.
## Task: Describe the Tables:
Customers
Products
Orders
OrderDetails

SELECT 
    c.customer_id,
    c.name AS customer_name,
    c.location AS customer_location,
    o.order_id,
    o.order_date,
    o.total_amount,
    p.product_id,
    p.name AS product_name,
    p.category AS product_category,
    p.price AS product_price,
    od.quantity,
    od.price_per_unit
FROM 
    Orders o
JOIN 
    Customers c ON o.customer_id = c.customer_id
JOIN 
    OrderDetails od ON o.order_id = od.order_id
JOIN 
    Products p ON od.product_id = p.product_id;
    
## 2. Problem statement
## Identify the top 3 cities with the highest number of customers to determine key markets for targeted marketing and logistic optimization.

SELECT 
    location, 
    COUNT(customer_id) AS number_of_customers
FROM 
    Customers
GROUP BY 
    location
ORDER BY 
    number_of_customers DESC
LIMIT 3;

## 3.Problem statement
## Determine the distribution of customers by the number of orders placed. This insight will help in segmenting customers into one-time buyers, occasional shoppers, and regular customers for tailored marketing strategies.

WITH OrderCounts AS (
    SELECT 
        customer_id,
        COUNT(order_id) AS NumberOfOrders
    FROM 
        Orders
    GROUP BY 
        customer_id
)
SELECT 
    NumberOfOrders,
    COUNT(customer_id) AS CustomerCount
FROM 
    OrderCounts
GROUP BY 
    NumberOfOrders
ORDER BY 
    NumberOfOrders ASC;

## 4. Problem statement
## Identify products where the average purchase quantity per order is 2 but with a high total revenue, suggesting premium product trends.

WITH ProductMetrics AS (
    SELECT 
        product_id,
        AVG(quantity) AS AvgQuantity,
        SUM(quantity * price_per_unit) AS TotalRevenue
    FROM 
        OrderDetails
    GROUP BY 
        product_id
)
SELECT 
    product_id AS Product_Id,
    AvgQuantity,
    TotalRevenue
FROM 
    ProductMetrics
WHERE 
    AvgQuantity = 2
ORDER BY 
    TotalRevenue DESC;
    
## 5. Problem statement
## For each product category, calculate the unique number of customers purchasing from it. This will help understand which categories have wider appeal across the customer base.

SELECT 
    p.category AS category,
    COUNT(DISTINCT o.customer_id) AS unique_customers
FROM 
    Products p
JOIN 
    OrderDetails od ON p.product_id = od.product_id
JOIN 
    Orders o ON od.order_id = o.order_id
GROUP BY 
    p.category
ORDER BY 
    unique_customers DESC;
    
## 6. Problem statement
## Analyze the month-on-month percentage change in total sales to identify growth trends.

WITH MonthlySales AS (
    SELECT 
        DATE_FORMAT(order_date, '%Y-%m') AS Month,
        SUM(total_amount) AS TotalSales
    FROM 
        Orders
    GROUP BY 
        DATE_FORMAT(order_date, '%Y-%m')
),
SalesChanges AS (
    SELECT 
        Month,
        TotalSales,
        LAG(TotalSales) OVER (ORDER BY Month) AS PreviousTotalSales
    FROM 
        MonthlySales
)
SELECT 
    Month,
    TotalSales,
    ROUND(
        (TotalSales - COALESCE(PreviousTotalSales, 0)) / 
        NULLIF(COALESCE(PreviousTotalSales, 0), 0) * 100, 2
    ) AS PercentChange
FROM 
    SalesChanges
ORDER BY 
    Month;
    
## 7.Problem statement
## Examine how the average order value changes month-on-month. Insights can guide pricing and promotional strategies to enhance order value.

WITH MonthlyOrderValues AS ( 
    SELECT 
        DATE_FORMAT(order_date, '%Y-%m') AS Month, 
        AVG(total_amount) AS AvgOrderValue 
    FROM Orders 
    GROUP BY Month 
) 

SELECT 
    Month, 
    AvgOrderValue, 
    ROUND((AvgOrderValue - LAG(AvgOrderValue) OVER (ORDER BY Month)), 2) AS ChangeInValue
FROM MonthlyOrderValues 
order by changeInValue desc;

## 8. Problem statement
## Based on sales data, identify products with the fastest turnover rates, suggesting high demand and the need for frequent restocking.

SELECT 
    product_id,
    COUNT(order_id) AS SalesFrequency
FROM 
    OrderDetails
GROUP BY 
    product_id
ORDER BY 
    SalesFrequency DESC
LIMIT 5;

## 9. Problem statement
## List products purchased by less than 40% of the customer base, indicating potential mismatches between inventory and customer interest.

SELECT 
    p.product_id, 
    p.name, 
    COUNT(DISTINCT o.customer_id) AS UniqueCustomerCount
FROM 
    Products p
JOIN 
    OrderDetails od ON p.product_id = od.product_id
JOIN 
    Orders o ON od.order_id = o.order_id
GROUP BY 
    p.product_id, 
    p.name
HAVING 
    COUNT(DISTINCT o.customer_id) < (SELECT COUNT(*) FROM Customers) * 0.40;
    
## 10. Problem statement
## Evaluate the month-on-month growth rate in the customer base to understand the effectiveness of marketing campaigns and market expansion efforts.

WITH MonthlyNewCustomers AS ( 
    SELECT 
        DATE_FORMAT(MIN(order_date), '%Y-%m') AS FirstPurchaseMonth, 
        COUNT(DISTINCT customer_id) AS NewCustomers 
    FROM Orders 
    GROUP BY customer_id 
) 

SELECT 
    FirstPurchaseMonth, 
    SUM(NewCustomers) AS TotalNewCustomers 
FROM MonthlyNewCustomers 
GROUP BY FirstPurchaseMonth 
ORDER BY FirstPurchaseMonth;

## 11.Problem statement
## Identify the months with the highest sales volume, aiding in planning for stock levels, marketing efforts, and staffing in anticipation of peak demand periods.

SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS Month,
    SUM(total_amount) AS TotalSales
FROM Orders
GROUP BY Month
ORDER BY TotalSales DESC
LIMIT 3;