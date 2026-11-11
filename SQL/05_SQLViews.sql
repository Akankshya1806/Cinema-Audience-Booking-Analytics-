USE Cinema_Analytics;
GO

-- View 1: Cleaned Cinema Ticket Data

CREATE VIEW dbo.vw_CinemaTicket_Cleaned
AS
SELECT
film_code,cinema_code,total_sales,tickets_sold,tickets_out,
show_time,occu_perc,ticket_price,ticket_use,capacity,date,
month,quarter,day,Occupancy_Flag
FROM dbo.CinemaTicket_Cleaned;
GO

SELECT TOP 10 *
FROM dbo.vw_CinemaTicket_Cleaned;

-- View 2: Cinema Performance

CREATE VIEW dbo.vw_Cinema_Performance
AS
SELECT
    cinema_code,
    SUM(total_sales) AS Total_Revenue,
    SUM(tickets_sold) AS Total_Tickets_Sold,
    AVG(occu_perc) AS Average_Occupancy,
    AVG(ticket_price) AS Average_Ticket_Price,
    COUNT(*) AS Total_Records
FROM dbo.CinemaTicket_Cleaned
WHERE Occupancy_Flag = 'Valid'
GROUP BY cinema_code;
GO

SELECT *
FROM dbo.vw_Cinema_Performance
ORDER BY Total_Revenue DESC;

-- View 3: Film Performance

CREATE VIEW dbo.vw_Film_Performance
AS
SELECT
    film_code,
    SUM(total_sales) AS Total_Revenue,
    SUM(tickets_sold) AS Total_Tickets_Sold,
    AVG(ticket_price) AS Average_Ticket_Price,
    AVG(occu_perc) AS Average_Occupancy,
    COUNT(DISTINCT cinema_code) AS Total_Cinemas,
    COUNT(*) AS Total_Records
FROM dbo.CinemaTicket_Cleaned
WHERE Occupancy_Flag = 'Valid'
GROUP BY film_code;
GO

SELECT *
FROM dbo.vw_Film_Performance
ORDER BY Total_Revenue DESC;

-- View 4: Monthly Performance

CREATE VIEW dbo.vw_Monthly_Performance
AS
SELECT
    YEAR(date) AS Sales_Year,
    MONTH(date) AS Sales_Month,
    SUM(total_sales) AS Total_Revenue,
    SUM(tickets_sold) AS Total_Tickets_Sold,
    AVG(ticket_price) AS Average_Ticket_Price,
    AVG(occu_perc) AS Average_Occupancy,
    COUNT(*) AS Total_Records
FROM dbo.CinemaTicket_Cleaned
GROUP BY
    YEAR(date),
    MONTH(date);
GO

SELECT *
FROM dbo.vw_Monthly_Performance
ORDER BY Sales_Year, Sales_Month;



-- View 5: Quarterly Performance
CREATE VIEW dbo.vw_Quarterly_Performance
AS
SELECT
    YEAR(date) AS Sales_Year,
    DATEPART(QUARTER, date) AS Sales_Quarter,
    SUM(total_sales) AS Total_Revenue,
    SUM(tickets_sold) AS Total_Tickets_Sold,
    AVG(ticket_price) AS Average_Ticket_Price,
    AVG(occu_perc) AS Average_Occupancy,
    COUNT(*) AS Total_Records
FROM dbo.CinemaTicket_Cleaned
GROUP BY
    YEAR(date),
    DATEPART(QUARTER, date);
GO

SELECT *
FROM dbo.vw_Quarterly_Performance
ORDER BY Sales_Year, Sales_Quarter;


SELECT name
FROM sys.views
WHERE schema_id = SCHEMA_ID('dbo')
ORDER BY name;