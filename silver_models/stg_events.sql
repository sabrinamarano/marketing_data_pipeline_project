with source as (
    select * from {{ source('bronze', 'events_stg') }}
)
select
    event_id,
    event_ts,
    cast(event_ts as date)                        as event_date,
    customer_id,
    session_id,
    lower(trim(event_type))                       as event_type,
    product_id,
    lower(trim(device_type))                      as device_type,
    lower(trim(traffic_source))                   as traffic_source,
    nullif(campaign_id, 0)                         as campaign_id,
    lower(trim(page_category))                    as page_category,
    cast(session_duration_sec as number(10,2))    as session_duration_sec,
    lower(trim(utm_campaign))                      as utm_campaign,
    lower(trim(utm_source))                        as utm_source,
    lower(trim(utm_medium))                        as utm_medium,
    case lower(trim(event_type))
        when 'view'        then 1
        when 'add_to_cart' then 2
        when 'purchase'    then 3
        else 0
    end                                           as funnel_stage,
    (lower(trim(event_type)) = 'purchase')        as is_conversion
from source
where event_id is not null
