with source as (
    select * from {{ source('bronze', 'campaigns_stg') }}
)
select
    campaign_row_id,
    cast(spend_date as date)             as spend_date,
    lower(trim(platform))                as platform,
    campaign_id,
    adset_id,
    ad_id,
    campaign_name                        as campaign_name_raw,
    adset_name                           as adset_name_raw,
    ad_name                              as ad_name_raw,
    -- raw metrics only (derived ctr/cvr/cpc/cpm moved to gold)
    cast(spend as number(12,2))          as spend,
    impressions,
    clicks,
    conversions,
    -- parsed canonical fields (lowercased)
    lower(trim(country))                 as country,
    lower(trim(objective))               as objective,
    lower(trim(campaign_clean))          as campaign_clean,
    lower(trim(audience))                as audience,
    lower(trim(creative_type))           as creative_type,
    year,
    month
from source
where campaign_row_id is not null
