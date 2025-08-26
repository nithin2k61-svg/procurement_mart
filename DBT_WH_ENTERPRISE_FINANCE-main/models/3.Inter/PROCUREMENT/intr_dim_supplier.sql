{{ config(materialized="table", tags=["daily"]) }}

with
    intr_dim_supplier as (
        select distinct
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
            src_sys_id,
            src_uniq_cd,
            row_cre_dt,
            row_cre_usr_id,
            row_mod_dt,
            row_mod_usr_id
        from {{ ref("stg_suppliers") }}
    )

select *
from intr_dim_supplier