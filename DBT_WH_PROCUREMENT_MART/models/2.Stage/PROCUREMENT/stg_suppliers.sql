{{ config(materialized="table", tags=["daily"]) }}

with
    stg_suppliers as (
        select
            SUPPLIER_ID,
            SUPPLIER,
            SUPPLIER_CATEGORY,
            SUPPLIER_STATUS,
            SUPPLIER_APPROVAL_STATUS,
            COUNTRY,
            PRIMARY_EMAIL_ADDRESS,
            DEFAULT_PHONE_NUMBER,
            SUPPLIER_CONTACTS,
            EMAIL_ID,
            EMAIL_ADDRESS,
            CREATED_ON,
            '1' as src_sys_id,
            concat(src_sys_id, '_', SUPPLIER_ID) as src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ source("procurement_sources", "EXTRACT_SUPPLIERS") }}
        where SUPPLIER_ID is not null
    )

select * from stg_suppliers