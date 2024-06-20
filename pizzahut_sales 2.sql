######Intermediate :::---------

#####:::Q) 1 Join the necessary tables to find the total quantity of each pizza category ordered.
select pizza_types.category,
sum(orders_details.quantity) as quantity
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join orders_details
on orders_details.pizza_id = pizzas.pizza_id
group by pizza_types.category order by quantity desc;



#### ::: Q) 2 Determine the distribution of orders by hour of the day.
select hour(order_time)as time_hour,count(oder_id) as count_id
 from orders
group by hour(order_time);

##### ::: Q) 3 Join relevant tables to find the category-wise distribution of pizzas.
select category, count(name) from pizza_types
group by category;

### ::: Q) 4 Group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(quantity),0) from
(select orders.order_date, sum(orders_details.quantity) as quantity
from orders join orders_details
on orders.oder_id = orders_details.order_id
group by orders.order_date) as count_quantity;

###::: Q) 5. Determine the top 3 most ordered pizza types based on revenue.
select pizza_types.name,
sum(orders_details.quantity * pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join orders_details
on orders_details.pizza_id = pizzas.pizza_id
group by pizza_types.name order by revenue desc limit 3;



############Advanced:::::

####Q).1 Calculate the percentage contribution of each pizza type to total revenue.
select pizza_types.category,
round(sum(orders_details.quantity*pizzas.price)/(SELECT 
    ROUND(SUM(orders_details.quantity * pizzas.price),
            2) AS pizza_sales
FROM
    orders_details
        JOIN
    pizzas ON pizzas.pizza_id = orders_details.pizza_id)*100,2) as revenue

from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join orders_details
on orders_details.pizza_id = pizzas.pizza_id
group by pizza_types.category order by revenue ;


####Q)2 Analyze the cumulative revenue generated over time.

SELECT order_date,
       SUM(revenue) OVER (ORDER BY order_date) AS cum_revenue
FROM (
    SELECT orders.order_date,
           SUM(orders_details.quantity * pizzas.price) AS revenue
    FROM orders_details
    JOIN pizzas ON orders_details.pizza_id = pizzas.pizza_id
    JOIN orders ON orders.oder_id = orders_details.order_id
    GROUP BY orders.order_date
) AS sale;


###Q).3 Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name, revenue
from
(select category, name, revenue,
rank() over(partition by category order by revenue desc) as rn
from
(select pizza_types.category,pizza_types.name,
sum((orders_details.quantity) * pizzas.price)as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join orders_details
on orders_details.pizza_id = pizzas.pizza_id
group by pizza_types.category,pizza_types.name) as a) as b
where rn <=3;
