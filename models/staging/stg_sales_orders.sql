
with source as (

    -- Pull data from your RAW layer
    select * from {{ source('raw', 'sales_orders') }}

),

cleaned as (

    select
        cast(order_id as int) as order_id,
        try_to_date(order_date) as order_date,
         customer_id   as customer_id,
        upper(trim(product_id)) as product_id,
        cast(quantity as int) as quantity,
        cast(price as number(10,2)) as price,
        quantity * price as total_value,
        current_timestamp() as load_ts
    from source
    where quantity > 0
      and price > 0
)

select * from cleaned