SELECT * FROM inventory.projectfinaldata;
-- remove duplicates
DELETE p
FROM inventory.projectfinaldata p
LEFT JOIN (
    SELECT MIN(Patient_ID) AS min_rowid
    FROM inventory.projectfinaldata
    GROUP BY Typeofsales, Patient_ID, Specialisation, Dept, Dateofbill, Quantity, ReturnQuantity, Final_Cost, Final_Sales, RtnMRP, Formulation, DrugName, SubCat, SubCat1
) t ON p.Patient_ID = t.min_rowid
WHERE t.min_rowid IS NULL;


-- handle missing values
UPDATE inventory.projectfinaldata
SET Specialisation = 'Unknown'
WHERE Specialisation IS NULL;

UPDATE inventory.projectfinaldata
SET SubCat = 'Not Available'
WHERE SubCat IS NULL;

-- Repeat similar UPDATE statements for other columns as needed

-- normalize data
UPDATE inventory.projectfinaldata
SET Dateofbill = 
    CASE
        WHEN LOCATE('-', Dateofbill) > 0 THEN Dateofbill
        WHEN LOCATE('/', Dateofbill) > 0 THEN Dateofbill
        ELSE NULL
    END;
-- Removing Outliers
DELETE FROM inventory.projectfinaldata
WHERE Final_Cost < 0 OR Final_Cost > 1000000;

DELETE FROM inventory.projectfinaldata
WHERE Final_Sales < 0 OR Final_Sales > 1000000;

-- Removing Invalid Records
DELETE FROM inventory.projectfinaldata
WHERE Quantity < 0 OR ReturnQuantity < 0;


-- Calculate mean and variance
SELECT
    AVG(Final_Cost) AS mean_final_cost,
    VARIANCE(Final_Cost) AS variance_final_cost,
    AVG(Final_Sales) AS mean_final_sales,
    VARIANCE(Final_Sales) AS variance_final_sales,
    AVG(ReturnQuantity) AS mean_return_quantity,
    VARIANCE(ReturnQuantity) AS variance_return_quantity
FROM inventory.projectfinaldata;
-- EDA 1 Meadian Calculation
DELIMITER //

CREATE PROCEDURE CalculateMedian()
BEGIN
    DECLARE total_count INT;
    DECLARE middle_position INT;
    DECLARE median_value DECIMAL(10, 2);
    
    SELECT COUNT(*) INTO total_count FROM inventory.projectfinaldata;

    SET middle_position = (total_count + 1) DIV 2;
    
    SELECT Final_Sales INTO median_value
    FROM (
        SELECT Final_Sales, @rownum := @rownum + 1 AS rownum
        FROM inventory.projectfinaldata, (SELECT @rownum := 0) r
        ORDER BY Final_Sales
    ) AS ranked
    WHERE rownum = middle_position;
    
    SELECT
        COUNT(*) AS total_records,
        AVG(Final_Sales) AS avg_sales,
        MIN(Final_Sales) AS min_sales,
        MAX(Final_Sales) AS max_sales,
        median_value AS median_sales,
        STDDEV_POP(Final_Sales) AS std_deviation_sales
    FROM inventory.projectfinaldata;
END //

DELIMITER ;
CALL CalculateMedian();

-- EDA 2 Visualization
-- Number of sales per specialization
SELECT Specialisation, COUNT(*) AS sales_count
FROM inventory.projectfinaldata
GROUP BY Specialisation
ORDER BY sales_count DESC;

-- Daily sales trend
SELECT DATE(Dateofbill) AS bill_date, SUM(Final_Sales) AS daily_sales
FROM inventory.projectfinaldata
GROUP BY bill_date
ORDER BY bill_date;

-- EDA 3 Transformation
-- Convert 'Quantity' and 'ReturnQuantity' to positive values
UPDATE inventory.projectfinaldata
SET Quantity = ABS(Quantity), ReturnQuantity = ABS(ReturnQuantity);

-- Calculate total sales for each drug category
SELECT SubCat, SUM(Final_Sales) AS total_sales
FROM inventory.projectfinaldata
GROUP BY SubCat
ORDER BY total_sales DESC;

-- EDA 4 Interpretaion
-- Identify top-selling drugs and their sales
SELECT DrugName, SUM(Final_Sales) AS total_sales
FROM inventory.projectfinaldata
GROUP BY DrugName
ORDER BY total_sales DESC
LIMIT 10;

-- Calculate return rate for each drug
SELECT DrugName, COUNT(*) AS total_sales,
       SUM(CASE WHEN ReturnQuantity > 0 THEN 1 ELSE 0 END) AS total_returns,
       SUM(CASE WHEN ReturnQuantity > 0 THEN 1 ELSE 0 END) / COUNT(*) AS return_rate
FROM inventory.projectfinaldata
GROUP BY DrugName
ORDER BY return_rate DESC;

