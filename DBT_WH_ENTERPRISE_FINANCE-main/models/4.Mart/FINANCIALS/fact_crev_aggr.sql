{{ config(materialized="table") }}

with
    fact_crev_aggr as (
        select
            DIM_CLIENT_ID,
            dim_product_type_id,
            dim_source_system_id,
            dim_business_unit_id,
            DIM_PROVIDER_ID,
            dim_date_id,
            ACCOUNT_NAME,
            LEVEL_NAME,
            TRAN_TYP,
            CREV_AMOUNT,
            SRC_SYS_ID,
            src_uniq_cd,
            row_cre_dt,
            row_cre_usr_id,
            row_mod_dt,
            row_mod_usr_id            
        from {{ ref("intr_fact_crev_aggr") }}       
    )
select *from fact_crev_aggr
