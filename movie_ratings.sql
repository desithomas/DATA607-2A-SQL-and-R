-- !preview conn=DBI::dbConnect(RSQLite::SQLite())
 -- Do not use if already connected to database.
    --DROP DATABASE IF EXISTS movie_ratings;
  -- Create the database first; not needed if you are already connected to the database
--CREATE DATABASE movie_ratings; 
    --command to connect to database: \c movie_ratings


--If starting from scratch:
--Create a database named movie_ratings
--Connect to the database
--Load the CSV file (included in this repo: survey_results.csv)


DROP TABLE IF EXISTS ratings;
DROP TABLE IF EXISTS profiles;
DROP TABLE IF EXISTS movies;
DROP TABLE IF EXISTS accounts;
DROP TABLE IF EXISTS staging_ratings;




 --This is the staging table. No PRIMARY KEY goes here
  account_id INT,
  profile_name TEXT,
  movie_title TEXT,
  rating INT
);
  
-- Part of the normalized database schema; note that each table can only have one PRIMARY KEY
CREATE TABLE accounts(
  account_id INT PRIMARY KEY
); 

CREATE TABLE profiles (
  profile_id SERIAL PRIMARY KEY,
  account_id INT REFERENCES accounts(account_id), 
  profile_name TEXT
);

--use a FOREIGN KEY here instead of a PRIMARY KEY
CREATE TABLE movies (
  movie_id SERIAL PRIMARY KEY,
  title TEXT
);

CREATE TABLE ratings (
  rating_id SERIAL PRIMARY KEY, 
  profile_id INT REFERENCES profiles(profile_id), 
  movie_id INT REFERENCES movies(movie_id),
  rating INT
);

--Table population starts here


--Loading accounts
INSERT INTO accounts (account_id)
SELECT DISTINCT account_id 
FROM staging_ratings;


--Loading movies 
INSERT INTO movies (title) 
SELECT DISTINCT movie_title 
FROM staging_ratings;

-- Loading profiles
INSERT INTO profiles (account_id, profile_name)
SELECT DISTINCT account_id, profile_name
FROM staging_ratings;

--Loading ratings
INSERT INTO ratings (profile_id, movie_id, rating)
SELECT profiles.profile_id, movies.movie_id, staging_ratings.rating
FROM staging_ratings
JOIN movies ON staging_ratings.movie_title = movies.title
JOIN profiles ON staging_ratings.account_id = profiles.account_id AND staging_ratings.profile_name = profiles.profile_name;


--This is to check that the NULLS are actually there and I still have movies that were not rated 
SELECT * FROM ratings WHERE rating IS NULL LIMIT 5;


