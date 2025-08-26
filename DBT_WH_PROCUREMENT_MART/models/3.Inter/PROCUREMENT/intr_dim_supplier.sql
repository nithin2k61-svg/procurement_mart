{{ config(materialized="table", tags=["daily"]) }}

with
    intr_dim_supplier as (
        select distinct
            SUPPLIER_ID as SUPPLIER_CODE,
            SUPPLIER as SUPPLIER_NAME,
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
            src_sys_id,
            src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ ref("stg_suppliers") }}
        where SUPPLIER_ID is not null
    )

select * from intr_dim_supplier