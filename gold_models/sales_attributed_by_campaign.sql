-- Sales: revenue attributed to each internal campaign (paid only).
-- NOTE: "attributed" under last-touch (transaction carries campaign_id).
-- True incrementality would require the experiment holdout; this is the
-- campaign-attributed revenue, treated as the campaign's contribution.
{{ config(materialized='table', schema='gold') }}

with tx as (
    select * from {{ ref('stg_transactions') }}
    where not is_refunded
      and campaign_id is not null      -- paid / campaign-attributed only
)
select
    campaign_id,
    order_month                     as month,
    count(*)                        as orders,
    sum(net_revenue)                as attributed_revenue,
    sum(quantity)                   as units_sold,
    round(avg(net_revenue), 2)      as avg_order_value
from tx
group by 1,2
