create database Cinema_Analytics;

use Cinema_Analytics;
go

-- check total records
select COUNT(*) as Total_Records
FROM [dbo].[CinemaTicket_Raw];

/*
Project: Cinema Analytics
Purpose: Data Quality Analysis
*/

SELECT TOP 10 *
FROM [dbo].[CinemaTicket_Raw];

-- Step 1: Check column names and data types
SELECT
    COLUMN_NAME, DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH, NUMERIC_PRECISION,
    NUMERIC_SCALE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'CinemaTicket_Raw'
ORDER BY ORDINAL_POSITION;

-- Check missing values (NULLs)
SELECT
    COUNT(*) - COUNT(film_code) AS Missing_film_code,
    COUNT(*) - COUNT(cinema_code) AS Missing_cinema_code,
    COUNT(*) - COUNT(total_sales) AS Missing_total_sales,
    COUNT(*) - COUNT(tickets_sold) AS Missing_tickets_sold,
    COUNT(*) - COUNT(tickets_out) AS Missing_tickets_out,
    COUNT(*) - COUNT(show_time) AS Missing_show_time,
    COUNT(*) - COUNT(occu_perc) AS Missing_occupancy,
    COUNT(*) - COUNT(ticket_price) AS Missing_ticket_price,
    COUNT(*) - COUNT(ticket_use) AS Missing_ticket_use,
    COUNT(*) - COUNT(capacity) AS Missing_capacity,
    COUNT(*) - COUNT([date]) AS Missing_date,
    COUNT(*) - COUNT([month]) AS Missing_month,
    COUNT(*) - COUNT([quarter]) AS Missing_quarter,
    COUNT(*) - COUNT([day]) AS Missing_day
FROM [dbo].[CinemaTicket_Raw];

-- Calculate missing-value percentage

SELECT
    COUNT(*) AS Total_Records,
    COUNT(*) - COUNT(occu_perc) AS Missing_Occupancy,
    CAST((COUNT(*) - COUNT(occu_perc)) * 100.0 / COUNT(*)
    AS DECIMAL(10,4)) AS Occupancy_Missing_Percentage,

    COUNT(*) - COUNT(capacity) AS Missing_Capacity,
    CAST((COUNT(*) - COUNT(capacity)) * 100.0 / COUNT(*)
    AS DECIMAL(10,4)) AS Capacity_Missing_Percentage
FROM [dbo].[CinemaTicket_Raw];

-- Check duplicate records

SELECT film_code, cinema_code, total_sales,tickets_sold, tickets_out,
    show_time, occu_perc, ticket_price,ticket_use,
    capacity, [date],[month],[quarter], [day],
    COUNT(*) AS Duplicate_Count
FROM [dbo].[CinemaTicket_Raw]
GROUP BY
    film_code,cinema_code,total_sales, tickets_sold,
    tickets_out,show_time,occu_perc,ticket_price,
    ticket_use,capacity,[date],[month],[quarter],[day]
HAVING COUNT(*) > 1;

-- Calculate the total number of duplicate groups and extra duplicate rows.

WITH DuplicateRecords AS
(
    SELECT COUNT(*) AS Record_Count
    FROM dbo.CinemaTicket_Raw
    GROUP BY
        film_code,cinema_code,total_sales,tickets_sold,
        tickets_out,show_time,occu_perc,ticket_price,
        ticket_use,capacity,[date],[month],[quarter],[day]
    HAVING COUNT(*) > 1)
SELECT
    COUNT(*) AS Duplicate_Groups,
    SUM(Record_Count) AS Records_In_Duplicate_Groups,
    SUM(Record_Count - 1) AS Extra_Duplicate_Rows
FROM DuplicateRecords;

-- Check negative values
SELECT
    SUM(CASE WHEN total_sales < 0 THEN 1 ELSE 0 END) AS Negative_Sales,
    SUM(CASE WHEN tickets_sold < 0 THEN 1 ELSE 0 END) AS Negative_Tickets_Sold,
    SUM(CASE WHEN tickets_out < 0 THEN 1 ELSE 0 END) AS Negative_Tickets_Out,
    SUM(CASE WHEN ticket_price < 0 THEN 1 ELSE 0 END) AS Negative_Ticket_Price,
    SUM(CASE WHEN ticket_use < 0 THEN 1 ELSE 0 END) AS Negative_Ticket_Use,
    SUM(CASE WHEN capacity < 0 THEN 1 ELSE 0 END) AS Negative_Capacity
