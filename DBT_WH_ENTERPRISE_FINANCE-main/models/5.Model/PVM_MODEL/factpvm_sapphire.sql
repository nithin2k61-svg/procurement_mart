{{ config(materialized="view") }}

with
    factpvm_sapphire as (
        select
            dat.dateday,
            spr.dim_date_id,
            client.financeparent,
            product.PRODUCT_TYPE as dim_spr_product_type_id,
            case
                when
                    sum(spr.volume_amount) = 0.000
                    or product_type_category
                    in ('Network Solutions Products', 'PayerCompass')
                then null
                else sum(spr.volume_amount)
            end charged_amount,
            case
                when
                    sum(spr.gross_revenue_amount) = 0.000
                    or product_type_category
                    in ('Network Solutions Products', 'PayerCompass')
                then null
                else sum(spr.gross_revenue_amount)
            end revenue_amount,
            case
                when sum(spr.net_revenue_amount) = 0.000
                then null
                else sum(spr.net_revenue_amount)
            end net_revenue_amount

        from {{ ref("fact_revenue_aggr") }} spr
        inner join
            {{ ref('dim_date') }} dat
            on dat.dim_date_id = spr.dim_date_id
        inner join
            {{ ref("dim_client") }} client
            on client.dim_client_id = spr.dim_client_id
        inner join
            {{ ref("dim_business_unit") }} business_unit
            on business_unit.dim_business_unit_id = spr.dim_business_unit_id
        inner join
            {{ ref("dim_product_type") }} product
            on product.dim_product_type_id = spr.dim_product_type_id
        where
            dat.dateday < date_trunc('MONTH', getdate())
            and business_unit.businessunitname = 'Insights & Empowerment'
            and product.product_type_category in ('Sapphire Digital Products')
        group by
            dat.dateday,
            spr.dim_date_id,
            client.financeparent,
            product.PRODUCT_TYPE,
            product.product_type_category
    )
select * from factpvm_sapphire
