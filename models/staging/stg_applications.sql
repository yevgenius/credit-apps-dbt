-- Assumption: in production this selects from source('bronze', 'applications')
-- against a real ingested raw table. We don't have a real warehouse here, so it
-- selects from the seed directly. Swapping in a source() is a one-line change
-- and nothing downstream needs to know the difference.
--
-- Grain: one row per application_id (the application entity itself - status
-- history lives in stg_application_status_events, not here).

with source as (

    select * from {{ ref('raw_applications') }}

),

cleaned as (

    select
        application_id,
        applicant_id,
        lower(trim(product_type)) as product_type,
        lower(trim(channel)) as channel,
        requested_amount,
        created_at::timestamp as created_at,
        -- Assumption: attributes is a free-form JSON blob for product-specific
        -- fields (e.g. {"collateral_type": "vehicle"} for hardship loans) that we
        -- don't want to force into the table schema today. Parsed lazily by
        -- whoever needs a specific key, rather than spreading every possible
        -- product's attributes into named columns up front.
        attributes as attributes_json

    from source

)

select * from cleaned
