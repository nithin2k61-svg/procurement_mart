{{ config(materialized="table", tags=["monthly"]) }}

with
    fact_lrp_revenue_aggr as (
        select
            dim_client_id,
            dim_product_type_id,
            dim_source_system_id,
            dim_business_unit_id,
            dim_date_id,
            src_sys_id,
            revenue_amount,
            getdate() as row_cre_dt,
            'SF_Admin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SF_Admin' as row_mod_usr_id,
            dim_provider_id
        from {{ ref("intr_fact_lrp_revenue_aggr") }}
       
    )

select *
from fact_lrp_revenue_aggr

