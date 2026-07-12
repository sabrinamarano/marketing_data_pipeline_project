-- Customers: counts by acquisition channel + loyalty tier.
{{ config(materialized='table', schema='gold') }}

with c as (
    select * from {{ ref('stg_customers') }}
)
select
    acquisition_channel,
    loyalty_tier,
    country,
    count(*)                        as customer_count,
    round(avg(age), 1)              as avg_age,
    round(avg(tenure_days), 0)      as avg_tenure_days
from c
group by 1,2,3
