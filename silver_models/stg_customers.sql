with source as (
    select * from {{ source('bronze', 'customers_stg') }}
)
select
    customer_id,
    cast(signup_date as date)                     as signup_date,
    lower(trim(country))                          as country,
    age,
    lower(trim(gender))                           as gender,
    lower(trim(loyalty_tier))                     as loyalty_tier,
    lower(trim(acquisition_channel))              as acquisition_channel,
    datediff('day', signup_date, current_date())  as tenure_days
from source
where customer_id is not null
