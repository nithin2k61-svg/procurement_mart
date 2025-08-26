{{config(materialized='table')}}
with stg_accounts as(
    select
    distinct account_name1,
    account_name2,
    account_name3,
    account_name4,
    case
        when account_name2 = 'Postage & Freight - COGS' then account_name4
        else coalesce(account_name5, account_name4)
    end account_name5
FROM
    {{source('adaptive_comm_sources','ACCOUNTS')}}
where
    account_name1 IN (
        'Total Cost of Revenues',
        'Total Operating Expenses'
    )
    and (
        account_name2 = 'Total Operating Expenses (External)'
        or upper(account_name5) LIKE '% - NO CATEGORY'
        or RIGHT(left(account_name5, 8), 3) = ' - '
        or try_to_double(left(account_name5, 5)) is null
    )
    and case
        when account_name2 = 'Postage & Freight - COGS' then account_name4
        else coalesce(account_name5, account_name4)
    end is not null
order by
    case
        when account_name2 = 'Postage & Freight - COGS' then account_name4
        else coalesce(account_name5, account_name4)
    end desc
)
select *,{{getSourceSystemID(var('var_adaptive_sourcesystemid'))}} as sourcesystemid,
		concat(sourcesystemid,'_',account_name5) as SRC_UNIQ_CD,
		0 as DEL_INDC,
        getdate() as row_cre_dt,
        'SFAdmin' as row_cre_usr_id,
         getdate() as row_mod_dt,
        'SFAdmin' as row_mod_usr_id 
from stg_accounts