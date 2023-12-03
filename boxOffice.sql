
-- Creating movie table
CREATE TABLE movie(
	url VARCHAR(1000),
	title VARCHAR(1000),
	studio VARCHAR(1000),
	rating VARCHAR(1000),
	runtime VARCHAR(1000),
	director VARCHAR(1000),
	metascore VARCHAR(1000),
	userscore VARCHAR(1000),
	release_date VARCHAR(1000),
	release_year VARCHAR(1000),
	PRIMARY KEY (title)
	
);


-- Creating sales table
CREATE TABLE sales (
	title VARCHAR (10000),
	genre VARCHAR (50),
	box_office VARCHAR (50),
	production_budget VARCHAR (50),
	opening_weekend VARCHAR (50),
	theatre_count VARCHAR (50),
	avg_run_per_theatre VARCHAR (50),
	runtime VARCHAR (50),
	creative_type VARCHAR (100),
	release_date VARCHAR (100),	
	url VARCHAR (1000),
	FOREIGN KEY (title)
		REFERENCES movie(title)

);


-- Creating expert review table
CREATE TABLE expert_review (
	url VARCHAR(1000),
	idvscore VARCHAR(50),
	expert_name VARCHAR(1000),
	review_date VARCHAR(100),
	expert_review VARCHAR (10000),
	clout VARCHAR(20),	
	authentic VARCHAR(20)

);


-- Creating user review table
CREATE TABLE user_review (
	url VARCHAR(1000),
	idvscore VARCHAR(50),
	reviewer VARCHAR(1000),
	review_date VARCHAR(100),
	thumbs_up VARCHAR(20),
	thumbs_tot VARCHAR(20),
	analytic VARCHAR(20),
	clout VARCHAR(20),
	authentic VARCHAR(20)

);


-- Creating awards table
CREATE TABLE movie_awards (
	awards VARCHAR (10000),
	title VARCHAR (1000)

);


-- Creating genre table
CREATE TABLE movie_genre (
	genre VARCHAR (10000),
	title VARCHAR (1000)

);


--The database is created and now we are going to analyze what is the relationship
--between production budgets and metascore to see how it influences movie box_office
-------------------------------------------------------------------------------------


--Step 1: Creating a subquey to rank movies based on box office per each genre 

CREATE TEMP TABLE budget_and_metascore AS --Creating a temporary table to store the query result so we can use the table in Python encapsulation for further analysis
WITH ranked_movies AS ( 
	SELECT
		m.title,
		CAST(s.box_office AS NUMERIC) AS budget, --- Changing the data type to numeric 
		CAST(m.metascore AS NUMERIC) AS metascore, --- Changing the data type to numeric
		CAST(s.box_office AS NUMERIC) AS box_office, --- Changing the data type to numeric
		g.genre,
			RANK() OVER (PARTITION BY g.genre ORDER BY s.box_office DESC) AS box_office_rank --- The rank function is used to assign a rank to each movie within its genre based on box_office
		FROM --- Partitioning by genre is used to ensure ranking is done separately for each genre 
			movie AS m
		INNER JOIN
			sales AS s ON m.title = s.title
		LEFT JOIN
			movie_genre AS g ON m.title = g.title
) 

--STEP 2: We pull the subquery with 'FROM' function to calculate the average production_budget, metascore and box_office of top 100 movies compared to 100 low performing movies per genre.
SELECT
    genre,
    AVG(CASE WHEN box_office_rank <= 100 THEN budget END) AS avg_top_budget, --- CASE statement is used to separate movies with ranks up to 100 top and 100 low per each genre.
    AVG(CASE WHEN box_office_rank > 100 THEN budget END) AS avg_low_budget,
	AVG(CASE WHEN box_office_rank <= 100 THEN metascore END) AS avg_top_metascore,
    AVG(CASE WHEN box_office_rank > 100 THEN metascore END) AS avg_low_metascore,
	AVG(CASE WHEN box_office_rank <= 100 THEN box_office END) AS avg_box_office_top_100,
    AVG(CASE WHEN box_office_rank > 100 THEN box_office END) AS avg_box_office_low_performing
FROM
    ranked_movies ---We use the ranked movies subquery to execute the average calculation 

GROUP BY
	genre --- We group by genre as we are partitioning by genre above.
ORDER BY 
	avg_top_budget DESC, avg_top_metascore DESC, avg_low_budget DESC, avg_low_metascore DESC, avg_box_office_top_100 DESC, avg_box_office_low_performing DESC;