FROM dbo.CinemaTicket_Raw;

-- Check occupancy above 100%
SELECT
COUNT(*) AS Occupancy_Above_100
FROM dbo.CinemaTicket_Raw
WHERE occu_perc > 100;

-- Check occupancy below 0%

SELECT
COUNT(*) AS Occupancy_Below_Zero
FROM dbo.CinemaTicket_Raw
WHERE occu_perc < 0;

-- Check minimum and maximum values
SELECT
    MIN(total_sales) AS Min_Sales,
    MAX(total_sales) AS Max_Sales,

    MIN(tickets_sold) AS Min_Tickets_Sold,
    MAX(tickets_sold) AS Max_Tickets_Sold,

    MIN(ticket_price) AS Min_Ticket_Price,
    MAX(ticket_price) AS Max_Ticket_Price,

    MIN(occu_perc) AS Min_Occupancy,
    MAX(occu_perc) AS Max_Occupancy,

    MIN(capacity) AS Min_Capacity,
    MAX(capacity) AS Max_Capacity,

    MIN(ticket_use) AS Min_Ticket_Use,
    MAX(ticket_use) AS Max_Ticket_Use
FROM dbo.CinemaTicket_Raw;

-- Investigate unusually high ticket prices
SELECT TOP 10
    film_code,cinema_code,total_sales,tickets_sold,
    show_time,ticket_price,occu_perc,capacity,[date]
FROM dbo.CinemaTicket_Raw
ORDER BY ticket_price DESC;

-- Check the ticket-price distribution
SELECT
    CASE
        WHEN ticket_price < 1000 THEN 'Below 1000'
        WHEN ticket_price < 10000 THEN '1000 - 9999'
        WHEN ticket_price < 100000 THEN '10000 - 99999'
        WHEN ticket_price < 500000 THEN '100000 - 499999'
        ELSE '500000 and above'
    END AS Ticket_Price_Range,
    COUNT(*) AS Record_Count
FROM dbo.CinemaTicket_Raw
GROUP BY
    CASE
        WHEN ticket_price < 1000 THEN 'Below 1000'
        WHEN ticket_price < 10000 THEN '1000 - 9999'
        WHEN ticket_price < 100000 THEN '10000 - 99999'
        WHEN ticket_price < 500000 THEN '100000 - 499999'
        ELSE '500000 and above'
    END
ORDER BY MIN(ticket_price);

-- Check date range
SELECT
    MIN([date]) AS First_Date,MAX([date]) AS Last_Date,
    COUNT(DISTINCT [date]) AS Total_Distinct_Dates
FROM dbo.CinemaTicket_Raw;

-- Validate month, quarter and day columns
SELECT
    COUNT(*) AS Total_Records,SUM(CASE WHEN [month] <> MONTH([date])
    THEN 1 ELSE 0 END) AS Incorrect_Month,
    SUM(CASE WHEN [quarter] <> DATEPART(QUARTER, [date])
    THEN 1 ELSE 0 END) AS Incorrect_Quarter,
    SUM(CASE WHEN [day] <> DAY([date]) THEN 1 ELSE 0
    END) AS Incorrect_Day
FROM dbo.CinemaTicket_Raw;

-- Check show_time values
SELECT show_time, COUNT(*) AS Record_Count
FROM dbo.CinemaTicket_Raw GROUP BY show_time
ORDER BY show_time;

-- Check occupancy distribution
SELECT CASE WHEN occu_perc < 25 THEN 'Low Occupancy'
WHEN occu_perc < 50 THEN 'Moderate Occupancy'
WHEN occu_perc < 75 THEN 'Good Occupancy'
WHEN occu_perc <= 100 THEN 'High Occupancy'
ELSE 'Above 100%' END AS Occupancy_Category,COUNT(*) AS Record_Count
FROM dbo.CinemaTicket_Raw WHERE occu_perc IS NOT NULL
GROUP BY CASE
WHEN occu_perc < 25 THEN 'Low Occupancy'
WHEN occu_perc < 50 THEN 'Moderate Occupancy'
WHEN occu_perc < 75 THEN 'Good Occupancy'
WHEN occu_perc <= 100 THEN 'High Occupancy'
ELSE 'Above 100%' END ORDER BY MIN(occu_perc);

