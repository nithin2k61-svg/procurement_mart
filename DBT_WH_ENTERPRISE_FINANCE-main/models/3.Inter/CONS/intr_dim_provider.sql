{{ config(materialized="table", tags=["monthly"]) }}

with intr_dim_provider as (
    select distinct  providerid, 
    name, 
    tin, 
    npi, 
    STREET1, 
    STREET2, 
    CITY, 
    STATE, 
    POSTALCODE, 
    COUNTRY,
    src_sys_id,
    src_uniq_cd, 
    row_cre_dt, 
    row_cre_usr_id, 
    row_mod_dt, 
    row_mod_usr_id 
    from {{ref('stg_pps_ppswh_provider')}}                    
)
select * from intr_dim_provider
