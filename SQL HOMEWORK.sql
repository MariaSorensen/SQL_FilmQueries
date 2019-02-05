USE sakila;

-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name
FROM actor;

-- 1b. Display the first and last name of each actor in a single column in 
-- upper case letters. Name the column `Actor Name`.

-- Turn safe updates on
SET SQL_SAFE_UPDATES = 0;
 
ALTER TABLE actor
ADD COLUMN Actor_Name VARCHAR(50);

UPDATE actor
SET Actor_Name = CONCAT(first_name, ' ', last_name);

SELECT *
FROM actor;

-- 2a. You need to find the ID number, first name, and last name 
-- of an actor, of whom you know only the first name, "Joe." 
-- What is one query you would use to obtain this information?

SELECT actor_id, Actor_Name 
FROM actor 
WHERE first_name = 'JOE';

-- 2b. Find all actors whose last name contain the letters `GEN`:

SELECT Actor_Name 
FROM actor 
WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names 
-- contain the letters `LI`. This time, order the rows by last name and first name, in that order:

SELECT first_name, last_name
FROM actor 
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;

-- 2d. Using `IN`, display the `country_id` and `country` columns 
-- of the following countries: Afghanistan, Bangladesh, and China:

SELECT country_id, country 
FROM country 
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. keep a description of each actor in a column in the table `actor` named `description` 
-- data type `BLOB` 

ALTER TABLE actor
ADD COLUMN description BLOB;

-- 3b. Delete the `description` column.

ALTER TABLE actor
DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(*) AS num
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors

SELECT last_name, COUNT(*) 
FROM actor
GROUP BY last_name
HAVING COUNT(*) >= 2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. 
-- Write a query to fix the record.

UPDATE actor
SET Actor_Name = 'HARPO WILLIAMS'
WHERE Actor_Name = 'GROUCHO WILLIAMS';

-- check to make sure the change is there.
SELECT Actor_Name
FROM actor
WHERE Actor_Name LIKE '%WILLIAMS%';

-- 4d. It turns out that `GROUCHO` was the correct name after all! 
-- In a single query, change it back to `GROUCHO`.

UPDATE actor
SET Actor_Name = 'GROUCHO WILLIAMS'
WHERE Actor_Name = 'HARPO WILLIAMS';

-- check to make sure the change is there.
SELECT Actor_Name
FROM actor
WHERE Actor_Name LIKE '%WILLIAMS%';

-- 5a. You cannot locate the schema of the `address` table. 
-- Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- 6a. Use `JOIN` to display the first and last names, 
-- as well as the address, of each staff member. 
-- Use the tables `staff` and `address`

SELECT first_name, last_name, address
FROM staff
JOIN address ON
staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount
-- rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT *
FROM payment;

SELECT first_name, last_name, SUM(amount) AS 'total_amount'
FROM staff
JOIN payment ON
staff.staff_id = payment.staff_id
GROUP BY payment.staff_id;

--  6c. List each film and the number of actors who are listed for that film. 
--  Use tables film_actor and film. Use inner join.
SELECT*
FROM film_actor;

SELECT title, COUNT(film_actor.actor_id) AS Num_of_Actors
FROM film
INNER JOIN film_actor ON
film.film_id = film_actor.film_id
GROUP BY film_actor.actor_id;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system
SELECT title, COUNT(TITLE) AS copies
FROM film
JOIN inventory ON 
film.film_id = inventory.film_id
WHERE title = 'Hunchback Impossible';

-- 6e. Using the tables payment and customer and the JOIN command, 
--  list the total paid by each customer. List the customers alphabetically by last name:

SELECT first_name, last_name, SUM(payment.amount) AS 'Total_amount_paid'
FROM customer
JOIN payment ON
customer.customer_id = payment.customer_id
GROUP BY payment.customer_id
ORDER BY customer.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English

SELECT title, (SELECT name FROM language WHERE film.language_id = language.language_id) AS 'Name_of_language'
FROM film
WHERE title LIKE "K%" OR title LIKE "Q%" AND 'Name_of_language' = 'English';

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN 
(
	SELECT actor_id
    FROM film_actor
    WHERE film_id IN 
    (
		SELECT film_id
        FROM film
        WHERE title = 'Alone Trip'
	)	
);

-- 7c. You want to run an email marketing campaign in Canada, 
-- for which you will need the names and email addresses of all Canadian customers. 
-- ****Use joins to retrieve this information.

SELECT first_name, last_name, email
FROM customer
JOIN address ON customer.address_id=address.address_id
JOIN city ON address.city_id=city.city_id
JOIN country ON city.country_id=country.country_id
WHERE country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target 
-- all family movies for a promotion. 
-- Identify all movies categorized as family films.

SELECT title AS Family_Movies
FROM film_list
WHERE category = 'Family';

-- 7e. Display the most frequently rented movies in descending order.
-- film, inventory, rental

SELECT title, count(rental.rental_id) AS 'Freq_rented'
FROM film
JOIN inventory ON film.film_id = inventory.film_id
JOIN rental ON inventory.inventory_id = rental.inventory_id
GROUP BY title
ORDER BY 'Freq_rented' DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT store, total_sales
FROM sales_by_store;

-- 7g. Write a query to display for each store its store ID, city, and country.
-- STORE, address, city, country
SELECT store_id, city.city, country.country
FROM store
JOIN address ON address.address_id = store.address_id
JOIN city ON city.city_id = address.city_id
JOIN country ON country.country_id = city.country_id;

-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT name AS genres, SUM(payment.amount) AS 'gross revenue'
FROM category
JOIN film_category ON film_category.category_id = category.category_id
JOIN inventory ON inventory.film_id = film_category.film_id
JOIN rental ON rental.inventory_id = inventory.inventory_id
JOIN payment ON payment.rental_id = rental.rental_id
GROUP BY category.name
ORDER BY 'gross revenue' DESC
LIMIT 5;


-- 8a. In your new role as an executive, you would like to have an easy way of viewing the 
-- Top five genres by gross revenue. Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view.


CREATE VIEW top_five_genres AS SELECT name AS genres, SUM(payment.amount) AS gross_revenue
FROM category
JOIN film_category ON film_category.category_id = category.category_id
JOIN inventory ON inventory.film_id = film_category.film_id
JOIN rental ON rental.inventory_id = inventory.inventory_id
JOIN payment ON payment.rental_id = rental.rental_id
GROUP BY category.name
ORDER BY 'gross revenue' DESC
LIMIT 5;


-- 8b. How would you display the view that you created in 8a? select * from view in 8a.

SELECT *
FROM top_five_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

DROP VIEW top_five_genres;