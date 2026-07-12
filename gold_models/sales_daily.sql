-- Sales: daily revenue split organic vs paid.
-- campaign_id is NULL (was 0) for organic; non-null = paid-attributed.
{{ config(materialized='table', schema='gold') }}

with tx as (
    select * from {{ ref('stg_transactions') }}
    where not is_refunded          -- exclude refunds from revenue
)
select
    order_date                                              as date,
    count(*)                                                as orders,
    sum(net_revenue)                                        as total_revenue,
    -- organic vs paid split
    sum(case when campaign_id is null then net_revenue else 0 end)      as organic_revenue,
    sum(case when campaign_id is not null then net_revenue else 0 end)  as paid_revenue,
    count_if(campaign_id is null)                           as organic_orders,
    count_if(campaign_id is not null)                       as paid_orders
from tx
group by 1
