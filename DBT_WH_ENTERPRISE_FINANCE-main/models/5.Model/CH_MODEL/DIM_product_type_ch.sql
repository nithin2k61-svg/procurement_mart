{{ config(materialized="view") }}

with
    dim_product_type_ch as (
        select
            dim_product_type_id DIM_PRODUCT_TYPE_ID,
            product_type "Product Type",
            product_type_group "Product Type Group",
            case
                when product_type = 'RBP'
                then 'OON'
                when product_type_group IN ('OON','Claims Editing','EOB','ID Cards','Check/EOB') AND product_type <> 'Enrollment-Product'
                THEN product_type_group
                else product_type
            end "Product Profile Group",
            product_type_category "Product Type Category",
            dense_rank() over (
                order by
                case
                when product_type = 'RBP'
                then 'OON'
                when product_type_group IN ('OON','Claims Editing', 'EOB','ID Cards', 'Check/EOB') AND product_type <> 'Enrollment-Product'
                THEN product_type_group
                else product_type
            end
            ) "Product Type Group Rank",
            case
                when (PRODUCT_TYPE_GROUP IN ('OON','Claims Editing', 'EOB','ID Cards', 'Check/EOB') AND product_type <> 'Enrollment-Product') or
                       product_type in ( 'RBP', 'HBR', 'VCC', 'ACH+', 'CHECK', 'PayerSponsored', 'PayerBrandedVCC')
                       or product_type_category = 'Sapphire Digital Products'
                then 1
                else 0
            end "Product Profile Active Flag"
        from {{ ref("dim_product_type") }}
    )
select * from dim_product_type_ch