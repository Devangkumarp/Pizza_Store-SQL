create database pizzastore;

use pizzastore;

show databases;

#Q1 Import Data from the .CSV files.

select * from order_details;

select * from orders;

select * from pizza_types;

select * from pizzas;

#Q2 Retrived the total number order placed.

select count(*) as Total_Orders from orders;

#Q3 Calculate the total revenue generated from pizza sales.

select
	sum(o.quantity * p.price) as Tatal_revenue
from
	order_details o
inner join 
pizzas p 
on
	o.pizza_id = p.pizza_id;

#Q4 Identify the highest priced pizza.

select
	pt.name,
	max(p.price) as max_price
from
	pizza_types pt
inner join
pizzas p
on
	pt.pizza_type_id = p.pizza_type_id
group by
	pt.name
order by
	max_price desc
limit 1;

#Q5 Identify the most common pizza ordered.

select
	P.pizza_type_id,
	count(od.quantity) as Total_quantity
from
	order_details od
inner join
pizzas p
on
	od.pizza_id = p.pizza_id
group by
	p.pizza_type_id
order by
	Total_quantity desc;

#Q6 Identify the most common pizza ordered.

select
	p.size ,
	count(od.order_id) as Total_ordered
from
	order_details od
inner join
pizzas p
on
	od.pizza_id = p.pizza_id
group by
	p.size
order by
	Total_ordered desc
limit 1;


#Q7 List the top 5 most ordered pizza types along with there quantity.

select
	pt.name,
	sum(od.quantity) as Total_Ordered
from
	pizza_types pt
inner join
pizzas p on
	pt.pizza_type_id = p.pizza_type_id
inner join 
order_details od
on
	od.pizza_id = p.pizza_id
group by
	pt.name
order by
	Total_Ordered desc
limit 5;

#Q7 Join the necessary tables to find the total quantity of each pizza orders.

select
	pt.name,
	SUM(od.quantity) Total_ordered
from
	pizza_types pt
inner join
pizzas p 
on
	pt.pizza_type_id = P.pizza_type_id
inner join 
order_details od 
on
	od.pizza_id = p.pizza_id
group by
	pt.name
order by
	Total_ordered desc;

#Q8 Join the necessary tables to find the total quantity of each pizza categeory.

select
	pt.category,
	sum(od.quantity) as Total_Quantity
from
	pizza_types pt
inner join pizzas p 
on
	pt.pizza_type_id = p.pizza_type_id
inner join 
order_details od 
on
	od.pizza_id = p.pizza_id
group by
	pt.category
order by
	Total_Quantity desc;

#Q9 Determine the distribution of orderes by hours of the day.

select
	hour(time),
	count(order_id) as total_orderd
from
	orders
group by
	hour(time);

#Q10 Join relevent tables to find the categeory wise distribution of pizzas.

select
	category,
	count(*)
from
	pizza_types
group by
	category;

#Q11 Group the orderes by date and calculate the average number of pizzas ordered per day.

select
	o.date,
	sum(od.quantity) as Total
from
	orders o
inner join 
order_details od
on
	o.order_id = od.order_id
group by
	o.date;

#Q12 Determined the top 3 most ordered pizza types based on revenue.

select
	pt.name,
	sum(od.quantity * p.price) as Revenue
from
	pizzas p
inner join
pizza_types pt 
on
	p.pizza_type_id = pt.pizza_type_id
inner join 
order_details od
on
	od.pizza_id = p.pizza_id
group by
	pt.name
order by
	Revenue desc
limit 3;

#Q13 Calculate the percentage contribution of each pizza type to revenue.

select
	pt.category,
	(sum(od.quantity * p.price) / (
	select
		sum(od.quantity * p.price) as total_sales
	from
		order_details od
	join pizzas p on
		od.pizza_id = p.pizza_id))* 100 
as revenue
from
	pizza_types pt
join
pizzas p 
on
	pt.pizza_type_id = p.pizza_type_id
inner join
order_details od
on
	od.pizza_id = p.pizza_id
group by
	pt.category
order by
	revenue desc;

#Q14 Analyse the cumalative revenue generated over time.

select
	date,
	sum(Revenue) over (
	order by date) as cumalative_Rev
from
	(
	select
		o.date,
		sum(od.quantity * p.price) as Revenue
	from
		orders o
	inner join
order_details od 
on
		o.order_id = od.order_id
	inner join
pizzas p 
on
		p.pizza_id = od.pizza_id
	group by
		o.date) as sales;

#Q15 Determine the top 3 most pizzatype based on revenue for each pizza category.

select
	category,
	name,
	Revenue
from
	(
	select
		category,
		name,
		Revenue,
		rank() over (partition by category
	order by
		Revenue desc) as Rn
	from
		(
		select
			pt.name,
			pt.category,
			round(sum(od.quantity * p.price), 2) as Revenue
		from
			pizza_types pt
		inner join
pizzas p
on
			pt.pizza_type_id = p.pizza_type_id
		inner join
order_details od
on
			od.pizza_id = p.pizza_id
		group by
			pt.name,
			pt.category) as a)as b
where
	Rn <= 3;