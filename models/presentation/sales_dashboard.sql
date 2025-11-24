{% set from_date = var('from_date', none) %}

{# ------------------------------ #}
{#   PRE-HOOK: DELETE FOR RELOAD  #}
{# ------------------------------ #}
{% if from_date is not none %}
  {{
    config(
      pre_hook = [
       "delete from {{ this }} where reporting_date >= '{{ var('from_date') }}'"
      ]
       
    )
  }}
{% endif %}

{# ------------------------------ #}
{#         MODEL CONFIG           #}
{# ------------------------------ #}
{{
  config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key=['customer_id', 'order_day']
  )
}}

with customer_summary as (
    select
        dateadd(day, 1, order_day) as reporting_date,
        *
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

{# ------------------------------ #}
{#       INCREMENTAL LOGIC        #}
{# ------------------------------ #}

{% if is_incremental() %}

    {% if from_date is not none %}
        -- PARTIAL REFRESH MODE
        -- after deletion, reinsert all rows for the range
        select * from dashboard

    {% else %}
        -- NORMAL INCREMENTAL MODE
        select *
        from dashboard d
        where d.order_day > (
            select coalesce(max(order_day), '1900-01-01')
            from {{ this }}
        )
    {% endif %}

{% else %}
    -- FULL REFRESH MODE
    select * from dashboard
{% endif %}
