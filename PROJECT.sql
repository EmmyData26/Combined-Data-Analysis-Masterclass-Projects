SELECT*FROM Customers$  



-- 1) Customer Segmentation by Region:
    -- 1a) Identifying top 10 regions by the number of unique customers
    SELECT TOP 10 Region, COUNT(DISTINCT "Customer ID" ) AS "Unique Customers"
    FROM Customers$ 
    GROUP BY Region
    ORDER BY "Unique Customers" DESC
    
    /* 1b) Analysis of the distribution of customers across the regions to provide insights into the company's reach*/
    SELECT Region, COUNT (DISTINCT "Customer ID") AS Unique_Customers,CAST( ROUND( COUNT(DISTINCT "Customer ID" ) 
    * 100.0 / SUM(COUNT(DISTINCT "Customer ID" )) OVER (),2) AS DECIMAL(10,2)) AS Regions_Customers_Percentage
    FROM Customers$ 
    GROUP BY Region 
    ORDER BY Unique_Customers DESC

    

-- 2) Customer Retention and Repeat Purchases:
    -- 2a) List of customers who placed more than one order

 SELECT 
    [c].[Customer Name], 
    [o].[Customer ID], 
    COUNT([o].[Order ID]) AS [Total Orders]
FROM [Orders$] AS [o]
JOIN (
    SELECT DISTINCT [Customer ID], [Customer Name] 
    FROM [Customers$] 
) AS [c] ON [o].[Customer ID] = [c].[Customer ID]
GROUP BY [c].[Customer Name], [o].[Customer ID]
HAVING COUNT([o].[Order ID]) > 1
ORDER BY [Total Orders] DESC;

       -- 2ai) Total number of Customers who made more than one order
           SELECT COUNT(*) AS TOTAL_REPEAT_CUSTOMERS FROM (
            SELECT "Customer ID", COUNT("Order ID") AS "Total Orders"
            FROM Orders$ 
            GROUP BY "Customer ID" 
            HAVING COUNT("Order ID")>1
           ) AS CUSTOMER_LIST;
         -- Total Distint Customers  
        SELECT Count(DISTINCT("Customer ID")) AS Total_Customers From Orders$;

     -- 2b) Identification of the top 5 customers who have placed the most orders
     SELECT TOP 5 
    sub.[Customer Name], 
    o.[Customer ID], 
    COUNT(o.[Order ID]) AS [Total Orders]
FROM [Orders$] AS o
JOIN (
    SELECT DISTINCT [Customer ID], [Customer Name] 
    FROM [Customers$] 
) AS sub 
    ON o.[Customer ID] = sub.[Customer ID]
GROUP BY sub.[Customer Name], o.[Customer ID]
HAVING COUNT(o.[Order ID]) > 1
ORDER BY [Total Orders] DESC;

           -- 2bi) Insight into thier purchasing behaviour            

WITH TopFiveCustomers AS (
    SELECT TOP 5 
        [Customer ID], 
        COUNT([Order ID]) AS total_orders
    FROM [Orders$] 
    GROUP BY [Customer ID]
    HAVING COUNT([Order ID]) > 1
    ORDER BY total_orders DESC
)
SELECT 
    TopFiveCustomers.[Customer ID],
    MAX(c.[Customer Name]) AS [Customer Name],
    o.Category,
    COUNT(o.[Order ID]) AS number_of_orders,
    RANK() OVER (
        PARTITION BY TopFiveCustomers.[Customer ID] 
        ORDER BY COUNT(o.[Order ID]) DESC
    ) AS frequency_rank
FROM TopFiveCustomers
JOIN [Orders$] AS o ON TopFiveCustomers.[Customer ID] = o.[Customer ID]
LEFT JOIN [Customers$]  AS c ON TopFiveCustomers.[Customer ID] = c.[Customer ID]
GROUP BY TopFiveCustomers.[Customer ID], o.Category
ORDER BY TopFiveCustomers.[Customer ID], number_of_orders DESC;