--- We order by the above mentioned metrics to be able to have an overview of averages per genre

--NEXT STEP: We'll use Python to run a correlation analysis on the table, looking for connections between box office sales,
--metascore ratings, and production budgets. This research will assist us in showing the extent to which 
--film budgets and critical reception influence box office success.


--To run this code to preview the research table stored in a temporary table
SELECT * FROM budget_and_metascore



--We are going to analyze the relationship between director reputation, as measured by number of awards received and reputation score, 
--and sales performance measured by sales margin percentage of movies
----------------------------------------------------------------------



-- Step 1: Calculating the sales margin percentage for each movie per director, genre and release_year

CREATE TEMP TABLE director_reputation AS --Creating a temporary table to store the query result so we can use the table in Python encapsulation for further analysis
SELECT
    m.title, 
	m.director, 
	CAST(m.release_year AS INTEGER) AS release_year, --Change the release_year data type to integer
    s.genre,
    CAST(s.box_office AS NUMERIC) AS box_office, --Change the box_office data type to numeric
    CAST(s.production_budget AS NUMERIC) AS production_budget, -- Change the production_budget data type to numeric
	CASE --Calculate the sales margin percentage by removing zero values to avoid errors
		WHEN CAST(s.box_office AS NUMERIC) = 0 THEN NULL
            ELSE (CAST(s.box_office AS NUMERIC) - CAST(s.production_budget AS NUMERIC)) / NULLIF(CAST(s.box_office AS NUMERIC), 0) * 100
        END AS sales_margin_percentage,
    d.avg_expert_score,
	
	--The reputation of directors can be reflected on the number of awards their movies have received. 
	--Here we Count the number of awards each movie has received and count how many movies each director has directed.
	--As found in the literatures, the higher the reputation of the director the higher chances they can get more deals.
    COUNT(a.awards) AS total_awards,
	COUNT(*) OVER (PARTITION BY m.director) AS movie_count_per_director
	
--Step 2: We then join the movie, sales and expert_review tables to calculate the average expert review score per each movie and compare that to sales performance of each movie.
--The assumption is that, a movie with good reputation score, has higher chances of having good sales performance.
FROM
    movie AS m
INNER JOIN
    sales AS s
    ON m.title = s.title
LEFT JOIN
    ( -- We make a subquery to retrieve director reputation scores (avg_expert_score)
        SELECT
            m.director,
            AVG(CAST(e.idvscore AS DECIMAL(10, 2))) AS avg_expert_score
        FROM
            movie AS m
        LEFT JOIN
            expert_review AS e
            ON m.url = e.url
        GROUP BY
            m.director
    ) AS d
    ON m.director = d.director
LEFT JOIN
    movie_awards AS a
    ON m.title = a.title
GROUP BY
    m.title, m.director, m.metascore, m.userscore, s.genre, s.box_office, s.production_budget, d.avg_expert_score

--We order by box_office to have an overview per movie sales performance in descending order so we can first see the top sales performers.
ORDER BY
	box_office DESC;


--Next step: Using Python to analyze the correlation between sales_margin_percentage and avg_expert_score to determine if there's a trend.


--To run this code to preview the research table stored in a temporary table concerning director's reputation influence on movie sales performance
SELECT * FROM director_reputation


--We analyze the impact of movie genre produced by studios specialized in that genre can have on movie sales.
--We will rank movie genres by profit per genre to have the top performing genres and then populate the studio and release month
----------------------------------------------------------------------------------------------------------------------------------

	
--STEP 1: We calculate profit per genre.
	
CREATE TEMP TABLE studio_genre AS --Creating a temporary table to store the query result so we can use the table in Python encapsulation for further analysis
WITH movies_profit AS (
    SELECT
        s.genre,
        m.studio,
        TO_CHAR(TO_DATE(s.release_date, 'DD/MM/YYYY'), 'Month') AS release_month, -- We extract only the release month from the release date
		
		--Calculating movies profit as (box_office - production_budget) and we change the columns datatype to numeric. And we also join the movie and sales tables.
        SUM(CAST(s.box_office AS numeric)) - SUM(CAST(s.production_budget AS numeric)) AS profit
    FROM
        sales s
    JOIN
        movie m
    ON
        s.title = m.title
    GROUP BY
        s.genre,
        m.studio,
        release_month
)
	
