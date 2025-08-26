{{ config(materialized="view") }}

with
    factpvm_ccs as (
        select
            dat.dateday,
            ccs.dim_date_id,
            client.financeparent,
            product.PRODUCT_TYPE as dim_ccs_product_type_id,
            case
                when
                    sum(ccs.volume_amount) = 0.000
                    or product_type_category
                    in ('Network Solutions Products', 'PayerCompass')
                then null
                else sum(ccs.volume_amount)
            end charged_amount,
            case
                when
                    sum(ccs.gross_revenue_amount) = 0.000
                    or product_type_category
                    in ('Network Solutions Products', 'PayerCompass')
                then null
                else sum(ccs.gross_revenue_amount)
            end revenue_amount,
            case
                when sum(ccs.net_revenue_amount) = 0.000
                then null
                else sum(ccs.net_revenue_amount)
            end net_revenue_amount

        from {{ ref("fact_revenue_aggr") }} ccs
        inner join
            {{ ref('dim_date') }} dat
            on dat.dim_date_id = ccs.dim_date_id
        inner join
            {{ ref("dim_client") }} client
            on client.dim_client_id = ccs.dim_client_id
        inner join
            {{ ref("dim_business_unit") }} business_unit
            on business_unit.dim_business_unit_id = ccs.dim_business_unit_id
        inner join
            {{ ref("dim_product_type") }} product
            on product.dim_product_type_id = ccs.dim_product_type_id
        where
            dat.dateday < date_trunc('MONTH', getdate())
            and business_unit.businessunitname = 'Price'
            and product.product_type_category in ('% of Saving Products', 'Network Solutions Products', 'PayerCompass + NR')
        group by
            dat.dateday,
            ccs.dim_date_id,
            client.financeparent,
            product.PRODUCT_TYPE,
            product.product_type_category
    )
select * from factpvm_ccs
