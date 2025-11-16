
with source as (

    select * from {{ source('raw', 'customers') }}

),

cleaned as (

    select
        customer_id  as customer_id,
        initcap(trim(customer_name)) as customer_name,
        upper(trim(segment)) as segment,
        try_to_date(signup_date) as signup_date,
        current_timestamp() as load_ts
    from source
    where customer_id is not null
)

select * from cleaned
