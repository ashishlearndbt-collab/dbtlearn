{{ 
    config(
            materialized='incremental',
            schema='presentation',
            unique_key=['customer_id', 'order_day']
           ) 
}}


with customer_summary as (
    select DATEADD(day, 1, order_day) as reporting_date, *
    from {{ ref('int_sales_summary') }}
),

dashboard as (
    select
        reporting_date,
        customer_id,
        customer_name,
        order_day,
        total_orders,
        total_quantity,
        total_sales,
        round(total_sales / nullif(total_orders, 0), 2) as avg_order_value
    from customer_summary
)

{% if is_incremental() %}
    select *
    from dashboard d
    where d.order_day > (
        select coalesce(max(order_day), '1900-01-01')
        from {{ this }}
    )
{% else %}
    select * from dashboard
{% endif %}
