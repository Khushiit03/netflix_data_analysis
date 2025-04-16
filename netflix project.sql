 #netflix database (project)
 
 use netflix;
 
 select*from netflix_titles;
 
 # QUEST 1-Count the Number of Movies vs TV Shows

SELECT 
    type,
    COUNT(*)
FROM netflix_titles
GROUP BY 1;

# Find the Most Common Rating for Movies and TV Shows

WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix_titles
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS 'rank'
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE 'rank' = 1;

# List All Movies Released in a Specific Year (e.g., 2020)

SELECT * 
FROM netflix_titles
WHERE release_year = 2020;

# Find the Top 5 Countries with the Most Content on Netflix
WITH RECURSIVE split_countries AS (
    SELECT 
        show_id,
        TRIM(SUBSTRING_INDEX(country, ',', 1)) AS country,
        CASE 
            WHEN country LIKE '%,%' THEN SUBSTRING_INDEX(country, ',', -1)
            ELSE NULL
        END AS rest
    FROM netflix_titles
    WHERE country IS NOT NULL

    UNION ALL

    SELECT 
        show_id,
        TRIM(SUBSTRING_INDEX(rest, ',', 1)) AS country,
        CASE 
            WHEN rest = SUBSTRING_INDEX(rest, ',', 1) THEN NULL
            ELSE SUBSTRING_INDEX(rest, ',', -1)
        END
    FROM split_countries
    WHERE rest IS NOT NULL
)

SELECT 
    country,
    COUNT(*) AS total_content
FROM split_countries
WHERE country IS NOT NULL AND country != ''
GROUP BY country
ORDER BY total_content DESC
LIMIT 5;

#Identify the Longest Movie

SELECT 
    title,
    duration,
    CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) AS duration_minutes
FROM netflix_titles
WHERE type = 'Movie'
  AND duration LIKE '%min'
ORDER BY duration_minutes DESC
LIMIT 1;



#Find Content Added in the Last 5 Years

SELECT *
FROM netflix_titles
WHERE STR_TO_DATE(date_added, '%M %d, %Y') >= CURDATE() - INTERVAL 5 YEAR;

#Find All Movies/TV Shows by Director 'Rajiv Chilaka'
SELECT *
FROM netflix_titles
WHERE TRIM(director) = 'Rajiv Chilaka'
   OR director LIKE 'Rajiv Chilaka,%'
   OR director LIKE '%, Rajiv Chilaka'
   OR director LIKE '%, Rajiv Chilaka,%';

#List All TV Shows with More Than 5 Seasons
SELECT *
FROM netflix_titles
WHERE type = 'TV Show'
  AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;
  
  
#Count the Number of Content Items in Each Genre

SELECT genre, COUNT(*) AS content_count
FROM (
    SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', numbers.n), ',', -1)) AS genre
    FROM netflix_titles
    JOIN (
        SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 
        UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
    ) AS numbers
    ON CHAR_LENGTH(listed_in) - CHAR_LENGTH(REPLACE(listed_in, ',', '')) >= numbers.n - 1
) AS genres
GROUP BY genre
ORDER BY content_count DESC;

#Find each year and the average numbers of content release in India on netflix.

SELECT release_year, AVG(content_count) AS avg_content_per_year
FROM (
    SELECT release_year, COUNT(*) AS content_count
    FROM netflix_titles
    WHERE country = 'India'
    GROUP BY release_year
) AS yearly_counts
GROUP BY release_year
ORDER BY release_year;

#List All Movies that are Documentaries

SELECT *
FROM netflix_titles
WHERE type = 'Movie'
  AND listed_in LIKE '%Documentary%';


#Find All Content Without a Director

SELECT *
FROM netflix_titles
WHERE director IS NULL
   OR director = '';

#Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
SELECT COUNT(*) AS movie_count
FROM netflix_titles
WHERE type = 'Movie'
  AND cast LIKE '%Salman Khan%'
  AND date_added >= CURDATE() - INTERVAL 10 YEAR;
  
  #Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
  
  SELECT actor, COUNT(*) AS movie_count
FROM (
    SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(cast, ',', numbers.n), ',', -1)) AS actor
    FROM netflix_titles
    JOIN (
        SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
        UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
    ) AS numbers
    ON CHAR_LENGTH(cast) - CHAR_LENGTH(REPLACE(cast, ',', '')) >= numbers.n - 1
    WHERE country = 'India'
      AND type = 'Movie'
) AS actors
GROUP BY actor
ORDER BY movie_count DESC
LIMIT 10;


 #Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
 
 SELECT title, 
       CASE
           WHEN LOWER(description) LIKE '%kill%' AND LOWER(description) LIKE '%violence%' THEN 'Kill & Violence'
           WHEN LOWER(description) LIKE '%kill%' THEN 'Kill'
           WHEN LOWER(description) LIKE '%violence%' THEN 'Violence'
           ELSE 'Other'
       END AS content_category
FROM netflix_titles;



