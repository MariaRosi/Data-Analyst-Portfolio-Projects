select * from
walmartsalesdata;

SELECT time,
(
	CASE WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
		 WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
         ELSE "Evening"
    END
) as time_of_day
FROM walmartsalesdata;


ALTER TABLE walmartsalesdata ADD COLUMN time_of_day VARCHAR(20);

UPDATE walmartsalesdata
SET time_of_day = (
	CASE WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
		 WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
         ELSE "Evening"
    END
);

SELECT date,
DAYNAME(date) AS day_name
FROM walmartsalesdata;

ALTER TABLE walmartsalesdata ADD COLUMN day_name VARCHAR(20);

UPDATE walmartsalesdata
SET day_name = DAYNAME(date);

SELECT date,
MONTHNAME(date)
FROM walmartsalesdata;

ALTER TABLE walmartsalesdata ADD COLUMN month_name VARCHAR(20);

UPDATE walmartsalesdata
SET month_name = MONTHNAME(date);

-- Payment method trend
SELECT
payment,
COUNT(payment) AS payment_count
FROM walmartsalesdata
GROUP BY payment
ORDER BY payment_count DESC;


-- Most selling product line
SELECT
`Product line`,
COUNT(`Product line`) AS product_line_count
FROM walmartsalesdata
GROUP BY `Product line`
ORDER BY product_line_count DESC;

-- Total revenue by month
SELECT
month_name,
ROUND(SUM(total), 4) AS per_month_revenue
FROM walmartsalesdata
GROUP BY month_name
ORDER BY per_month_revenue DESC;

-- Revenue per product line
SELECT
`product line`,
SUM(total) AS total_revenue_per_product_line
FROM walmartsalesdata
GROUP BY `product line`
ORDER BY total_revenue_per_product_line DESC;

-- Which branch sold more products quantity than average quantity
SELECT
branch,
SUM(quantity) as total_quantity,
AVG(quantity) as avg_quantity
FROM walmartsalesdata
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) from walmartsalesdata)