-- Investigate negative capacity records
SELECT film_code, cinema_code, total_sales, tickets_sold,
show_time, occu_perc,ticket_price,capacity,[date]
FROM dbo.CinemaTicket_Raw WHERE capacity < 0
ORDER BY capacity;

-- Check negative ticket_use records
SELECT film_code, cinema_code, total_sales, tickets_sold,
tickets_out, ticket_use, show_time, occu_perc,
capacity, [date] FROM dbo.CinemaTicket_Raw
WHERE ticket_use < 0 ORDER BY ticket_use;

-- Verify the ticket_use formula
SELECT COUNT(*) AS Total_Records,SUM(CASE
WHEN ticket_use = tickets_sold - tickets_out THEN 1 ELSE 0
END) AS Matching_Records,

SUM(CASE WHEN ticket_use <> tickets_sold - tickets_out
THEN 1 ELSE 0 END) AS Non_Matching_Records
FROM dbo.CinemaTicket_Raw;

-- Check whether occupancy matches tickets sold and capacity
SELECT TOP 20 film_code, cinema_code,tickets_sold,capacity, occu_perc,
CAST((tickets_sold * 100.0) / NULLIF(capacity, 0)
AS DECIMAL(10,2)) AS Calculated_Occupancy
FROM dbo.CinemaTicket_Raw
WHERE capacity > 0
  AND occu_perc IS NOT NULL
ORDER BY film_code;

-- Verify occupancy formula across all records
SELECT COUNT(*) AS Total_Comparable_Records,
SUM(CASE WHEN ABS(occu_perc - (tickets_sold * 100.0 / capacity)) < 0.02
THEN 1 ELSE 0 END) AS Matching_Records,
SUM(CASE WHEN ABS(occu_perc - (tickets_sold * 100.0 / capacity)) >= 0.02
THEN 1 ELSE 0 END) AS Non_Matching_Records
FROM dbo.CinemaTicket_Raw
WHERE capacity > 0
  AND occu_perc IS NOT NULL;

--Inspect missing occupancy and capacity

SELECT
    film_code,cinema_code,tickets_sold,tickets_out,
    occu_perc,capacity,ticket_price,total_sales,
    show_time,[date]
FROM dbo.CinemaTicket_Raw
WHERE occu_perc IS NULL OR capacity IS NULL
ORDER BY cinema_code, [date];

-- Check available capacity for affected cinemas

WITH Missing_Capacity_Cinemas AS
( SELECT DISTINCT cinema_code FROM dbo.CinemaTicket_Raw
    WHERE capacity IS NULL)
SELECT
    R.cinema_code,
    COUNT(*) AS Total_Records,
    COUNT(R.capacity) AS Records_With_Capacity,
    COUNT(DISTINCT R.capacity) AS Distinct_Capacity_Values,
    MIN(R.capacity) AS Minimum_Capacity,
    MAX(R.capacity) AS Maximum_Capacity
FROM dbo.CinemaTicket_Raw R
INNER JOIN Missing_Capacity_Cinemas M
ON R.cinema_code = M.cinema_code
GROUP BY R.cinema_code
ORDER BY R.cinema_code;

-- Investigate duplicate screening combinations

SELECT
film_code,cinema_code,show_time,[date],
COUNT(*) AS Record_Count
FROM dbo.CinemaTicket_Raw
GROUP BY
film_code,cinema_code,show_time,[date]
HAVING COUNT(*) > 1
ORDER BY Record_Count DESC;

-- Compare records within repeated screening combinations

SELECT
film_code,cinema_code,show_time,[date],
COUNT(*) AS Record_Count,
COUNT(DISTINCT total_sales) AS Distinct_Sales,
COUNT(DISTINCT tickets_sold) AS Distinct_Tickets_Sold,
COUNT(DISTINCT tickets_out) AS Distinct_Tickets_Out,
COUNT(DISTINCT ticket_price) AS Distinct_Ticket_Prices,
COUNT(DISTINCT occu_perc) AS Distinct_Occupancy,
COUNT(DISTINCT capacity) AS Distinct_Capacity
FROM dbo.CinemaTicket_Raw
GROUP BY
film_code,cinema_code,show_time,[date]
HAVING COUNT(*) > 1
ORDER BY [date], cinema_code;

