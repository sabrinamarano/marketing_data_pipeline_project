with source as (
    select * from {{ source('bronze', 'transactions_stg') }}
)
select
    transaction_id,
    order_ts,
    cast(order_ts as date)                                as order_date,
    date_trunc('month', order_ts)::date                   as order_month,
    customer_id,
    product_id,
    quantity,
    cast(gross_revenue as number(12,2))                   as gross_revenue,
    cast(discount_applied as number(10,2))                as discount_applied,
    nullif(campaign_id, 0)                                as campaign_id,
    (refund_flag = 1)                                     as is_refunded,
    case when refund_flag = 1 then 0
         else cast(gross_revenue as number(12,2)) end     as net_revenue,
    (campaign_id <> 0)                                    as is_paid_attributed
from source
where transaction_id is not null
