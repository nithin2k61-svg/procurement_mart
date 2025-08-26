{{
    config(
        materialized="incremental",
        dist="src_uniq_cd",
        unique_key="src_uniq_cd",
        on_schema_change="sync_all_columns",
    )
}}

with
    dim_supplier as (
        select
            {{ source("sequence_sources", "dimsupplieridkey") }}.nextval as dim_supplier_id,
            a.SUPPLIER_CODE,
            a.SUPPLIER_NAME,
            a.SUPPLIER_CATEGORY,
            a.SUPPLIER_STATUS,
            a.SUPPLIER_APPROVAL_STATUS,
            a.COUNTRY,
            a.PRIMARY_EMAIL_ADDRESS,
            a.DEFAULT_PHONE_NUMBER,
            a.SUPPLIER_CONTACTS,
            a.EMAIL_ID,
            a.EMAIL_ADDRESS,
            a.CREATED_ON,
            a.src_sys_id,
            a.src_uniq_cd,
            a.row_cre_dt,
            a.row_cre_usr_id,
            a.row_mod_dt,
            a.row_mod_usr_id
        from {{ ref("intr_dim_supplier") }} a
        
        {% if is_incremental() %}
        where a.src_uniq_cd not in (
            select src_uniq_cd from {{ this }}
        )
        {% endif %}
        
        union all
        
        -- Unknown member record
        select
            -1 as dim_supplier_id,
            'UNKNOWN' as SUPPLIER_CODE,
            'Unknown Supplier' as SUPPLIER_NAME,
            null as SUPPLIER_CATEGORY,
            null as SUPPLIER_STATUS,
            null as SUPPLIER_APPROVAL_STATUS,
            null as COUNTRY,
            null as PRIMARY_EMAIL_ADDRESS,
            null as DEFAULT_PHONE_NUMBER,
            null as SUPPLIER_CONTACTS,
            null as EMAIL_ID,
            null as EMAIL_ADDRESS,
            null as CREATED_ON,
            '0' as src_sys_id,
            '0_UNKNOWN' as src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
    )

select * from dim_supplier