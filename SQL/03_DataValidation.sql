-- Verify cleaned table record count

SELECT
COUNT(*) AS Cleaned_Total_Records,
COUNT(DISTINCT film_code) AS Distinct_Films,
COUNT(DISTINCT cinema_code) AS Distinct_Cinemas
FROM dbo.CinemaTicket_Cleaned;

-- Verify negative capacity values

SELECT
    COUNT(*) AS Total_Records,
    SUM(CASE WHEN capacity < 0 THEN 1 ELSE 0 END)
        AS Remaining_Negative_Capacity,
    SUM(CASE WHEN capacity IS NULL THEN 1 ELSE 0 END)
        AS Missing_Capacity
FROM dbo.CinemaTicket_Cleaned;

-- Missing capacity investigation

SELECT
    COUNT(*) AS Missing_Capacity_Records,
    SUM(CASE WHEN occu_perc IS NULL THEN 1 ELSE 0 END)
        AS Missing_Occupancy,
    SUM(CASE WHEN occu_perc = 0 THEN 1 ELSE 0 END)
        AS Zero_Occupancy
FROM dbo.CinemaTicket_Cleaned
WHERE capacity IS NULL;


-- Verify occupancy quality flags

SELECT
Occupancy_Flag,COUNT(*) AS Record_Count
FROM dbo.CinemaTicket_Cleaned
GROUP BY Occupancy_Flag
ORDER BY Occupancy_Flag;

-- Verify the revised flags

SELECT
Occupancy_Flag,COUNT(*) AS Record_Count
FROM dbo.CinemaTicket_Cleaned
GROUP BY Occupancy_Flag
ORDER BY Occupancy_Flag;


-- Check remaining missing values

SELECT
    SUM(CASE WHEN film_code IS NULL THEN 1 ELSE 0 END) AS Missing_Film_Code,
    SUM(CASE WHEN cinema_code IS NULL THEN 1 ELSE 0 END) AS Missing_Cinema_Code,
    SUM(CASE WHEN total_sales IS NULL THEN 1 ELSE 0 END) AS Missing_Total_Sales,
    SUM(CASE WHEN tickets_sold IS NULL THEN 1 ELSE 0 END) AS Missing_Tickets_Sold,
    SUM(CASE WHEN tickets_out IS NULL THEN 1 ELSE 0 END) AS Missing_Tickets_Out,
    SUM(CASE WHEN show_time IS NULL THEN 1 ELSE 0 END) AS Missing_Show_Time,
    SUM(CASE WHEN occu_perc IS NULL THEN 1 ELSE 0 END) AS Missing_Occupancy,
    SUM(CASE WHEN ticket_price IS NULL THEN 1 ELSE 0 END) AS Missing_Ticket_Price,
    SUM(CASE WHEN ticket_use IS NULL THEN 1 ELSE 0 END) AS Missing_Ticket_Use,
    SUM(CASE WHEN capacity IS NULL THEN 1 ELSE 0 END) AS Missing_Capacity,
    SUM(CASE WHEN date IS NULL THEN 1 ELSE 0 END) AS Missing_Date
FROM dbo.CinemaTicket_Cleaned;

-- Check invalid numeric values

SELECT
    SUM(CASE WHEN total_sales < 0 THEN 1 ELSE 0 END) AS Negative_Sales,
    SUM(CASE WHEN tickets_sold < 0 THEN 1 ELSE 0 END) AS Negative_Tickets_Sold,
    SUM(CASE WHEN tickets_out < 0 THEN 1 ELSE 0 END) AS Negative_Tickets_Out,
    SUM(CASE WHEN ticket_price < 0 THEN 1 ELSE 0 END) AS Negative_Ticket_Price,
    SUM(CASE WHEN capacity < 0 THEN 1 ELSE 0 END) AS Negative_Capacity
FROM dbo.CinemaTicket_Cleaned;

-- Validate ticket usage calculation

SELECT
COUNT(*) AS Total_Records,
SUM(CASE WHEN ticket_use <> tickets_sold - tickets_out
         THEN 1 ELSE 0
         END ) AS Mismatched_Records
FROM dbo.CinemaTicket_Cleaned;

-- Validate occupancy calculation
SELECT
COUNT(*) AS Total_Valid_Capacity_Records,
SUM( CASE
     WHEN ABS(
        occu_perc - (CAST(tickets_sold AS DECIMAL(18,4)) * 100 / capacity)
            ) > 0.02
            THEN 1 ELSE 0
        END) AS Occupancy_Mismatches
FROM dbo.CinemaTicket_Cleaned
WHERE capacity > 0 AND occu_perc IS NOT NULL;

-- Validate date-related columns
SELECT
    COUNT(*) AS Total_Records,
    SUM(CASE WHEN month <> MONTH(date) THEN 1 ELSE 0 END)
        AS Month_Mismatches,
    SUM(CASE WHEN quarter <> DATEPART(QUARTER, date) THEN 1 ELSE 0 END)
        AS Quarter_Mismatches,
    SUM(CASE WHEN day <> DAY(date) THEN 1 ELSE 0 END)
        AS Day_Mismatches
FROM dbo.CinemaTicket_Cleaned
WHERE date IS NOT NULL;

