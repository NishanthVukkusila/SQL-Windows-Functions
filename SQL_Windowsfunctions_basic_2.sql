-- Script to create the Product table and load data into it.

create database Products_db;
use Products_db;

DROP TABLE product;
CREATE TABLE product
( 
    product_category varchar(255),
    brand varchar(255),
    product_name varchar(255),
    price int
);

INSERT INTO product VALUES
('Phone', 'Apple', 'iPhone 12 Pro Max', 1300),
('Phone', 'Apple', 'iPhone 12 Pro', 1100),
('Phone', 'Apple', 'iPhone 12', 1000),
('Phone', 'Samsung', 'Galaxy Z Fold 3', 1800),
('Phone', 'Samsung', 'Galaxy Z Flip 3', 1000),
('Phone', 'Samsung', 'Galaxy Note 20', 1200),
('Phone', 'Samsung', 'Galaxy S21', 1000),
('Phone', 'OnePlus', 'OnePlus Nord', 300),
('Phone', 'OnePlus', 'OnePlus 9', 800),
('Phone', 'Google', 'Pixel 5', 600),
('Laptop', 'Apple', 'MacBook Pro 13', 2000),
('Laptop', 'Apple', 'MacBook Air', 1200),
('Laptop', 'Microsoft', 'Surface Laptop 4', 2100),
('Laptop', 'Dell', 'XPS 13', 2000),
('Laptop', 'Dell', 'XPS 15', 2300),
('Laptop', 'Dell', 'XPS 17', 2500),
('Earphone', 'Apple', 'AirPods Pro', 280),
('Earphone', 'Samsung', 'Galaxy Buds Pro', 220),
('Earphone', 'Samsung', 'Galaxy Buds Live', 170),
('Earphone', 'Sony', 'WF-1000XM4', 250),
('Headphone', 'Sony', 'WH-1000XM4', 400),
('Headphone', 'Apple', 'AirPods Max', 550),
('Headphone', 'Microsoft', 'Surface Headphones 2', 250),
('Smartwatch', 'Apple', 'Apple Watch Series 6', 1000),
('Smartwatch', 'Apple', 'Apple Watch SE', 400),
('Smartwatch', 'Samsung', 'Galaxy Watch 4', 600),
('Smartwatch', 'OnePlus', 'OnePlus Watch', 220);
COMMIT;




-- All the SQL Queries written during the video

select * from product;


-- FIRST_VALUE 
-- Write query to display the most expensive product under each category (corresponding to each record)
select * ,
    first_value(price) 
    over(partition by product_category order by price desc range between unbounded preceding and current row) 
    as cost_of_most_exp_product
from product;

-- LAST_VALUE 
-- Write query to display the least expensive product under each category (corresponding to each record)

select * ,
    last_value(price) 
		over(partition by product_category order by price desc
        range between unbounded preceding and unbounded following) 
        -- here the default range is between unbounded preceeding and current row 
        -- when the range is not specified we get the same value from the row 
        as cost_of_least_exp_product
from product;

-- if we want to find a specific category of produc
select * ,
    last_value(product_name) 
		over(partition by product_category order by price desc
        range between unbounded preceding and unbounded following) 
        as least_exp_product
from product
where product_category = 'Laptop';

-- Alternate way to write SQL query using Window functions
-- NTH_VALUE 
-- Write query to display the Second most expensive product under each category.
select * ,
    nth_value(product_name,3) 
		over(partition by product_category order by price desc
        range between unbounded preceding and unbounded following) 
        -- here the default range is between unbounded preceeding and current row 
        -- when the range is not specified we get the same value from the row 
        as second_most_exp_product
from product;

-- NTILE
-- Write a query to segregate all the expensive phones, mid range phones and the cheaper phones.

select p.product_name, 
case when buckts = 1 then 'HighEnd Phones'
     when buckts = 2 then 'MidRange Phones'
     when buckts = 3 then 'Cheaper Phones' END as Phone_Category
from (
    select *,
    ntile(3) over (order by price desc) as buckts
    from product
    where product_category = 'Phone')p ;
    
-- CUME_DIST (cumulative distribution) ; 
/*  Formula = Current Row no (or Row No with value same as current row) / Total no of rows */

-- Query to fetch all products which are constituting the first 30% 
-- of the data in products table based on price.

select product_name, concat(ROUND(cume_distribution * 100, 2), '%')  AS percentage
	from (
		select *,
		cume_dist() over (order by price desc) as cume_distribution
		from product ) a
where cume_distribution  <= 0.3;

-- PERCENT_RANK (relative rank of the current row / Percentage Ranking)
/* Formula = Current Row No - 1 / Total no of rows - 1 */
-- Query to identify how much percentage more expensive is "Galaxy Z Fold 3" when compared to all products.

select 
	product_name,
    round((percent_rank() over(order by price)* 100), 2) as percent
from ( select *,
		percent_rank() over(order by price) as per 
		from product) b
where b.product_name='Galaxy Z Fold 3';



