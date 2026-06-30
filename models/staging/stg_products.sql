-- Grain: one row per product_type. Trivial today (one active product) but
-- exists so adding a second product is a seed-data change, not a schema
-- change - see README "Extensibility" section.

with source as (

    select * from {{ ref('raw_products') }}

),

cleaned as (

    select
        lower(trim(product_type)) as product_type,
        product_name,
        product_category,
        min_amount,
        max_amount,
        is_active

    from source

)

select * from cleaned
