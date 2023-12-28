SELECT * FROM inventory.`cleaned data`;
-- Top Selling Drugs:

SELECT DrugName, SUM(Final_Sales) AS total_sales
FROM inventory.projectfinaldata
GROUP BY DrugName
ORDER BY total_sales DESC
LIMIT 10;

-- Sales Trend by Month:
SELECT YEAR(Dateofbill) AS year, MONTH(Dateofbill) AS month, SUM(Final_Sales) AS monthly_sales
FROM inventory.projectfinaldata
GROUP BY year, month
ORDER BY year, month;

-- Inventory Aging Analysis
SELECT DrugName,
       DATEDIFF(MAX(Dateofbill), MIN(Dateofbill)) AS days_in_inventory,
       SUM(Quantity) AS total_purchased,
       SUM(ReturnQuantity) AS total_returned,
       COUNT(*) AS total_sales
FROM inventory.projectfinaldata
GROUP BY DrugName
ORDER BY days_in_inventory DESC;

-- Category-wise Sales Distribution

SELECT SubCat, SUM(Final_Sales) AS total_sales
FROM inventory.projectfinaldata
GROUP BY SubCat
ORDER BY total_sales DESC;
-- Sales vs. Cost Analysis:

SELECT DrugName, SUM(Final_Sales) AS total_sales, SUM(Final_Cost) AS total_cost
FROM inventory.projectfinaldata
GROUP BY DrugName
ORDER BY total_sales DESC;

-- Most Frequent Buyers:
SELECT Patient_ID, COUNT(*) AS purchase_count
FROM inventory.projectfinaldata
GROUP BY Patient_ID
ORDER BY purchase_count DESC
LIMIT 10;
-- Drug Usage by Department:

SELECT Dept, DrugName, SUM(Quantity) AS total_used
FROM inventory.projectfinaldata
GROUP BY Dept, DrugName
ORDER BY total_used DESC;


