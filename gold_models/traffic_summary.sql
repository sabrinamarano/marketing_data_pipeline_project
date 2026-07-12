-- Traffic: volume counts by source, device, campaign (internal id).
{{ config(materialized='table', schema='gold') }}

with events as (
    select * from {{ ref('stg_events') }}
)
select
    traffic_source,
    device_type,
    campaign_id,
    count(*)                        as event_count,
    count(distinct session_id)      as sessions,
    count(distinct customer_id)     as unique_customers
from events
group by 1,2,3
