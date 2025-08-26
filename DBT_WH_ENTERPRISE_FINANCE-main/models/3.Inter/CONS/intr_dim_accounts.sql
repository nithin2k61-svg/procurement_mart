{{config(materialized='table')}}
with intr_dim_accounts as(
select
    account_name1,
    account_name2,
    account_name3,
    account_name4,
    account_name5,
    sourcesystemid,
	SRC_UNIQ_CD,
	DEL_INDC,
    row_cre_dt,
    row_cre_usr_id,
    row_mod_dt,
    row_mod_usr_id
from {{ref('stg_accounts')}})
select * from intr_dim_accounts