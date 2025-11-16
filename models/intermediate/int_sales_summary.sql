
with order_data as (
    select *
    from {{ ref('stg_sales_orders') }}
),

customer_data as (
    select *
    from {{ ref('stg_customers') }}
),

-- join sales orders with customer info
joined as (
    select
        o.order_id,
        o.order_date,
        o.customer_id,
        c.customer_name,

        o.product_id,
        o.quantity,
        o.price,
        o.total_value
    from order_data o
    left join customer_data c
        on o.customer_id = c.customer_id
),

-- aggregate daily sales
daily_sales as (
    select
        customer_id,
        customer_name,
        
        date_trunc('day', order_date) as order_day,
        count(distinct order_id) as total_orders,
        sum(quantity) as total_quantity,
        sum(total_value) as total_sales
    from joined
    group by 1,2,3
)

select * from daily_sales
