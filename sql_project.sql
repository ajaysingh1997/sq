/* 1: Who is the senior most employee based on job title? */

SELECT title, last_name, first_name 
FROM employee
ORDER BY levels DESC
LIMIT 1


/* 2: Which countries have the most Invoices? */

SELECT COUNT(*) AS c, billing_country 
FROM invoice
GROUP BY billing_country
ORDER BY c DESC


/* 3: What are top 3 values of total invoice? */

SELECT total 
FROM invoice
ORDER BY total DESC


/* 4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

SELECT billing_city,SUM(total) AS InvoiceTotal
FROM invoice
GROUP BY billing_city
ORDER BY InvoiceTotal DESC
LIMIT 1;


/* 5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

SELECT customer.customer_id, first_name, last_name, SUM(total) AS total_spending
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total_spending DESC
LIMIT 1;


/* 6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */



SELECT DISTINCT customer.email,customer.first_name, customer.last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoiceline ON invoice.invoice_id = invoiceline.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY customer.email;

/* 
7. Let's invite the artists who have written the most rock music in our dataset. Write a
query that returns the Artist name and total track count of the top 10 rock bands
*/

select artist.name,count(track.track_id) as total_count from artist
join album on artist.artist_id = album.artist_id
join track on track.album_id = album.album_id
where track.genre_id = 
(select genre.genre_id from track
join genre on track.genre_id = genre.genre_id
where genre.name like 'Rock'
limit 1)
group by artist.name
order by total_count desc
limit 10;


/* 8. Return all the track names that have a song length longer than the average song length.
Return the Name and Milliseconds for each track. Order by the song length with the
longest songs listed first */

select name from track
where milliseconds > (select avg(milliseconds) as avg_length from track)
order by milliseconds desc;

/* 9. Find how much amount spent by each customer on artists? Write a query to return
customer name, artist name and total spent 
*/

WITH best_selling AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, 
	SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

/*  10. We want to find out the most popular music Genre for each country. We determine the
most popular genre as the genre with the highest amount of purchases. Write a query
that returns each country along with the top Genre. For countries where the maximum
number of purchases is shared return all Genres
*/
select * from genre;
select * from customer;
select * from track;
select * from invoice;
select * from customer;

with cte as
(select genre.name, genre.genre_id, customer.country ,count(invoice_line.quantity) as total_count,
row_number() over(partition by customer.country order by count(invoice_line.quantity) desc) as rank_wise_count
from genre
join track on track.genre_id = genre.genre_id
join invoice_line on track.track_id = invoice_line.track_id
join invoice on invoice.invoice_id = invoice_line.invoice_id
join customer on customer.customer_id = invoice.customer_id
group by genre.name, genre.genre_id, customer.country 
order by customer.country, total_count desc)
select * from cte where rank_wise_count <= 1;



/* 11.Write a query that determines the customer that has spent the most on music for each
country. Write a query that returns the country along with the top customer and how
much they spent. For countries where the top amount spent is shared, provide all
customers who spent this amount */


-- we want country name, top customer name, and spend money



select * from customer;
select * from invoice;

with cte as
(select concat(customer.first_name, customer.last_name) as full_name, 
invoice.billing_country,
sum(invoice.total) as total_spent,
row_number() over(partition by invoice.billing_country order by sum(invoice.total) desc) as row_no
from customer
join invoice on invoice.customer_id = customer.customer_id
group by full_name, invoice.billing_country
order by invoice.billing_country asc, total_Spent desc)
select * from cte where row_no <= 1;










