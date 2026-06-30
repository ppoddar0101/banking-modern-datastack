{{ config(materialized='view') }}

WITH ranked AS (
    SELECT
        v:id::string AS account_id,
        v:customer_id::string AS customer_id,
        v:account_type::string AS account_type,
        v:balance::float AS balance,
        v:currency::string AS currency,
        v:created_at::timestamp AS created_at,
        current_timestamp AS load_timestamp,
        ROW_NUMBER() OVER (
            PARTITION BY v:id::string
            ORDER BY v:created_at DESC
        ) AS rn
    FROM {{ source('raw', 'accounts') }}
)

SELECT 
    account_id,
    customer_id,
    account_type,
    balance,
    currency,
    created_at,
    load_timestamp
FROM ranked
WHERE rn = 1