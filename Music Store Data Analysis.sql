use sql_project;
SELECT * FROM sql_project.employee;

# PROJECT PHASE 1

# 1. Who is the senior most employee based on job title?

SELECT first_name,last_name,title,hire_date
FROM employee
WHERE (title,hire_date) IN (SELECT title,MIN(hire_date) 
                           FROM  employee 
                           GROUP BY title
						   );
# BY senior most employee levels

SELECT title, last_name, first_name 
FROM employee
ORDER BY levels DESC
LIMIT 1;





# 2. Which countries have the most Invoices?

SELECT * FROM sql_project.invoice;

SELECT billing_country,COUNT(billing_country) AS top_bill_country
FROM invoice
GROUP BY billing_country
ORDER BY billing_country DESC;

# 3. What are top 3 values of total invoice? 

SELECT total 
FROM invoice
ORDER BY total DESC
LIMIT 3;

# 4.  Which city has the best customers? We would like to throw a promotional Music Festival 
#     in the city we made the most money. Write a query that returns one city that has the highest
#     sum of invoice totals. Return both the city name & sum of all invoice totals.

SELECT billing_city AS city,ROUND(SUM(total),3) AS total_invoice
FROM invoice
GROUP BY billing_city
ORDER BY SUM(total) DESC
LIMIT 1;

# 5. Who is the best customer? The customer who has spent 
#    the most money will be declared the best customer. 
#    Write a query that returns the person who has spent the most money.

SELECT * FROM sql_project.invoice;
SELECT * FROM sql_project.customer;

SELECT cu.customer_id,cu.first_name,cu.last_name,ROUND(sum(inv.total),2) AS total_sum
FROM customer AS cu
INNER  JOIN invoice AS inv
ON cu.customer_id = inv.customer_id
GROUP BY cu.customer_id,cu.first_name,cu.last_name
ORDER BY sum(inv.total) DESC
LIMIT 1;


# Project Phase II

#  1. Write query to return the email, first name, last name,
#  & Genre of all Rock Music listeners. Return your 
#  list ordered alphabetically by email starting with A 

SELECT cu.first_name,cu.last_name,cu.email,ge.name AS genre_name
FROM customer AS cu
INNER JOIN invoice AS inv
ON cu.customer_id = inv.customer_id
INNER JOIN invoice_line AS inv_li
ON inv.invoice_id = inv_li.invoice_id
INNER JOIN track AS tr
ON inv_li.track_id = tr.track_id
INNER JOIN genre AS ge
ON tr.genre_id = ge.genre_id
WHERE ge.name = 'Rock'
GROUP BY cu.first_name,cu.last_name,cu.email
ORDER BY cu.email;



# 2. Let's invite the artists who have written the most rock music 
# in our dataset. Write a query that returns the Artist 
# name and total track count of the top 10 rock band

SELECT ar.name,COUNT(ar.artist_id) AS TOTAL_COUNT
FROM artist AS ar
JOIN album AS al
ON ar.artist_id = al.artist_id
JOIN track AS tr
ON al.album_id = tr.album_id
JOIN genre AS ge
ON tr.genre_id = ge.genre_id
WHERE ge.name = 'Rock'
GROUP BY ar.name,ar.artist_id
ORDER BY TOTAL_COUNT DESC
LIMIT 10; 



# 3. Return all the track names that have a song length longer than the average song length.
#  Return the Name and Milliseconds for each track. 
# Order by the song length with the longest songs listed first


SELECT * FROM sql_project.track;


SELECT name,milliseconds AS Song_length
FROM track
WHERE milliseconds > (SELECT AVG(milliseconds) AS AVG_LENGTH
                      FROM track)
ORDER BY milliseconds DESC;


# PROJECT PHASE 3

# 1.Find how much amount spent by each customer on artists?
# Write a query to return customer name, artist name and total spent.

SELECT CONCAT(c.first_name,' ',c.last_name) AS Customer_name , ar.name AS Artist_name , SUM(il.unit_price * il.quantity) AS Total_spent
FROM customer c LEFT JOIN invoice i ON c.customer_id = i.customer_id
INNER JOIN invoice_line il ON i.invoice_id = il.invoice_id
INNER JOIN track t ON il.track_id = t.track_id
INNER JOIN album al ON t.album_id = al.album_id
INNER JOIN artist ar ON al.artist_id = ar.artist_id
GROUP BY 1 , 2
ORDER BY 1;

# 2. We want to find out the most popular music Genre for each country. 
# We determine the most popular genre as the genre with the highest amount of purchases. 
# Write a query that returns each country along with the top Genre. 
# For countries where the maximum number of purchases is shared return all Genres



WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1;



# 3. Write a query that determines the customer that has spent 
# the most on music for each country. Write a query that returns the
# country along with the top customer and how much they spent. 
# For countries where the top amount spent is shared, provide all customers who spent this amount.

WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1