-- 3) High-Value Customers:
     --3a)  Finding the top 10 customers who have spent the most (based on total sales amount):
     
    SELECT TOP 10 
    o.[Customer ID], 
    sub.[Customer Name], 
    SUM(o.[Sales] * o.[Quantity]) AS TotalSalesAmount
FROM [Orders$] AS o
JOIN (
    SELECT DISTINCT [Customer ID], [Customer Name] 
    FROM [Customers$] 
) AS sub ON o.[Customer ID] = sub.[Customer ID]
GROUP BY o.[Customer ID], sub.[Customer Name]
ORDER BY TotalSalesAmount DESC;

    /* 3b) Analysis of the purchasing patterns of these high-value customers, including what product categories
     they purchase the most and their average order value*/
   
  WITH CustomerCategoryRanking AS (
  -- Identifying the most purchased category for all customers
    SELECT 
        [Customer ID], 
        Category,
        SUM(Quantity) AS TotalQty,
        ROW_NUMBER() OVER (
            PARTITION BY [Customer ID] 
            ORDER BY SUM(Quantity) DESC, SUM(Sales) DESC
        ) AS CategoryRank
    FROM [Orders$]
    GROUP BY [Customer ID], Category
)
SELECT TOP 10 
     o.[Customer ID],
     each.[Customer Name],
     SUM(o.Sales * o.Quantity) AS Total_spent,
     ROUND(AVG(o.Sales * o.Quantity), 2) AS AverageOrderValue,
     COUNT(o.[Order ID]) AS Order_count,
     MAX(DATENAME(MONTH, o.[Order Date])) AS last_purchase_month,
     -- Selecting the category name where the rank is highest
     MAX(cat.Category) AS MostPurchasedCategory
FROM [Orders$] AS o
JOIN (
    SELECT DISTINCT [Customer ID], [Customer Name] 
    FROM [Customers$] 
) AS each ON o.[Customer ID] = each.[Customer ID]
LEFT JOIN CustomerCategoryRanking AS cat 
    ON o.[Customer ID] = cat.[Customer ID] 
    AND cat.CategoryRank = 1 
GROUP BY o.[Customer ID], each.[Customer Name]
ORDER BY Total_spent DESC;


 -- 4) Customer Purchase Frequency:
      -- 4a) Determine the average number of purchases made per customer.
                    
WITH PurchasesPerCustomer AS (
    SELECT 
        [Customer ID],
        COUNT([Order ID]) AS NumberOfPurchases
    FROM [Orders$] 
    GROUP BY [Customer ID]
)
SELECT 
    p.[Customer ID], 
    each.[Customer Name],
    p.NumberOfPurchases AS AvgPurchasesPerCustomer
FROM PurchasesPerCustomer AS p
JOIN (
    -- Using 'each' as the representative name for the cleaned list
    SELECT DISTINCT [Customer ID], [Customer Name] 
    FROM [Customers$] 
) AS each ON p.[Customer ID] = each.[Customer ID]
ORDER BY AvgPurchasesPerCustomer DESC;


      -- 4b) Identify any trends or patterns based on customer segments (e.g., consumer, corporate, home office).
            
            -- 4bi) Overall Performance by Segment
     
        SELECT 
            Segment,
            COUNT(DISTINCT "Customer ID") AS Total_Customers,
            COUNT("Order ID") AS Total_Orders,
            ROUND(SUM(Sales*Quantity ),2) AS Total_Sales,
            ROUND (AVG(Sales), 2) AS Avg_Order_Value
        FROM Orders$ 
        GROUP BY Segment
        ORDER BY Total_Sales DESC; 
        
         -- 4bii) Product Category Preference by Segment:
         SELECT 
            Segment,
            Category,
            ROUND(SUM(Sales*Quantity),2) AS Total_Sales
        FROM Orders$ 
        GROUP BY Segment, Category
        ORDER BY Segment, Total_Sales DESC;

        -- 4biii) Total and Average Profit per Segment:
        SELECT 
            Segment,
            ROUND(SUM(Profit),2) AS Total_Profit,
            ROUND(AVG(Profit),2) AS Avg_Profit
        FROM Orders$ 
        GROUP BY Segment
        ORDER BY Total_Profit DESC;
 
        -- 4biv) Order Frequency by Segment:
        SELECT 
            Segment,
            COUNT("Order ID") AS Total_Orders
        FROM Orders$ 
        GROUP BY Segment
        ORDER BY Total_Orders DESC;

        /*
        The Consumer segment places the highest number of orders, indicating it is the largest customer group.

        The Corporate segment generates higher average order values, suggesting bulk purchases.

        The Home Office segment contributes less to total sales but shows moderate purchasing activity.*/


