{{ config(materialized="table", tags=["monthly"]) }}

WITH stg_pps_ppswh_provider AS (
    select providerid, 
    name, 
    tin, 
    npi, 
    STREET1, 
    STREET2, 
    CITY, 
    STATE, 
    POSTALCODE, 
    COUNTRY,
    '2' as src_sys_id,
    concat(src_sys_id, '_', providerid) as src_uniq_cd, 
    getdate() as row_cre_dt,
    'SFAdmin' as row_cre_usr_id, 
    getdate() as row_mod_dt,
    'SFAdmin' as row_mod_usr_id
    from {{source("ppswh_payment_sources","dimprovider")}}
)
select * from stg_pps_ppswh_provider

