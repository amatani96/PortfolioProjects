-- The dataset these queries are referencing was obtained from Kaggle at the following URL: https://www.kaggle.com/datasets/asaniczka/tmdb-movies-dataset-2023-930k-movies/data
-- All findings are correct as of 07/01/2025

-- Displaying all information on the table ordered ascending by ID, some IDs are missing in the original dataset (hense why content with IDs 1 and 4 are missing for example

SELECT * FROM TMDBPortfolioProject.dbo.TMDB_movie_dataset_v11
ORDER BY id

-- Displaying the top 25 released films with the longest runtimes, many of these movies are likely compilations of multiple films
SELECT TOP 25 title, release_date, runtime
FROM TMDB_movie_dataset_v11
ORDER BY runtime DESC

-- Displaying the top 25 released films with the shortest runtimes, these movies likely all contain incorrect or missing runtime information
SELECT TOP 25 title, release_date, runtime
FROM TMDB_movie_dataset_v11
ORDER BY runtime

-- Displaying the top 25 shortest films that are 1 minute long or more, these films are more likely to be films with accurate information that are simply very short
SELECT TOP 25 title, release_date, runtime
FROM TMDB_movie_dataset_v11
WHERE runtime >= '1'
ORDER BY runtime

-- There may be more films that are 1 minute, since all of the top 25 films of 1 minute or more are 1 minute. So to more accurately show the shortest films, to the extent that
-- possible with this dataset, I will simply show all the films with a runtime of 1 minute
SELECT title, release_date, runtime
FROM TMDB_movie_dataset_v11
WHERE runtime = '1'
ORDER BY runtime

-- This is the count of how many 1 minute films there are on TMDB, there are a lot of them!

SELECT COUNT(title) AS number_of_1_minute_films
FROM TMDB_movie_dataset_v11
WHERE runtime = '1'



-- Displaying all films with no spoken languages (a.k.a silent films) ordered vote average descending

SELECT title, genres, release_date, vote_average, vote_count
FROM TMDB_movie_dataset_v11
WHERE spoken_languages LIKE 'No Language'
ORDER BY vote_average DESC

-- Many of these silent films with ratings of 10 have very small vote counts (many even being only 1) which may not have vote averages which would accurately represent 
-- the average opinions of the general population. So here are the results but only showing silent films with a vote count over 100

SELECT title, genres, release_date, vote_average, vote_count
FROM TMDB_movie_dataset_v11
WHERE spoken_languages LIKE 'No Language' AND vote_count > 100
ORDER BY vote_average DESC

-- Now I will display all the lowest rated silent films, again with vote counts over 100
SELECT title, genres, release_date, vote_average, vote_count
FROM TMDB_movie_dataset_v11
WHERE spoken_languages LIKE 'No Language' AND vote_count > 100
ORDER BY vote_average



-- Displaying which genres on average have the highest budgets

SELECT genres, AVG(CAST(budget AS BIGINT)) AS average_budget, COUNT(title) AS content_count
FROM TMDB_movie_dataset_v11
GROUP BY genres
ORDER BY average_budget DESC

-- Since there are many films that have differing combinations of multiple genres it is hard to narrow down which genres genreally have higher budgets,
-- we could however view genre combinations with larger content counts with high budgets. It's not a perfect solution but could give us an idea of what
-- some popular genre combinations shown on TMDB. From this query we can see that many of the films with a high average budget are Action, Adventure, Sci-Fi films.

SELECT genres, AVG(CAST(budget AS BIGINT)) AS average_budget, COUNT(title) AS content_count
FROM TMDB_movie_dataset_v11
GROUP BY genres
HAVING COUNT(title) > 10
ORDER BY average_budget DESC

-- To further validate the findings above, we'll see which genres the highest budget films fall under, we'll also remove NULL genres. From these results we can see
-- that the Action, Adventure, Sci-fi combination appeared regularly in the previous query due to most of the Avatar films, and many DC and Marvel films being listed
-- under these genres

SELECT TOP(25) title, budget, genres, release_date
FROM TMDB_movie_dataset_v11
WHERE genres IS NOT NULL
ORDER BY budget DESC

-- Some of the films in the above query are unreleased, here is the above query but only showing films that are currently released. We will also remove
-- the content with a NULL release_date

SELECT TOP(25) title, budget, genres, release_date, status, spoken_languages
FROM TMDB_movie_dataset_v11
WHERE genres IS NOT NULL AND release_date IS NOT NULL AND status LIKE 'released'
ORDER BY budget DESC

-- I also included spoken languages in the query above to show that most of these films have "English" as a spoken language. Here are the highest budget films
-- which don't have english as a spoken language. I will also omit NULL spoken_languages.

SELECT TOP(25) title, budget, genres, release_date, spoken_languages
FROM TMDB_movie_dataset_v11
WHERE spoken_languages NOT LIKE '%English%'
ORDER BY budget DESC

-- Moving away from languages, here are films that made the highest return in revenue over their budget
SELECT TOP(25) title, release_date, budget, revenue, revenue/budget*100 AS profit_percentage, vote_count
FROM TMDB_movie_dataset_v11
WHERE revenue > 0 AND budget > 0
ORDER BY revenue/budget*100 DESC

-- I added vote count in to the previous query to show that these results are likely not accurate, since films with such high revenue will likely have more
-- vote counts on TMDB. Here are the results with a vote count above 100. This list seems more accurate, with it containing well known low budget successes such as
-- "The Blair Witch Project", "The Texas Chainsaw Massacre" and "Mad Max".

SELECT TOP(25) title, release_date, budget, revenue, revenue/budget*100 AS profit_percentage, vote_count
FROM TMDB_movie_dataset_v11
WHERE revenue > 0 AND budget > 0 AND vote_count > 100
ORDER BY revenue/budget*100 DESC



-- Dispaying the most anticipated unreleased movie based on its TMDB popularity rating. Unfortunately we can see a limitation of this dataset,
-- some of the statuses of the content have not been updated and are not showing as 'released' even though they are already released.

SELECT TOP(25) title, release_date, status, popularity
FROM TMDB_movie_dataset_v11
WHERE status NOT LIKE 'released'
ORDER BY popularity DESC

-- I will remedy this limitation by showing content with a release date past the current date and omitting NULL values under 'release_date'
SELECT TOP(25) title, release_date, status, popularity
FROM TMDB_movie_dataset_v11
WHERE release_date > CURRENT_TIMESTAMP
ORDER BY popularity DESC