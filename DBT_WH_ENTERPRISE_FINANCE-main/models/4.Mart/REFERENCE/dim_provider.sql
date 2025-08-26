{{
    config(
        materialized="incremental",
        dist="src_uniq_cd",
        unique_key="src_uniq_cd",
        on_schema_change="sync_all_columns",
    )
}}

with dim_provider as (
    select 
    {{ source("sequence_sources", "dimprovideridkey") }}.nextval as dim_provider_id,
    a.providerid, 
    a.name, 
    a.tin, 
    a.npi, 
    a.STREET1, 
    a.STREET2, 
    a.CITY, 
    a.STATE, 
    a.POSTALCODE, 
    a.COUNTRY,
    a.src_sys_id,
    a.src_uniq_cd, 
    a.row_cre_dt, 
    a.row_cre_usr_id, 
    a.row_mod_dt, 
    a.row_mod_usr_id
    from {{ ref("intr_dim_provider") }} a
        {% if is_incremental() %}
        left outer join {{ this }} b on (a.src_uniq_cd = b.src_uniq_cd)
        where b.src_uniq_cd is null

 union all

    select 
    b.dim_provider_id,
    a.providerid, 
    a.name, 
    a.tin, 
    a.npi, 
    a.STREET1, 
    a.STREET2, 
    a.CITY, 
    a.STATE, 
    a.POSTALCODE, 
    a.COUNTRY,
    a.src_sys_id,
    a.src_uniq_cd, 
    b.row_cre_dt, 
    b.row_cre_usr_id, 
    a.row_mod_dt, 
    a.row_mod_usr_id
     from {{ ref("intr_dim_provider") }} a
        left outer join {{ this }} b on (a.src_uniq_cd = b.src_uniq_cd)
        where b.src_uniq_cd is not null
        {% endif %}
union all
    select 
    -1 as dim_provider_id,
    -1 as providerid, 
    'Unknown' as name, 
    'Unknown' as tin, 
    -1 as npi, 
    'Unknown' as STREET1, 
    'Unknown' as STREET2, 
    'Unknown' as CITY, 
    'Unknown' as STATE, 
    'Unknown' as POSTALCODE, 
    'Unknown' as COUNTRY,
    '7' as src_sys_id,
    concat(src_sys_id, '_', providerid) as src_uniq_cd,
    getdate() row_cre_dt, 
    'SF_Admin' asrow_cre_usr_id, 
    getdate() row_mod_dt, 
    'SF_Admin' as row_mod_usr_id
)
select * from dim_provider
