USE Cinema_Analytics;
GO

-- Q1: Film-wise Revenue Analysis

SELECT
    film_code,
    SUM(total_sales) AS Total_Revenue,
    SUM(tickets_sold) AS Total_Tickets_Sold,
    COUNT(DISTINCT cinema_code) AS Total_Cinemas,
    AVG(total_sales) AS Average_Revenue
FROM dbo.CinemaTicket_Cleaned
GROUP BY film_code
ORDER BY Total_Revenue DESC;

-- Q2: Cinema-wise Revenue Analysis

SELECT
    cinema_code,
    SUM(total_sales) AS Total_Revenue,
    SUM(tickets_sold) AS Total_Tickets_Sold,
    COUNT(DISTINCT film_code) AS Total_Films,
    AVG(occu_perc) AS Average_Occupancy
FROM dbo.CinemaTicket_Cleaned
WHERE Occupancy_Flag IN ('Valid', 'Above 100%')
GROUP BY cinema_code
ORDER BY Total_Revenue DESC;

-- Q3: Identify cinemas with low average occupancy

SELECT
    cinema_code,
    AVG(occu_perc) AS Average_Occupancy,
    SUM(tickets_sold) AS Total_Tickets_Sold,
    SUM(capacity) AS Total_Capacity,
    COUNT(*) AS Total_Records
FROM dbo.CinemaTicket_Cleaned
WHERE Occupancy_Flag = 'Valid'
GROUP BY cinema_code
HAVING COUNT(*) >= 30
ORDER BY Average_Occupancy ASC;

-- Q4: Showtime-wise occupancy analysis

SELECT
    show_time,
    AVG(occu_perc) AS Average_Occupancy,
    SUM(tickets_sold) AS Total_Tickets_Sold,
    COUNT(*) AS Total_Records
FROM dbo.CinemaTicket_Cleaned
WHERE Occupancy_Flag = 'Valid'
GROUP BY show_time
ORDER BY Average_Occupancy DESC;

-- Q5: Film-wise ticket price analysis

SELECT
    film_code,
    AVG(ticket_price) AS Average_Ticket_Price,
    MIN(ticket_price) AS Minimum_Ticket_Price,
    MAX(ticket_price) AS Maximum_Ticket_Price,
    SUM(tickets_sold) AS Total_Tickets_Sold,
    COUNT(*) AS Total_Records
FROM dbo.CinemaTicket_Cleaned
WHERE Occupancy_Flag = 'Valid'
GROUP BY film_code
ORDER BY Average_Ticket_Price DESC;

-- Q6: Cinema-wise occupancy and ticket price analysis

SELECT
    cinema_code,
    AVG(occu_perc) AS Average_Occupancy,
    AVG(ticket_price) AS Average_Ticket_Price,
    SUM(tickets_sold) AS Total_Tickets_Sold,
    SUM(total_sales) AS Total_Revenue,
    COUNT(*) AS Total_Records
FROM dbo.CinemaTicket_Cleaned
WHERE Occupancy_Flag = 'Valid'
GROUP BY cinema_code
HAVING COUNT(*) >= 30
ORDER BY Total_Revenue DESC;

-- Q7: High occupancy cinemas with comparatively low revenue

SELECT
    cinema_code,
    AVG(occu_perc) AS Average_Occupancy,
    AVG(ticket_price) AS Average_Ticket_Price,
    SUM(tickets_sold) AS Total_Tickets_Sold,
    SUM(total_sales) AS Total_Revenue,
    COUNT(*) AS Total_Records
FROM dbo.CinemaTicket_Cleaned
WHERE Occupancy_Flag = 'Valid'
GROUP BY cinema_code
HAVING COUNT(*) >= 30
   AND AVG(occu_perc) >= 40
ORDER BY Total_Revenue ASC;

-- Q8: Monthly revenue and ticket sales analysis

SELECT
    YEAR(date) AS Sales_Year,
    MONTH(date) AS Sales_Month,
    SUM(total_sales) AS Total_Revenue,
    SUM(tickets_sold) AS Total_Tickets_Sold,
    AVG(ticket_price) AS Average_Ticket_Price,
    COUNT(*) AS Total_Records
FROM dbo.CinemaTicket_Cleaned
GROUP BY
    YEAR(date),
    MONTH(date)
ORDER BY
    Sales_Year,
    Sales_Month;

-- Q9: Quarterly revenue and ticket sales analysis

SELECT
    YEAR(date) AS Sales_Year,
    DATEPART(QUARTER, date) AS Sales_Quarter,
    SUM(total_sales) AS Total_Revenue,
    SUM(tickets_sold) AS Total_Tickets_Sold,
    AVG(ticket_price) AS Average_Ticket_Price,
    COUNT(*) AS Total_Records
FROM dbo.CinemaTicket_Cleaned
GROUP BY
    YEAR(date),
    DATEPART(QUARTER, date)
ORDER BY
    Sales_Year,
    Sales_Quarter;


-- Q10: Overall business performance summary

SELECT
    COUNT(*) AS Total_Records,
    COUNT(DISTINCT film_code) AS Total_Films,
    COUNT(DISTINCT cinema_code) AS Total_Cinemas,
    SUM(total_sales) AS Total_Revenue,
    SUM(tickets_sold) AS Total_Tickets_Sold,
    AVG(ticket_price) AS Average_Ticket_Price,
    AVG(occu_perc) AS Average_Occupancy,
    MIN(date) AS First_Date,
    MAX(date) AS Last_Date
FROM dbo.CinemaTicket_Cleaned
WHERE Occupancy_Flag = 'Valid';