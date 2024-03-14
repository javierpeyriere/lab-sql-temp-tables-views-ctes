-- Temp tables and views Lab
-- Step 1: Create a View: summarizes rental information for each customer (customer's ID, name, email address, and total number of rentals (rental_count)).
use sakila;
create view rental_info  as
select c.customer_id, count(1) as rental_counts, c.last_name, c.email
from sakila.rental r
inner join sakila.customer c
	using (customer_id)
group by c.customer_id, c.last_name, c.email
;

-- Step 2: Create a Temporary Table that calculates the total amount paid by each customer (total_paid)
-- with rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.
create temporary table total_paid as
select customer_id, rental_info.last_name, rental_info.email , rental_info.rental_counts, sum(amount)
from payment
inner join rental_info
	using (customer_id)
group by customer_id, rental_info.last_name;
select * from total_paid;

-- or 
-- Simpler temporary table in payment
create temporary table total_paidv2 as
select customer_id, sum(amount) as totalv2
from payment
group by customer_id;
-- and joining it with the view
select customer_id, rental_info.last_name, rental_info.email , rental_info.rental_counts, total_paidv2.totalv2
from total_paidv2
inner join rental_info
	using (customer_id)
;
-- 3 Step 3: Create a CTE  that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. 
-- The CTE should include the customer's name, email address, rental count, and total amount paid.
-- Next, using the CTE, create the query to generate the final customer summary report, 
-- which should include: customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.
with cte_payment_and_rent_and_custo as (
select customer_id, rental_info.last_name, rental_info.email , rental_info.rental_counts, total_paidv2.totalv2
from total_paidv2
inner join rental_info
	using (customer_id)
)
-- creating the summary report
select last_name, email, rental_counts, totalv2 as total_paid, concat('$',round(totalv2/rental_counts, 2)) as rental_average_price
from cte_payment_and_rent_and_custo;
    




