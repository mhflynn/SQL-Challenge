use sakila;

show tables;

# 1a : Display the first and last names of all actors from the table `actor`.
select first_name, last_name from actor;

# 1b : Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
select upper(concat(first_name, " ", last_name)) as "Actor Name" from actor;

# 2a : You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe". 
#        What is one query would you use to obtain this information?
select actor_id, first_name, last_name from actor where first_name="Joe";

# 2b : Find all actors whose last name contain the letters `GEN`.
select first_name, last_name from actor where last_name like '%GEN%';

# 2c : Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order
select last_name, first_name from actor where last_name like '%LI%' order by last_name, first_name;

# 2d : Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China
select country_id, country from country where country in ('Afghanistan', 'Bangladesh', 'China');

# 3a : You want to keep a description of each actor. Create a column in the table `actor` named `description` and use the data type `BLOB`.
show create table actor;
alter table actor add column description BLOB NOT NULL;
alter table actor drop description;

# 4a : List the last names of actors, as well as how many actors have that last name
select last_name, count(*) from actor group by last_name;

# 4b : List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors.
# Note : Used query from #4a as sub-query to get 2 columns : last_name, count, as input to query to select rows with count > 1.
select * from (select last_name, count(*) as count from actor group by last_name)  as da where count>1;

# 4c : The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
update actor set first_name='HARPO' where first_name='GROUCHO' and last_name='WILLIAMS';

# 4d : Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! 
#        In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
#
# Note : As there could be other actors with first name HARPO, I used first and last name to qualify the query. 
#            For this specific case there was only one row with first name HARPO after update in #4c.
update actor set first_name='GROUCHO' where first_name='HARPO' and last_name='WILLIAMS';

# 5a : You cannot locate the schema of the `address` table. Which query would you use to re-create it?
SHOW CREATE TABLE address;
# Note : Result of the above query below.
/* 'CREATE TABLE `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8' */


# 6a : Use `JOIN` to display the first and last names, and address, of each staff member, using the tables `staff` and `address`.
# Notes : Since staff members names is of primary interest, use a left join to retreive full list of names and addresses if available.

select  s.first_name, s.last_name, a.address
    from staff as s 
	left join address as a
    on s.address_id=a.address_id;

# 6b : Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
# Notes : Filtered the payment table for transactions in month of August first, then performed an inner join with staff table.
#             A "full" join of payment table and staff, with fillter for month of August also works, but sub-query reduces the number of 
#             rows input to the join.
select s.first_name, s.last_name, sum(p.amount) as sales 
   from (select * from payment where payment_date between '2005-08-01' and '2005-09-01' ) as p
   join staff as s 
   on p.staff_id=s.staff_id 
   group by s.staff_id;
   
# 6b : Without sub-query.
select s.first_name, s.last_name, sum(p.amount) as sales 
   from payment as p
   join staff as s 
   on p.staff_id=s.staff_id 
   where payment_date between '2005-08-01' and '2005-09-01' 
   group by s.staff_id;
   
   
# 6c : List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
select f.title as 'Film Title', count(*) as 'Actor Count' from film_actor as fa join film as f on f.film_id=fa.film_id group by f.title;

# 6d : How many copies of the film `Hunchback Impossible` exist in the inventory system?
# Notes : Used a sub-query to get film_id for film 'Hunchback Impossible' to query inventory for that single film_id.
select count(*) as 'Inventory count' from inventory where film_id = (select film_id from film where title = 'Hunchback Impossible');

# 6e : Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. 
#        List the customers alphabetically by last name.
# Notes : Used sub-query to get initial payment total by Customer ID, then join with Customer table.
select c.last_name, c.first_name, p.amount as "Total Amount Paid"
    from customer as c 
    left join (select customer_id, sum(amount) as amount from payment group by customer_id) as p 
    on c.customer_id=p.customer_id 
    order by last_name;

# 7a : The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
#        As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. 
#        Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
select title as 'K/Q Titles in English'
   from film 
   where (title like 'K%' or title like 'Q%') 
   and language_id = (select language_id from language where name='English');

# 7b : Use subqueries to display all actors who appear in the film `Alone Trip`.
select last_name, first_name from actor 
    where actor_id in 
        (select actor_id from film_actor where film_id = 
                 (select film_id from film where title = "Alone Trip"));

# 7c : You want to run an email marketing campaign in Canada, 
#        for which you will need the names and email addresses of all Canadian customers. 
#        Use joins to retrieve this information.
select first_name, last_name, email
    from customer as cus
    join address as a
         on cus.address_id=a.address_id
	join city as cty
         on a.city_id=cty.city_id
    join country as ctry
         on cty.country_id=ctry.country_id
    where country="Canada";

# 7d : Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
#        Identify all movies categorized as _family_ films.
select title as family_film_title 
    from film as f
    join film_category as fc
    on f.film_id=fc.film_id
    where category_id=(select category_id from category where name="Family");
    
# 7e : Display the most frequently rented movies in descending order.
select f.title as film_title, ri.rental_count
    from (select film_id, count(*) as rental_count
	          from rental as r 
	    	  join inventory as i 
              on r.inventory_id=i.inventory_id
              group by film_id) as ri
    join film as f
    on ri.film_id=f.film_id
    order by rental_count desc;
    
# 7f : Write a query to display how much business, in dollars, each store brought in.
select store_id as store, sum(amount) as store_total_amount
    from (select inventory_id, sum(amount) as amount
                 from rental as r
                 join payment as p
                 on r.rental_id=p.rental_id
                 group by inventory_id) as s
	join inventory as i
    on s.inventory_id=i.inventory_id
    group by store;

# 7g : Write a query to display for each store its store ID, city, and country.
select s.store_id as store, c.city, cy.country
    from store as s
    join address as a
        on s.address_id=a.address_id
	join city as c
        on a.city_id=c.city_id
	join country as cy
        on c.country_id=cy.country_id;
    
# 7h : List the top five genres in gross revenue in descending order. 
select c.name as genre, sum(s.amount) as genre_revenue
    from (select inventory_id, sum(amount) as amount
                 from rental as r
                 join payment as p
                 on r.rental_id=p.rental_id
                 group by inventory_id) as s
	join inventory as i 
        on s.inventory_id=i.inventory_id
	join film_category as f
        on i.film_id=f.film_id
	join category as c
        on f.category_id=c.category_id
	group by genre
    order by genre_revenue desc
    limit 5;
    
# 8a : Use the solution from 7h to create a view. 
create view top_genre as
  select c.name as genre, sum(s.amount) as genre_revenue
    from (select inventory_id, sum(amount) as amount
                 from rental as r
                 join payment as p
                 on r.rental_id=p.rental_id
                 group by inventory_id) as s
	join inventory as i 
        on s.inventory_id=i.inventory_id
	join film_category as f
        on i.film_id=f.film_id
	join category as c
        on f.category_id=c.category_id
	group by genre
    order by genre_revenue desc
    limit 5;

# 8b : How would you display the view top_genre?
select * from top_genre;

# 8c : Write a query to delete the view top_genre;
drop view top_genre;