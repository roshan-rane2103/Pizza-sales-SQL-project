-- (1)Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;
    
    -- (2)Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(p.price * od.quantity), 2) AS total_revenue
FROM
    pizzas p
        INNER JOIN
    order_details od ON p.pizza_id = od.pizza_id;
    
    --(3) Identify the highest-priced pizza.

SELECT 
    pt.name, p.price
FROM
    pizza_types pt
        INNER JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
ORDER BY price DESC
LIMIT 1;


--(4) Identify the most common pizza size ordered.

SELECT 
    p.size, COUNT(od.order_details_id) AS order_count
FROM
    pizzas p
        INNER JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY order_count DESC;

-- (5)List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pt.name, SUM(od.quantity) AS total_quantity
FROM
    pizza_types pt
        INNER JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        INNER JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.name
ORDER BY total_quantity DESC
LIMIT 5;


-- (6)Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pt.category, SUM(od.quantity) AS total_quantity
FROM
    pizza_types pt
        INNER JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        INNER JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.category
ORDER BY total_quantity DESC;


--(7) Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY hour;

--(8) Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(quantity), 0) AS avg_pizza_ordered_per_day
FROM
    (SELECT 
        o.order_date, SUM(od.quantity) AS quantity
    FROM
        orders o
    INNER JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.order_date) AS order_quantity;
    
    --(9) Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    pt.category, COUNT(pt.pizza_type_id)
FROM
    pizza_types pt
GROUP BY category;

-- (10)Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pt.name, ROUND(SUM(p.price * od.quantity), 0) AS revenue
FROM
    pizza_types pt
        INNER JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        INNER JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;

-- (11)Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pt.category,
    ROUND(SUM(od.quantity * p.price) / (SELECT 
                    ROUND(SUM(p.price * od.quantity), 2) AS total_revenue
                FROM
                    pizzas p
                        INNER JOIN
                    order_details od ON p.pizza_id = od.pizza_id) * 100,
            2) AS percentage_contribution
FROM
    pizza_types pt
        INNER JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        INNER JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.category
ORDER BY percentage_contribution DESC;


-- (12)Analyze the cumulative revenue generated over time.

select order_date, Round(sum(sales) over(order by order_date),2) as cum_revenue
from
(select o.order_date,
sum(od.quantity*p.price) as sales from order_details od
inner join pizzas p
on od.pizza_id=p.pizza_id
inner join orders o 
on o.order_id=od.order_id
group by o.order_date) as revenue;

--(13) Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select name, revenue 
from
(select category, name, revenue,
rank() over(partition by category order by revenue desc ) as rn
from
(select pt.name, pt.category, Round(sum(od.quantity*p.price),2) as revenue
from pizza_types pt 
inner join pizzas P
ON pt.pizza_type_id=p.pizza_type_id
inner join order_details od 
on od.pizza_id=p.pizza_id
group by pt.name, pt.category) as a) as b
where rn <=3;


 