--STEP 2:  Using subquery, we populate the studio and release month for each genre which will help us indicates the month and the studio for each genre.
--We rank them by profit and order them by profit in descending order to have an overview of ranking from highest to lowest profitable genres.

SELECT
    genre,
    studio,
    release_month,
    profit
FROM (
    SELECT
        genre,
        studio,
        release_month,
        profit,
        RANK() OVER (PARTITION BY genre ORDER BY profit DESC) AS genre_ranking
    FROM
        movies_profit
) ranking --name of the subquery
WHERE
    genre_ranking = 1 -- We specify the ranking criteria for the selection.
ORDER BY
    profit DESC;
	
--Next step: Using Python encapsulation for further analysis.
	

--To run this code to preview the reseaarch table stored in the temporary table.
SELECT * FROM studio_genre


--We analyse what is the relationship between movie sales measured by box office collection 
--to that of the average idvscore for user review and expert review

--Step 1: We calculate the top 100 movies with highest box_office collection compared to their average idvscore from user review & expert review tables


-- Creating a temporary table to store the query result so we can use the table in Python encapsulation for further analysis
CREATE TEMP TABLE boxoffice_reputation AS
--Calculating the average idvscore for the 2 reviews tables separately and order them by 100 highest performing movies by sales
WITH Top100HighestBoxOffice AS (
	SELECT
    s.title AS movie_name, 
    AVG(CAST(ur.idvscore AS NUMERIC)) AS "avg_user_review_idv_score",   --Calculate the average idvscore per movie from user review table
    AVG(CAST(er.idvscore AS NUMERIC)) AS "avg_expert_review_idv_score"  --Calculate the average idvscore per movie from expert review table
FROM
    movie AS m
JOIN
    user_review AS ur ON m.url = ur.url
JOIN
    expert_review AS er ON m.url = er.url
JOIN
    sales AS s ON m.title = s.title
GROUP BY
    s.title
ORDER BY
    MAX(CAST(s.box_office AS NUMERIC)) DESC  -- Ordering by the highest box_office to see result in descending order
LIMIT
    100
),	


--Step 2: We calculate the top 100 movies with lowest box_office collection compared to their average idvscore from user review & expert review tables

--Calculating the average idvscore for the 2 reviews tables separately and order them by 100 lowest performing movies with sales higher than 0
Top100LowestBoxOffice AS ( 
	SELECT
    s.title AS movie_name, 
    AVG(CAST(ur.idvscore AS NUMERIC)) AS "avg_user_review_idv_score",   --- Calculate the average idv score per movie from user review table
    AVG(CAST(er.idvscore AS NUMERIC)) AS "avg_expert_review_idv_score"  --- Calculate the average idv score per movie from expert review table
FROM
    movie AS m
JOIN
    user_review AS ur ON m.url = ur.url
JOIN
    expert_review AS er ON m.url = er.url
JOIN
    sales AS s ON m.title = s.title
WHERE CAST(s.box_office AS NUMERIC) > 0  -- Specifying that we only need data for movies that have revenue higher than 0
GROUP BY
    s.title
ORDER BY
    MIN(CAST(s.box_office AS NUMERIC)) ASC
LIMIT
    100
),


--Step 3: Creating a combined result table that gives average of idvscores for top & bottom 100 movies based on box_office

CombinedResults AS (
    SELECT 'Top100HighestBoxOffice' AS BoxOffice,     --Selecting top 100 table with columns to be included to calculate the overall average user & expert score
           movie_name,
           avg_user_review_idv_score,
           avg_expert_review_idv_score
    FROM Top100HighestBoxOffice
    UNION ALL
    SELECT 'Top100LowestBoxOffice' AS BoxOffice,      --Selecting bottom 100 table with columns to be included to calculate the overall average user & expert score
           movie_name,
           avg_user_review_idv_score,
           avg_expert_review_idv_score
    FROM Top100LowestBoxOffice
)

--Calculate the overall average user and expert review scores
SELECT BoxOffice,
       AVG(avg_user_review_idv_score) AS overall_avg_user_review,
       AVG(avg_expert_review_idv_score) AS overall_avg_expert_review
FROM CombinedResults
GROUP BY BoxOffice
ORDER BY overall_avg_user_review DESC;


--Next step: Using Python for further analysis.


--Run this code to preview the research table stored in in a temporary table.
SELECT * FROM boxoffice_reputation