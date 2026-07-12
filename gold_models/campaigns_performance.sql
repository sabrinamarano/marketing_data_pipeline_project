-- Marketing: campaign/ad performance from AD PLATFORM data.
-- Metrics computed from aggregated totals (correct for ratios).
-- CVR here = conversions/clicks (ad-platform conversions).
{{ config(materialized='table', schema='gold') }}

with ads as (
    select * from {{ ref('stg_campaigns') }}
)
select
    spend_date                              as date,
    year,
    month,
    platform,
    country,
    campaign_clean                          as campaign_name,
    objective,
    audience,
    -- raw metrics (summed to this grain)
    sum(spend)                              as spend,
    sum(impressions)                        as impressions,
    sum(clicks)                             as clicks,
    sum(conversions)                        as conversions,
    -- derived metrics from SUMMED totals (correct ratio math)
    case when sum(impressions) > 0 then round(sum(clicks) / sum(impressions), 4) else 0 end        as ctr,
    case when sum(clicks) > 0      then round(sum(conversions) / sum(clicks), 4) else 0 end         as cvr,
    case when sum(clicks) > 0      then round(sum(spend) / sum(clicks), 2) else 0 end               as cpc,
    case when sum(impressions) > 0 then round(sum(spend) / sum(impressions) * 1000, 2) else 0 end   as cpm,
    -- cost per acquisition (spend per conversion)
    case when sum(conversions) > 0 then round(sum(spend) / sum(conversions), 2) else 0 end          as cpa
from ads
group by 1,2,3,4,5,6,7,8
