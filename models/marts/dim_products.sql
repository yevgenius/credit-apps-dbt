-- Grain: one row per product_type. Published as its own mart (rather than
-- just inlined into fct_applications) so that adding product-specific
-- reporting attributes later doesn't mean widening the applications fact.

select * from {{ ref('stg_products') }}
