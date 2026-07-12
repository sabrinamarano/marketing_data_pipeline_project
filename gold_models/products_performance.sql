-- Products: revenue + quantity per product/category, with avg monthly sessions.
{{ config(materialized='table', schema='gold') }}

with tx as (
    select * from {{ ref('stg_transactions') }}
    where not is_refunded
),
prod as (
    select * from {{ ref('stg_products') }}
),
-- monthly avg sessions per product from events
sessions as (
    select
        product_id,
        date_trunc('month', event_date)::date as month,
        count(distinct session_id)            as monthly_sessions
    from {{ ref('stg_events') }}
    where product_id is not null
    group by 1,2
),
sessions_avg as (
    select product_id, round(avg(monthly_sessions), 1) as avg_monthly_sessions
    from sessions group by 1
)
select
    p.product_id,
    p.category,
    p.brand,
    p.is_premium,
    count(t.transaction_id)                 as orders,
    sum(t.quantity)                         as units_sold,
    sum(t.net_revenue)                      as total_revenue,
    round(avg(t.net_revenue), 2)            as avg_order_value,
    coalesce(s.avg_monthly_sessions, 0)     as avg_monthly_sessions
from prod p
left join tx t     on t.product_id = p.product_id
left join sessions_avg s on s.product_id = p.product_id
group by 1,2,3,4, s.avg_monthly_sessions
