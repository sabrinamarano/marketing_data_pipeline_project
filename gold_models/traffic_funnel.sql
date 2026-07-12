-- Traffic: behavioural funnel from EVENTS (view -> cart -> purchase).
-- Behavioural CVR = purchases / views. Independent of ad-platform data.
{{ config(materialized='table', schema='gold') }}

with events as (
    select * from {{ ref('stg_events') }}
)
select
    event_date                                                   as date,
    traffic_source,
    device_type,
    count_if(event_type = 'view')                                as views,
    count_if(event_type = 'add_to_cart')                         as add_to_carts,
    count_if(event_type = 'purchase')                            as purchases,
    -- funnel conversion rates from counts
    case when count_if(event_type = 'view') > 0
         then round(count_if(event_type = 'add_to_cart') / count_if(event_type = 'view'), 4)
         else 0 end                                              as view_to_cart_rate,
    case when count_if(event_type = 'add_to_cart') > 0
         then round(count_if(event_type = 'purchase') / count_if(event_type = 'add_to_cart'), 4)
         else 0 end                                              as cart_to_purchase_rate,
    case when count_if(event_type = 'view') > 0
         then round(count_if(event_type = 'purchase') / count_if(event_type = 'view'), 4)
         else 0 end                                              as overall_cvr
from events
group by 1,2,3
