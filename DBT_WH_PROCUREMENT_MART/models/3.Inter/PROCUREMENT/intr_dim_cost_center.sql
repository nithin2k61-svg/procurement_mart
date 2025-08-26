{{ config(materialized="table", tags=["daily"]) }}

with
    intr_dim_cost_center as (
        select distinct
            COST_CENTER as COST_CENTER_CODE,
            COST_CENTER as COST_CENTER_NAME,
            src_sys_id,
            src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ ref("stg_purchase_orders") }}
        where COST_CENTER is not null
        
        union all
        
        select distinct
            COST_CENTER as COST_CENTER_CODE,
            COST_CENTER as COST_CENTER_NAME,
            src_sys_id,
            src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ ref("stg_supplier_invoices") }}
        where COST_CENTER is not null
        
        union all
        
        select distinct
            COST_CENTER as COST_CENTER_CODE,
            COST_CENTER as COST_CENTER_NAME,
            src_sys_id,
            src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ ref("stg_requisitions") }}
        where COST_CENTER is not null
    )

select * from intr_dim_cost_center