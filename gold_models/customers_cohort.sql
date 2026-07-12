-- Customers: signup cohort analysis by month + acquisition channel.
{{ config(materialized='table', schema='gold') }}

with c as (
    select * from {{ ref('stg_customers') }}
)
select
    date_trunc('month', signup_date)::date  as cohort_month,
    acquisition_channel,
    count(*)                                 as customers_acquired,
    round(avg(age), 1)                       as avg_age
from c
group by 1,2
order by 1,2
