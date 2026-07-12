with source as (
    select * from {{ source('bronze', 'products_stg') }}
)
select
    product_id,
    lower(trim(category))            as category,
    lower(trim(brand))               as brand,
    cast(base_price as number(10,2)) as base_price,
    cast(launch_date as date)        as launch_date,
    (is_premium = 1)                 as is_premium
from source
where product_id is not null
