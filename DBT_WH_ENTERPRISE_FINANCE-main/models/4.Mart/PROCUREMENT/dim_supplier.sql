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
            a.SUPPLIER_ID,
            a.SUPPLIER,
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

        left outer join {{ this }} b on (a.src_uniq_cd = b.src_uniq_cd)
        where b.src_uniq_cd is null

        union all

        select
            b.dim_supplier_id,
            a.SUPPLIER_ID,
            a.SUPPLIER,
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
            b.row_cre_dt,
            b.row_cre_usr_id,
            a.row_mod_dt,
            a.row_mod_usr_id
        from {{ ref("intr_dim_supplier") }} a
        left outer join {{ this }} b on (a.src_uniq_cd = b.src_uniq_cd)
        where b.src_uniq_cd is not null
        {% endif %}

        union all

        select
            -1 as dim_supplier_id,
            'Unknown' as SUPPLIER_ID,
            'Unknown' as SUPPLIER,
            'Unknown' as SUPPLIER_CATEGORY,
            'Unknown' as SUPPLIER_STATUS,
            'Unknown' as SUPPLIER_APPROVAL_STATUS,
            'Unknown' as COUNTRY,
            'Unknown' as PRIMARY_EMAIL_ADDRESS,
            'Unknown' as DEFAULT_PHONE_NUMBER,
            'Unknown' as SUPPLIER_CONTACTS,
            'Unknown' as EMAIL_ID,
            'Unknown' as EMAIL_ADDRESS,
            null as CREATED_ON,
            '1' as src_sys_id,
            concat(src_sys_id, '_', 'Unknown') as src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
    )

select *
from dim_supplier