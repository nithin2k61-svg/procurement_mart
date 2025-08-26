{{ config(materialized="table", tags=["daily"]) }}

with
    intr_dim_location as (
        select distinct
            LOCATION as LOCATION_CODE,
            LOCATION as LOCATION_NAME,
            src_sys_id,
            src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ ref("stg_purchase_orders") }}
        where LOCATION is not null
        
        union all
        
        select distinct
            LOCATION as LOCATION_CODE,
            LOCATION as LOCATION_NAME,
            src_sys_id,
            src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ ref("stg_supplier_invoices") }}
        where LOCATION is not null
        
        union all
        
        select distinct
            LOCATION as LOCATION_CODE,
            LOCATION as LOCATION_NAME,
            src_sys_id,
            src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ ref("stg_requisitions") }}
        where LOCATION is not null
    )

select * from intr_dim_location