-- Check duplicate records again

SELECT
    COUNT(*) AS Total_Records,
    COUNT(*) - COUNT(DISTINCT CONCAT(
        film_code, '|',
        cinema_code, '|',
        total_sales, '|',
        tickets_sold, '|',
        tickets_out, '|',
        show_time, '|',
        occu_perc, '|',
        ticket_price, '|',
        ticket_use, '|',
        capacity, '|',
        date, '|',
        month, '|',
        quarter, '|',
        day
    )) AS Duplicate_Count
FROM dbo.CinemaTicket_Cleaned;

-- Validate occupancy flag classification
SELECT
    COUNT(*) AS Total_Records,
    SUM(CASE
        WHEN occu_perc > 100 AND Occupancy_Flag <> 'Above 100%'
        THEN 1 ELSE 0
    END) AS Incorrect_Above_100_Flag,
    SUM(CASE
        WHEN occu_perc IS NULL AND Occupancy_Flag <> 'Missing Occupancy'
        THEN 1 ELSE 0
    END) AS Incorrect_Missing_Flag,
    SUM(CASE
        WHEN capacity IS NULL AND occu_perc IS NOT NULL
             AND occu_perc <= 100
             AND Occupancy_Flag <> 'Invalid Capacity'
        THEN 1 ELSE 0
    END) AS Incorrect_Capacity_Flag
FROM dbo.CinemaTicket_Cleaned;


-- Check ticket price distribution
SELECT
    MIN(ticket_price) AS Minimum_Ticket_Price,
    MAX(ticket_price) AS Maximum_Ticket_Price,
    AVG(ticket_price) AS Average_Ticket_Price,
    COUNT(*) AS Total_Records
FROM dbo.CinemaTicket_Cleaned;

-- Check sales distribution
SELECT
    MIN(total_sales) AS Minimum_Sales,
    MAX(total_sales) AS Maximum_Sales,
    AVG(total_sales) AS Average_Sales,
    SUM(total_sales) AS Overall_Sales,
    COUNT(*) AS Total_Records
FROM dbo.CinemaTicket_Cleaned;

-- Check ticket quantity distribution
SELECT
    MIN(tickets_sold) AS Minimum_Tickets_Sold,
    MAX(tickets_sold) AS Maximum_Tickets_Sold,
    AVG(CAST(tickets_sold AS DECIMAL(18,2))) AS Average_Tickets_Sold,
    MIN(tickets_out) AS Minimum_Tickets_Out,
    MAX(tickets_out) AS Maximum_Tickets_Out,
    AVG(CAST(tickets_out AS DECIMAL(18,2))) AS Average_Tickets_Out
FROM dbo.CinemaTicket_Cleaned;

-- Check table structure and data types
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    NUMERIC_PRECISION,
    NUMERIC_SCALE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'CinemaTicket_Cleaned'
ORDER BY ORDINAL_POSITION;

-- Check invalid date values

SELECT
    MIN(date) AS First_Date,
    MAX(date) AS Last_Date,
    COUNT(DISTINCT date) AS Unique_Dates,
    SUM(CASE WHEN date IS NULL THEN 1 ELSE 0 END) AS Missing_Dates
FROM dbo.CinemaTicket_Cleaned;

-- Check occupancy percentage range

SELECT
    MIN(occu_perc) AS Minimum_Occupancy,
    MAX(occu_perc) AS Maximum_Occupancy,
    SUM(CASE WHEN occu_perc < 0 THEN 1 ELSE 0 END)
        AS Negative_Occupancy,
    SUM(CASE WHEN occu_perc > 100 THEN 1 ELSE 0 END)
        AS Above_100_Occupancy,
    SUM(CASE WHEN occu_perc = 0 THEN 1 ELSE 0 END)
        AS Zero_Occupancy
FROM dbo.CinemaTicket_Cleaned;

-- Final record count comparison

SELECT
    (SELECT COUNT(*) FROM dbo.CinemaTicket_Raw)
        AS Raw_Records,
    (SELECT COUNT(*) FROM dbo.CinemaTicket_Cleaned)
        AS Cleaned_Records,
    (SELECT COUNT(*) FROM dbo.CinemaTicket_Raw)
    -
    (SELECT COUNT(*) FROM dbo.CinemaTicket_Cleaned)
        AS Records_Removed;

-- Final data cleaning summary

SELECT
    COUNT(*) AS Total_Records,
    COUNT(DISTINCT film_code) AS Total_Films,
    COUNT(DISTINCT cinema_code) AS Total_Cinemas,
    SUM(CASE WHEN Occupancy_Flag = 'Valid' THEN 1 ELSE 0 END)
        AS Valid_Records,
    SUM(CASE WHEN Occupancy_Flag = 'Above 100%' THEN 1 ELSE 0 END)
        AS Above_100_Records,
    SUM(CASE WHEN Occupancy_Flag = 'Invalid Capacity' THEN 1 ELSE 0 END)
        AS Invalid_Capacity_Records,
    SUM(CASE WHEN Occupancy_Flag = 'Missing Occupancy' THEN 1 ELSE 0 END)
        AS Missing_Occupancy_Records
FROM dbo.CinemaTicket_Cleaned;