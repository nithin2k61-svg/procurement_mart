{{
    config(
        materialized="incremental",
        dist="src_uniq_cd",
        unique_key="src_uniq_cd",
        on_schema_change="sync_all_columns",
    )
}}

with
    dim_company as (
        select
            {{ source("sequence_sources", "dimcompanyidkey") }}.nextval as dim_company_id,
            a.COMPANY_CODE,
            a.COMPANY_NAME,
            a.src_sys_id,
            a.src_uniq_cd,
            a.row_cre_dt,
            a.row_cre_usr_id,
            a.row_mod_dt,
            a.row_mod_usr_id
        from {{ ref("intr_dim_company") }} a
        
        {% if is_incremental() %}
        where a.src_uniq_cd not in (
            select src_uniq_cd from {{ this }}
        )
        {% endif %}
        
        union all
        
        -- Unknown member record
        select
            -1 as dim_company_id,
            'UNKNOWN' as COMPANY_CODE,
            'Unknown Company' as COMPANY_NAME,
            '0' as src_sys_id,
            '0_UNKNOWN' as src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
    )

select * from dim_company