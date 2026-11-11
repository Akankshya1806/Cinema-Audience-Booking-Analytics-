USE Cinema_Analytics;
GO

-- Create a cleaned copy of the raw table

SELECT DISTINCT *
INTO dbo.CinemaTicket_Cleaned
FROM dbo.CinemaTicket_Raw;

-- Replace invalid capacity values

UPDATE dbo.CinemaTicket_Cleaned
SET capacity = NULL
WHERE capacity < 0;

-- Add occupancy quality flag

ALTER TABLE dbo.CinemaTicket_Cleaned
ADD Occupancy_Flag VARCHAR(30);

-- Populate occupancy quality flag

UPDATE dbo.CinemaTicket_Cleaned
SET Occupancy_Flag =
    CASE
        WHEN capacity IS NULL THEN 'Invalid Capacity'
        WHEN occu_perc IS NULL THEN 'Missing Occupancy'
        WHEN occu_perc > 100 THEN 'Above 100%'
        ELSE 'Valid'
    END;

-- Improve occupancy classification

UPDATE dbo.CinemaTicket_Cleaned
SET Occupancy_Flag =
    CASE
        WHEN occu_perc IS NULL THEN 'Missing Occupancy'
        WHEN capacity IS NULL THEN 'Invalid Capacity'
        WHEN occu_perc > 100 THEN 'Above 100%'
        ELSE 'Valid'
    END;