-- 5) Monthly Purchase Trends:

       -- 5a) Analysis of monthly sales to determine any seasonal trends in customer purchases:
           SELECT                                
                MONTH("Order Date") AS Month,
                DATENAME(MONTH, "Order Date") AS Month_Name,
                ROUND(SUM(Sales*Quantity),2) AS Total_Monthly_Sales
            FROM Orders$ 
            GROUP BY  MONTH("Order Date"), DATENAME(MONTH, "Order Date")
            ORDER BY   Total_Monthly_Sales DESC; 

            -- Monthyly Sales Trend per customers
               SELECT
  o.[Customer ID],
  each.[Customer Name],
  MONTH(o.[Order Date]) AS [Month],
  DATENAME(MONTH, o.[Order Date]) AS [Month_Name],
  SUM(o.Sales * o.Quantity) AS Total_Monthly_Sales
FROM [Orders$] AS o
JOIN (
    SELECT DISTINCT [Customer ID], [Customer Name] 
    FROM [Customers$] 
) AS each ON o.[Customer ID] = each.[Customer ID]
GROUP BY 
    o.[Customer ID], 
    each.[Customer Name], 
    MONTH(o.[Order Date]), 
    DATENAME(MONTH, o.[Order Date])
ORDER BY Total_Monthly_Sales DESC;


     -- 5b) Identifying months with the highest and lowest number of orders and total sales.
            -- Month with Highest Number of Orders
                SELECT TOP 1
                MONTH("Order Date") AS Month,
                DATENAME(MONTH,"Order Date") AS Month_Name,
                COUNT("Order ID") HighestMonthylOrder
                FROM Orders$
                GROUP BY MONTH("Order Date"), DATENAME(MONTH,"Order Date")
                ORDER BY HighestMonthylOrder DESC ;
                
           
            -- Month with Highest Number of Total Sales
                SELECT TOP 1
                MONTH("Order Date") AS Month,
                DATENAME(MONTH,"Order Date") AS Month_Name,
                ROUND(SUM (Sales * Quantity), 2) AS HieghestTotalSale
                FROM Orders$
                GROUP BY MONTH("Order Date"), DATENAME(MONTH,"Order Date")
                ORDER BY HieghestTotalSale DESC ;
                
            -- Month with Lowest Number of Orders
                SELECT TOP 1
                MONTH("Order Date") AS Month,
                DATENAME(MONTH,"Order Date") AS Month_Name,
                COUNT("Order ID") LowestMonthylOrder
                FROM Orders$
                GROUP BY MONTH("Order Date"), DATENAME(MONTH,"Order Date")
                ORDER BY LowestMonthylOrder ASC ;

            -- Month with Lowest Number of Total Sales
                SELECT TOP 1
                MONTH("Order Date") AS Month,
                DATENAME(MONTH,"Order Date") AS Month_Name,
                ROUND(SUM (Sales * Quantity), 2) AS LowestTotalSale
                FROM Orders$
                GROUP BY MONTH("Order Date"), DATENAME(MONTH,"Order Date")
                ORDER BY LowestTotalSale  ASC ;