-- Inspect negative capacity records

SELECT
film_code,cinema_code,tickets_sold,tickets_out,
ticket_use,occu_perc,capacity,ticket_price,
total_sales,show_time,[date]
FROM dbo.CinemaTicket_Raw
WHERE capacity < 0
ORDER BY [date];

-- Check capacity values for cinema 557

SELECT cinema_code,capacity,
COUNT(*) AS Record_Count
FROM dbo.CinemaTicket_Raw
WHERE cinema_code = 557
GROUP BY cinema_code,capacity
ORDER BY capacity;

-- Inspect occupancy above 100%

SELECT
film_code,cinema_code,tickets_sold,capacity,
occu_perc,ticket_price,total_sales,show_time,[date]
FROM dbo.CinemaTicket_Raw
WHERE occu_perc > 100
ORDER BY occu_perc DESC;

-- Categorize occupancy above 100%

SELECT
    CASE
        WHEN occu_perc > 100 AND occu_perc <= 105
            THEN '100-105%'
        WHEN occu_perc > 105 AND occu_perc <= 110
            THEN '105-110%'
        WHEN occu_perc > 110 AND occu_perc <= 120
            THEN '110-120%'
        WHEN occu_perc > 120 AND occu_perc <= 130
            THEN '120-130%'
        WHEN occu_perc > 130
            THEN 'Above 130%'
    END AS Occupancy_Range,
    COUNT(*) AS Record_Count
FROM dbo.CinemaTicket_Raw
WHERE occu_perc > 100
GROUP BY
    CASE
        WHEN occu_perc > 100 AND occu_perc <= 105
            THEN '100-105%'
        WHEN occu_perc > 105 AND occu_perc <= 110
            THEN '105-110%'
        WHEN occu_perc > 110 AND occu_perc <= 120
            THEN '110-120%'
        WHEN occu_perc > 120 AND occu_perc <= 130
            THEN '120-130%'
        WHEN occu_perc > 130
            THEN 'Above 130%'
    END
ORDER BY Occupancy_Range;

-- Investigate zero occupancy records

SELECT
    COUNT(*) AS Total_Zero_Occupancy,
    SUM(CASE WHEN tickets_sold = 0 THEN 1 ELSE 0 END)
        AS Zero_Tickets_Sold,
    SUM(CASE WHEN tickets_sold > 0 THEN 1 ELSE 0 END)
        AS Tickets_Sold_Greater_Than_Zero,
    SUM(CASE WHEN capacity <= 0 THEN 1 ELSE 0 END)
        AS Invalid_Capacity,
    SUM(CASE WHEN capacity IS NULL THEN 1 ELSE 0 END)
        AS Missing_Capacity
FROM dbo.CinemaTicket_Raw
WHERE occu_perc = 0;


-- Investigate negative ticket usage

SELECT
    COUNT(*) AS Negative_Ticket_Use_Records,
    MIN(ticket_use) AS Minimum_Ticket_Use,
    MAX(ticket_use) AS Maximum_Ticket_Use,
    SUM(CASE WHEN tickets_sold > 0 THEN 1 ELSE 0 END)
        AS Records_With_Tickets_Sold,
    SUM(CASE WHEN tickets_out > tickets_sold THEN 1 ELSE 0 END)
        AS Records_Where_Tickets_Out_Exceed_Sold
FROM dbo.CinemaTicket_Raw
WHERE ticket_use < 0;

-- Check invalid ticket prices

SELECT
    COUNT(*) AS Total_Records,
    SUM(CASE WHEN ticket_price = 0 THEN 1 ELSE 0 END)
        AS Zero_Ticket_Price,
    SUM(CASE WHEN ticket_price < 0 THEN 1 ELSE 0 END)
        AS Negative_Ticket_Price,
    MIN(ticket_price) AS Minimum_Ticket_Price,
    MAX(ticket_price) AS Maximum_Ticket_Price
FROM dbo.CinemaTicket_Raw;