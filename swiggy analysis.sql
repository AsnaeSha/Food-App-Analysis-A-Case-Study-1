-- swiggy case study

-- find customers who never ordered
select users.user_id,name,email from users
left join orders on users.user_id = orders.user_id
where orders.user_id is null;

-- another way
select name from users
where user_id not in (select user_id from orders);

-- avg price per dish
select f_name,avg(price) as avg_price from food
join menu on food.f_id = menu.f_id
group by f_name;

-- find top restaurant in terms of orders for a given month
-- assuming the month as june

select r_name,most_orders from
(select monthname(date)as months,r_name,count(user_id)as most_orders from restaurants
join orders on orders.r_id = restaurants.r_id
group by monthname(date),r_name) restaurants
where months like 'june'
order by most_orders desc
limit 1;

-- restaurants with monthly sales > x(any threshold value)
-- lets assume the month as july and x value as 1000
select r_name,total_amount from 
(select r_name,monthname(date) as months, sum(amount)as total_amount from restaurants
join orders on orders.r_id = restaurants.r_id
group by monthname(date),r_name
having total_amount > 1000
)restaurants
where months like 'july';

-- show all orders with order details for a particular customer in a particular date range
select users.user_id,orders.order_id,name,f_name,r_name,amount,date from users
left join orders on users.user_id = orders.user_id
left join order_details on orders.order_id = order_details.order_id
left join food on order_details.f_id = food.f_id
left join restaurants on restaurants.r_id = orders.r_id
where users.name = 'Ankit'
and (date between '2022-06-10'and'2022-07-10');

-- restaurant with the max repeated customers or loyal customers
select restaurants.r_name,count(*) as loyal_customers from
(select orders.r_id,user_id,count(user_id)as cust_count from orders
group by orders.r_id,user_id
having cust_count > 1
order by r_id) orders
join restaurants on restaurants.r_id= orders.r_id
group by restaurants.r_name
order by loyal_customers desc
limit 1;

-- restaurants with max customers
select r_name,count(user_id)as max_customers from orders
join restaurants on orders.r_id = restaurants.r_id
group by r_name
order by max_customers desc
limit 1;

-- month by month revenue of swiggy
select month,total_revenue,prev_month,((total_revenue - prev_month/prev_month) * 100) as growth_rate from 
(select monthname(date) as month ,sum(amount) total_revenue,lag(sum(amount)) over(order by monthname(date) desc) as prev_month from orders
group by monthname(date)) orders;

-- customer fav food item (thats the item which he or she order the most)
select name,f_name from
(select rank() over(partition by name order by no_of_orders desc) as rnk,name,f_name,no_of_orders from 
(select name,f_name, count(f_name)as no_of_orders from users
join orders on users.user_id = orders.user_id
join order_details on orders.order_id = order_details.order_id
join food on order_details.f_id = food.f_id
group by name,f_name
) orders) orders
where rnk = 1;

-- most loyal customer of each restaurant
select r_name,loyal_customer from
(select rank() over(partition by r_name order by count desc) as rnk,r_name,name as loyal_customer,count from
(select r_name,name,count(orders.user_id)as count from orders
join users on orders.user_id = users.user_id
join restaurants on restaurants.r_id = orders.r_id
group by 1,2) orders)orders
where rnk = 1;

-- month over month revenue growth of each restaurant
select r_name,revenue,month,((revenue-prev_month/prev_month) * 100) as growth_rate from
(select r_name,sum(amount)as revenue,monthname(date) as month,lag(sum(amount)) over(order by monthname(date)desc) as prev_month from orders
join restaurants on restaurants.r_id = orders.r_id
group by r_name,monthname(date))orders
where month like 'July';

-- most ordered paired products

select f1.f_name as pair1,f2.f_name as pair2, count(*) as order_count from order_details o1
join order_details o2 on o1.order_id = o2.order_id and o1.f_id < o2.f_id
join food f1 on o1.f_id = f1.f_id
join food f2 on o2.f_id = f2.f_id
group by 1,2
order by order_count desc
limit 1