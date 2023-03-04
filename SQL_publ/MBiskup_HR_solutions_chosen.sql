-- Here I present my solutions to the chosen SQL challenges

-- MEDIUM DIFFICULTY ---

-- pairs (in MS SQL)

SELECT f1.x, f1.y
FROM Functions f1
JOIN Functions f2
ON (f1.x = f2.y AND f1.y=f2.x) 
WHERE f1.x <= f1.y 
EXCEPT 
SELECT x, y
FROM Functions
WHERE x=y
GROUP BY x, y
HAVING COUNT(x)=1 
ORDER BY f1.x;

-- median (in MS SQL)

WITH LAT_row_table AS
(SELECT LAT_N,
ROW_NUMBER() OVER(ORDER BY LAT_N) AS row_number
FROM station)

SELECT 
    CASE WHEN MAX(row_number)%2=0 THEN                         -- for even number of elements we need AVG of two middle elements
        (SELECT CAST(ROUND(AVG(LAT_N),4) AS decimal(7,4)) FROM LAT_row_table 
        WHERE row_number = (SELECT CAST(MAX(row_number)/2.0 AS integer) FROM LAT_row_table) 
        OR row_number = (SELECT CAST(MAX(row_number)/2.0+1 AS integer) FROM LAT_row_table)
        )
    ELSE  (SELECT CAST(ROUND(LAT_N,4) AS decimal(7,4)) FROM LAT_row_table    -- for odd number of elements we need a middle element
                WHERE row_number = 
                 (SELECT CAST((MAX(row_number)+1)/2.0 AS integer) FROM LAT_row_table)  
                ) 
    END AS median
FROM LAT_row_table;

-- CONCAT(), LEFT() (in MySQL) 

SELECT CONCAT(name,'(',LEFT(occupation,1),')')
FROM OCCUPATIONS
ORDER BY name;

SELECT CONCAT('There are a total of ', COUNT(occupation), ' ', LOWER(occupation), 's.')
FROM OCCUPATIONS
GROUP BY occupation
ORDER BY COUNT(occupation), occupation;

-- CTE in action (in MS SQL)

WITH ch_count AS                      -- number of challenges
    (SELECT c.hacker_id, h.name, COUNT(c.challenge_id) AS total_ch
    FROM Hackers h
    JOIN Challenges c
    ON h.hacker_id = c.hacker_id
    GROUP BY c.hacker_id, h.name     
    ),
same_no_ch_count AS                 -- no of hackers with the same no of challenges
    ( SELECT total_ch, 
    COUNT(total_ch) AS h_same_no_ch  
    FROM ch_count
    GROUP BY total_ch),

MAX_total_ch AS
    (SELECT MAX(total_ch) AS max_t_ch FROM ch_count), 

same_no_ch_incl AS      -- exclude h with the same number of ch when this number is lower than the maximum number of ch
    (SELECT total_ch, 
        CASE WHEN h_same_no_ch > 1 AND total_ch < max_t_ch THEN 0 
        ELSE 1 END AS include 
    FROM same_no_ch_count, MAX_total_ch)  

SELECT chc.hacker_id, chc.name, chc.total_ch
FROM ch_count chc
JOIN same_no_ch_incl  inc
ON chc.total_ch = inc.total_ch
WHERE inc.include = 1
ORDER BY total_ch DESC, chc.hacker_id;


-- EASY DIFFICULTY ---

-- LEFT(), RIGHT() (in MySQL)

SELECT DISTINCT city FROM station
WHERE LEFT(city,1) NOT IN ('a','e','i','o','u') 
    OR RIGHT(city,1) NOT IN ('a','e','i','o','u');

-- subqueries, CTE, MAX() (in MS SQL)

WITH earnings_table AS
(SELECT employee_id, (months*salary) AS total_earnings
FROM Employee)

SELECT CONCAT( MAX(total_earnings), '  ',   
				(SELECT COUNT(employee_id) FROM earnings_table
				WHERE  total_earnings= (SELECT MAX(total_earnings) FROM earnings_table))  
                )
FROM earnings_table;
