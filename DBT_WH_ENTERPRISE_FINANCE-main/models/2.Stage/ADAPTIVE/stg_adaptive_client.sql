{{ config(materialized="table", tags=["monthly"]) }}

with
    stg_adaptive_client as (
        select distinct
            null as srcclientkey,
            null as clid,
            nvl(REGEXP_SUBSTR(SUBSTRING(a.client, LENGTH(a.client) - POSITION('-' IN REVERSE(a.client)) + 2), '\\d+'), REGEXP_SUBSTR(a.client, '\\d+')) AS clientnumber,
            a.client as clientname,
            nvl(cfm.FINANCE_PARENT,a.client) as clientparentname,
            coalesce(AccountParent.ID,b.act_parent_unid) ACT_PARENT_UNID,
            coalesce(AccountParent.ACCOUNT_ID__C,b.act_parent_id) ACT_PARENT_ID,
            coalesce(AccountParent.NAME,b.act_parent_name) ACT_PARENT_NAME,
            coalesce(account.ID,b.act_unid) ACT_UNID,
            coalesce(account.ACCOUNT_ID__C,b.act_id) ACT_ID,
            coalesce(account.NAME,b.act_name) ACT_NAME,
            coalesce(account.ZELIS_STATUS__C,b.act_zelis_status) ACT_ZELIS_STATUS,
            b.act_active,
            b.act_create_date,
            b.act_type ACT_TYPE,
            b.team_sr_ccs,
            b.team_sr_pps,
            b.team_sr_com,
            b.team_am_ccs,
            b.team_am_pps,
            b.team_am_def,
            null as sourcesystemid,
            lower(nvl(client_financeparent_mapping.finance_parent, a.client)) as financeparent,
            '6' as src_sys_id,
            concat('6', '_', a.client) as src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ source("adaptive_comm_sources", "actuals") }} a
        left outer join
    (select distinct A.CLIENT, e.ATTRIBUTE_VALUE_LEVEL_ONE_NAME finance_parent, h.ATTRIBUTE_VALUE_LEVEL_ONE_NAME salesforce_account, max(to_date(a.yearmonth, 'MONYYYY')) MaxRevenueYearMonth
from {{ source("adaptive_comm_sources", "actuals") }} a
inner join {{ source("adaptive_comm_sources", "dimensions") }} d on (a.CLIENT = d.DIMENSION_VALUE_NAME and d.ATTRIBUTE_NAME = 'Parent -Finance')
inner join {{ source("adaptive_comm_sources", "HIERARCHY_ATTRIBUTES") }} e on (d.attribute_id = e.attribute_id and d.ATTRIBUTE_VALUE_ID = e.product_id)
left outer join {{ source("adaptive_comm_sources", "dimensions") }} g on (a.Client = g.DIMENSION_VALUE_NAME and g.ATTRIBUTE_NAME = 'Account Name ID')
left outer join {{ source("adaptive_comm_sources", "HIERARCHY_ATTRIBUTES") }} h on (g.attribute_id = h.attribute_id and g.ATTRIBUTE_VALUE_ID = h.product_id)
where A.CLIENT not in ('2023 New Sales', '2022 New Sales', 'Uptake', 'NSA - 2023 Plan', 'Operational Initiatives','NSA - 2022 Plan', 'Operational Initiatives - Go Get', 'Client (Uncategorized)')     
group by A.CLIENT, e.ATTRIBUTE_VALUE_LEVEL_ONE_NAME, h.ATTRIBUTE_VALUE_LEVEL_ONE_NAME
order by A.CLIENT, e.ATTRIBUTE_VALUE_LEVEL_ONE_NAME, h.ATTRIBUTE_VALUE_LEVEL_ONE_NAME) client_financeparent_mapping
left outer join {{ source("salesforce_sources", "account") }} account on ((trim(case when contains(right(salesforce_account,7),'A-')=TRUE then right(salesforce_account,7) else 'UNKNOWN' end)=account.ACCOUNT_ID__C))
left outer join {{ source("salesforce_sources", "account") }} AccountParent on (coalesce(account.PARENTID, account.ID) = AccountParent.ID)                    
            on a.client = client_financeparent_mapping.client
        left outer join {{ source("adaptive_comm_sources", "client_salesforceid_mapping") }} csm
            on a.client = csm.client_name
        left outer join {{ ref("stg_account_hierarchy") }} b
            on csm.salesforce_id = b.act_id
        left outer join {{ source("adaptive_comm_sources", "client_financeparent_mapping") }} cfm 
        on lower(trim(cfm.client)) = lower(trim(a.client))

union

        select distinct
            null as srcclientkey,
            null as clid,
            nvl(REGEXP_SUBSTR(SUBSTRING(a.client, LENGTH(a.client) - POSITION('-' IN REVERSE(a.client)) + 2), '\\d+'), REGEXP_SUBSTR(a.client, '\\d+')) AS clientnumber,
            a.client as clientname,
            nvl(cfm.FINANCE_PARENT,a.client) as clientparentname,
            coalesce(AccountParent.ID,b.act_parent_unid) ACT_PARENT_UNID,
            coalesce(AccountParent.ACCOUNT_ID__C,b.act_parent_id) ACT_PARENT_ID,
            coalesce(AccountParent.NAME,b.act_parent_name) ACT_PARENT_NAME,
            coalesce(account.ID,b.act_unid) ACT_UNID,
            coalesce(account.ACCOUNT_ID__C,b.act_id) ACT_ID,
            coalesce(account.NAME,b.act_name) ACT_NAME,
            coalesce(account.ZELIS_STATUS__C,b.act_zelis_status) ACT_ZELIS_STATUS,
            b.act_active,
            b.act_create_date,
            b.act_type ACT_TYPE,
            b.team_sr_ccs,
            b.team_sr_pps,
            b.team_sr_com,
            b.team_am_ccs,
            b.team_am_pps,
            b.team_am_def,
            null as  sourcesystemid,
            lower(nvl(client_financeparent_mapping.finance_parent, a.client)) as financeparent,
            '6' as src_sys_id,
            concat('6', '_', a.client) as src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ source("adaptive_comm_sources", "actuals_crev") }} a
        left outer join
    (select distinct A.CLIENT, e.ATTRIBUTE_VALUE_LEVEL_ONE_NAME finance_parent, h.ATTRIBUTE_VALUE_LEVEL_ONE_NAME salesforce_account, max(to_date(a.yearmonth, 'MONYYYY')) MaxRevenueYearMonth
from {{ source("adaptive_comm_sources", "actuals_crev") }} a
inner join {{ source("adaptive_comm_sources", "dimensions") }} d on (a.CLIENT = d.DIMENSION_VALUE_NAME and d.ATTRIBUTE_NAME = 'Parent -Finance')
inner join {{ source("adaptive_comm_sources", "HIERARCHY_ATTRIBUTES") }} e on (d.attribute_id = e.attribute_id and d.ATTRIBUTE_VALUE_ID = e.product_id)
left outer join {{ source("adaptive_comm_sources", "dimensions") }} g on (a.Client = g.DIMENSION_VALUE_NAME and g.ATTRIBUTE_NAME = 'Account Name ID')
left outer join {{ source("adaptive_comm_sources", "HIERARCHY_ATTRIBUTES") }} h on (g.attribute_id = h.attribute_id and g.ATTRIBUTE_VALUE_ID = h.product_id)
where A.CLIENT not in ('2023 New Sales', '2022 New Sales', 'Uptake', 'NSA - 2023 Plan', 'Operational Initiatives','NSA - 2022 Plan', 'Operational Initiatives - Go Get', 'Client (Uncategorized)')     
group by A.CLIENT, e.ATTRIBUTE_VALUE_LEVEL_ONE_NAME, h.ATTRIBUTE_VALUE_LEVEL_ONE_NAME
order by A.CLIENT, e.ATTRIBUTE_VALUE_LEVEL_ONE_NAME, h.ATTRIBUTE_VALUE_LEVEL_ONE_NAME) client_financeparent_mapping
left outer join {{ source("salesforce_sources", "account") }} account on ((trim(case when contains(right(salesforce_account,7),'A-')=TRUE then right(salesforce_account,7) else 'UNKNOWN' end)=account.ACCOUNT_ID__C))
left outer join {{ source("salesforce_sources", "account") }} AccountParent on (coalesce(account.PARENTID, account.ID) = AccountParent.ID)                    
on a.client = client_financeparent_mapping.client
left outer join {{ source("adaptive_comm_sources", "client_salesforceid_mapping") }} csm
on a.client = csm.client_name
left outer join {{ ref("stg_account_hierarchy") }} b
on csm.salesforce_id = b.act_id
left outer join {{ source("adaptive_comm_sources", "client_financeparent_mapping") }} cfm 
on lower(trim(cfm.client)) = lower(trim(a.client))

union

        select distinct
            null as srcclientkey,
            null as clid,
             nvl(REGEXP_SUBSTR(SUBSTRING(a.client, LENGTH(a.client) - POSITION('-' IN REVERSE(a.client)) + 2), '\\d+'), REGEXP_SUBSTR(a.client, '\\d+')) AS clientnumber,
            a.client as clientname,
            nvl(cfm.FINANCE_PARENT,a.client) as clientparentname,
            coalesce(AccountParent.ID,b.act_parent_unid) ACT_PARENT_UNID,
            coalesce(AccountParent.ACCOUNT_ID__C,b.act_parent_id) ACT_PARENT_ID,
            coalesce(AccountParent.NAME,b.act_parent_name) ACT_PARENT_NAME,
            coalesce(account.ID,b.act_unid) ACT_UNID,
            coalesce(account.ACCOUNT_ID__C,b.act_id) ACT_ID,
            coalesce(account.NAME,b.act_name) ACT_NAME,
            coalesce(account.ZELIS_STATUS__C,b.act_zelis_status) ACT_ZELIS_STATUS,
            b.act_active,
            b.act_create_date,
            b.act_type ACT_TYPE,
            b.team_sr_ccs,
            b.team_sr_pps,
            b.team_sr_com,
            b.team_am_ccs,
            b.team_am_pps,
            b.team_am_def,
            null as sourcesystemid,
            lower(nvl(client_financeparent_mapping.finance_parent, a.client)) as financeparent,
            '6' as src_sys_id,
            concat('6', '_', a.client) as src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ source("adaptive_comm_sources", "plan_crev") }} a
        left outer join
    (select distinct A.CLIENT, e.ATTRIBUTE_VALUE_LEVEL_ONE_NAME finance_parent, h.ATTRIBUTE_VALUE_LEVEL_ONE_NAME salesforce_account, max(to_date(a.yearmonth, 'MONYYYY')) MaxRevenueYearMonth
from {{ source("adaptive_comm_sources", "plan_crev") }} a
inner join {{ source("adaptive_comm_sources", "dimensions") }} d on (a.CLIENT = d.DIMENSION_VALUE_NAME and d.ATTRIBUTE_NAME = 'Parent -Finance')
inner join {{ source("adaptive_comm_sources", "HIERARCHY_ATTRIBUTES") }} e on (d.attribute_id = e.attribute_id and d.ATTRIBUTE_VALUE_ID = e.product_id)
left outer join {{ source("adaptive_comm_sources", "dimensions") }} g on (a.Client = g.DIMENSION_VALUE_NAME and g.ATTRIBUTE_NAME = 'Account Name ID')
left outer join {{ source("adaptive_comm_sources", "HIERARCHY_ATTRIBUTES") }} h on (g.attribute_id = h.attribute_id and g.ATTRIBUTE_VALUE_ID = h.product_id)
where A.CLIENT not in ('2023 New Sales', '2022 New Sales', 'Uptake', 'NSA - 2023 Plan', 'Operational Initiatives','NSA - 2022 Plan', 'Operational Initiatives - Go Get', 'Client (Uncategorized)')     
group by A.CLIENT, e.ATTRIBUTE_VALUE_LEVEL_ONE_NAME, h.ATTRIBUTE_VALUE_LEVEL_ONE_NAME
order by A.CLIENT, e.ATTRIBUTE_VALUE_LEVEL_ONE_NAME, h.ATTRIBUTE_VALUE_LEVEL_ONE_NAME) client_financeparent_mapping
left outer join {{ source("salesforce_sources", "account") }} account on ((trim(case when contains(right(salesforce_account,7),'A-')=TRUE then right(salesforce_account,7) else 'UNKNOWN' end)=account.ACCOUNT_ID__C))
left outer join {{ source("salesforce_sources", "account") }} AccountParent on (coalesce(account.PARENTID, account.ID) = AccountParent.ID)                    
on a.client = client_financeparent_mapping.client
left outer join {{ source("adaptive_comm_sources", "client_salesforceid_mapping") }} csm
on a.client = csm.client_name
left outer join {{ ref("stg_account_hierarchy") }} b
on csm.salesforce_id = b.act_id
left outer join {{ source("adaptive_comm_sources", "client_financeparent_mapping") }} cfm 
on lower(trim(cfm.client)) = lower(trim(a.client))

union

        select distinct
            null as srcclientkey,
            null as clid,
            nvl(REGEXP_SUBSTR(SUBSTRING(a.client, LENGTH(a.client) - POSITION('-' IN REVERSE(a.client)) + 2), '\\d+'), REGEXP_SUBSTR(a.client, '\\d+')) AS clientnumber,
            a.client as clientname,
            nvl(cfm.FINANCE_PARENT,a.client) as clientparentname,
            coalesce(AccountParent.ID,b.act_parent_unid) ACT_PARENT_UNID,
            coalesce(AccountParent.ACCOUNT_ID__C,b.act_parent_id) ACT_PARENT_ID,
            coalesce(AccountParent.NAME,b.act_parent_name) ACT_PARENT_NAME,
            coalesce(account.ID,b.act_unid) ACT_UNID,
            coalesce(account.ACCOUNT_ID__C,b.act_id) ACT_ID,
            coalesce(account.NAME,b.act_name) ACT_NAME,
            coalesce(account.ZELIS_STATUS__C,b.act_zelis_status) ACT_ZELIS_STATUS,
            b.act_active,
            b.act_create_date,
            b.act_type ACT_TYPE,
            b.team_sr_ccs,
            b.team_sr_pps,
            b.team_sr_com,
            b.team_am_ccs,
            b.team_am_pps,
            b.team_am_def,
            null as sourcesystemid,
            lower(nvl(client_financeparent_mapping.finance_parent, a.client)) as financeparent,
            '6' as src_sys_id,
            concat('6', '_', a.client) as src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ source("adaptive_comm_sources", "forecast_crev") }} a
        left outer join
    (select distinct A.CLIENT, e.ATTRIBUTE_VALUE_LEVEL_ONE_NAME finance_parent, h.ATTRIBUTE_VALUE_LEVEL_ONE_NAME salesforce_account, max(to_date(a.yearmonth, 'MONYYYY')) MaxRevenueYearMonth
from {{ source("adaptive_comm_sources", "forecast_crev") }} a
inner join {{ source("adaptive_comm_sources", "dimensions") }} d on (a.CLIENT = d.DIMENSION_VALUE_NAME and d.ATTRIBUTE_NAME = 'Parent -Finance')
inner join {{ source("adaptive_comm_sources", "HIERARCHY_ATTRIBUTES") }} e on (d.attribute_id = e.attribute_id and d.ATTRIBUTE_VALUE_ID = e.product_id)
left outer join {{ source("adaptive_comm_sources", "dimensions") }} g on (a.Client = g.DIMENSION_VALUE_NAME and g.ATTRIBUTE_NAME = 'Account Name ID')
left outer join {{ source("adaptive_comm_sources", "HIERARCHY_ATTRIBUTES") }} h on (g.attribute_id = h.attribute_id and g.ATTRIBUTE_VALUE_ID = h.product_id)
where A.CLIENT not in ('2023 New Sales', '2022 New Sales', 'Uptake', 'NSA - 2023 Plan', 'Operational Initiatives','NSA - 2022 Plan', 'Operational Initiatives - Go Get', 'Client (Uncategorized)')     
group by A.CLIENT, e.ATTRIBUTE_VALUE_LEVEL_ONE_NAME, h.ATTRIBUTE_VALUE_LEVEL_ONE_NAME
order by A.CLIENT, e.ATTRIBUTE_VALUE_LEVEL_ONE_NAME, h.ATTRIBUTE_VALUE_LEVEL_ONE_NAME) client_financeparent_mapping
left outer join {{ source("salesforce_sources", "account") }} account on ((trim(case when contains(right(salesforce_account,7),'A-')=TRUE then right(salesforce_account,7) else 'UNKNOWN' end)=account.ACCOUNT_ID__C))
left outer join {{ source("salesforce_sources", "account") }} AccountParent on (coalesce(account.PARENTID, account.ID) = AccountParent.ID)                    
            on a.client = client_financeparent_mapping.client
        left outer join {{ source("adaptive_comm_sources", "client_salesforceid_mapping") }} csm
            on a.client = csm.client_name
        left outer join {{ ref("stg_account_hierarchy") }} b
            on csm.salesforce_id = b.act_id
		left outer join {{ source("adaptive_comm_sources", "client_financeparent_mapping") }} cfm 
            on lower(trim(cfm.client)) = lower(trim(a.client))

union

        select distinct
           null as srcclientkey,
            null as clid,
            nvl(REGEXP_SUBSTR(SUBSTRING(dcs.payor, LENGTH(dcs.payor) - POSITION('-' IN REVERSE(dcs.payor)) + 2), '\\d+'), REGEXP_SUBSTR(dcs.payor, '\\d+')) AS clientnumber,
            dcs.payor as clientname,
            nvl(cfm.FINANCE_PARENT,dcs.payor) as clientparentname,
            coalesce(AccountParent.ID,b.act_parent_unid) ACT_PARENT_UNID,
            coalesce(AccountParent.ACCOUNT_ID__C,b.act_parent_id) ACT_PARENT_ID,
            coalesce(AccountParent.NAME,b.act_parent_name) ACT_PARENT_NAME,
            coalesce(account.ID,b.act_unid) ACT_UNID,
            coalesce(account.ACCOUNT_ID__C,b.act_id) ACT_ID,
            coalesce(account.NAME,b.act_name) ACT_NAME,
            coalesce(account.ZELIS_STATUS__C,b.act_zelis_status) ACT_ZELIS_STATUS,
            b.act_active,
            b.act_create_date,
            b.act_type ACT_TYPE,
            b.team_sr_ccs,
            b.team_sr_pps,
            b.team_sr_com,
            b.team_am_ccs,
            b.team_am_pps,
            b.team_am_def,
            null as sourcesystemid,
            lower(nvl(client_financeparent_mapping.finance_parent, dcs.payor)) as financeparent,
            '6' as src_sys_id,
            concat('6', '_', dcs.payor) as src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ source("ch_reference_sources", "CH_MONTHLY_BUDGET") }} dcs
        left outer join
            (select distinct a.payor CLIENT, e.ATTRIBUTE_VALUE_LEVEL_ONE_NAME finance_parent, h.ATTRIBUTE_VALUE_LEVEL_ONE_NAME salesforce_account, max(a.REV_PLAN_DATE) MaxRevenueYearMonth
from {{ source("ch_reference_sources", "CH_MONTHLY_BUDGET") }} a
inner join {{ source("adaptive_comm_sources", "dimensions") }} d on (a.payor = d.DIMENSION_VALUE_NAME and d.ATTRIBUTE_NAME = 'Parent -Finance')
inner join {{ source("adaptive_comm_sources", "HIERARCHY_ATTRIBUTES") }} e on (d.attribute_id = e.attribute_id and d.ATTRIBUTE_VALUE_ID = e.product_id)
left outer join {{ source("adaptive_comm_sources", "dimensions") }} g on (a.payor = g.DIMENSION_VALUE_NAME and g.ATTRIBUTE_NAME = 'Account Name ID')
left outer join {{ source("adaptive_comm_sources", "HIERARCHY_ATTRIBUTES") }} h on (g.attribute_id = h.attribute_id and g.ATTRIBUTE_VALUE_ID = h.product_id)
group by a.payor, e.ATTRIBUTE_VALUE_LEVEL_ONE_NAME, h.ATTRIBUTE_VALUE_LEVEL_ONE_NAME
order by a.payor, e.ATTRIBUTE_VALUE_LEVEL_ONE_NAME, h.ATTRIBUTE_VALUE_LEVEL_ONE_NAME) client_financeparent_mapping
            on dcs.payor = client_financeparent_mapping.client
left outer join {{ source("salesforce_sources", "account") }} account on ((trim(case when contains(right(salesforce_account,7),'A-')=TRUE then right(salesforce_account,7) else 'UNKNOWN' end)=account.ACCOUNT_ID__C))
left outer join {{ source("salesforce_sources", "account") }} AccountParent on (coalesce(account.PARENTID, account.ID) = AccountParent.ID)                    
        left outer join {{ source("adaptive_comm_sources", "client_salesforceid_mapping") }} csm
            on dcs.payor = csm.client_name
        left outer join {{ ref("stg_account_hierarchy") }} b
            on csm.salesforce_id = b.act_id   
      	left outer join {{ source("adaptive_comm_sources", "client_financeparent_mapping") }} cfm 
            on lower(trim(cfm.client)) = lower(trim(dcs.payor))
        where
            dcs.rev_plan_date >= date_trunc('YEAR', dateadd(year, -4, getdate()))
            and dcs.payor not in ('2023 New Sales','Uptake', 'NSA - 2023 Plan','Operational Initiatives', 'Operational Initiatives - Go Get', '2022 New Sales', '(Inactive Client)')       

UNION

select distinct
           null as srcclientkey,
            null as clid,
             nvl(REGEXP_SUBSTR(SUBSTRING(a.client, LENGTH(a.client) - POSITION('-' IN REVERSE(a.client)) + 2), '\\d+'), REGEXP_SUBSTR(a.client, '\\d+')) AS clientnumber,
            a.client as clientname,
            nvl(cfm.FINANCE_PARENT,a.client) as clientparentname,
            coalesce(AccountParent.ID,b.act_parent_unid) ACT_PARENT_UNID,
            coalesce(AccountParent.ACCOUNT_ID__C,b.act_parent_id) ACT_PARENT_ID,
            coalesce(AccountParent.NAME,b.act_parent_name) ACT_PARENT_NAME,
            coalesce(account.ID,b.act_unid) ACT_UNID,
            coalesce(account.ACCOUNT_ID__C,b.act_id) ACT_ID,
            coalesce(account.NAME,b.act_name) ACT_NAME,
            coalesce(account.ZELIS_STATUS__C,b.act_zelis_status) ACT_ZELIS_STATUS,
            b.act_active,
            b.act_create_date,
            b.act_type ACT_TYPE,
            b.team_sr_ccs,
            b.team_sr_pps,
            b.team_sr_com,
            b.team_am_ccs,
            b.team_am_pps,
            b.team_am_def,
            null as sourcesystemid,
            lower(nvl(client_financeparent_mapping.finance_parent, a.client)) as financeparent,
            '6' as src_sys_id,
            concat('6', '_', a.client) as src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ source("adaptive_comm_sources", "plan_rev") }} a
        left outer join
    (select distinct A.CLIENT, e.ATTRIBUTE_VALUE_LEVEL_ONE_NAME finance_parent, h.ATTRIBUTE_VALUE_LEVEL_ONE_NAME salesforce_account, max(to_date(a.yearmonth, 'MONYYYY')) MaxRevenueYearMonth
from {{ source("adaptive_comm_sources", "plan_rev") }} a
inner join {{ source("adaptive_comm_sources", "dimensions") }} d on (a.CLIENT = d.DIMENSION_VALUE_NAME and d.ATTRIBUTE_NAME = 'Parent -Finance')
inner join {{ source("adaptive_comm_sources", "HIERARCHY_ATTRIBUTES") }} e on (d.attribute_id = e.attribute_id and d.ATTRIBUTE_VALUE_ID = e.product_id)
left outer join {{ source("adaptive_comm_sources", "dimensions") }} g on (a.Client = g.DIMENSION_VALUE_NAME and g.ATTRIBUTE_NAME = 'Account Name ID')
left outer join {{ source("adaptive_comm_sources", "HIERARCHY_ATTRIBUTES") }} h on (g.attribute_id = h.attribute_id and g.ATTRIBUTE_VALUE_ID = h.product_id)
where A.CLIENT not in ('2023 New Sales', '2022 New Sales', 'Uptake', 'NSA - 2023 Plan', 'Operational Initiatives','NSA - 2022 Plan', 'Operational Initiatives - Go Get', 'Client (Uncategorized)')     
group by A.CLIENT, e.ATTRIBUTE_VALUE_LEVEL_ONE_NAME, h.ATTRIBUTE_VALUE_LEVEL_ONE_NAME
order by A.CLIENT, e.ATTRIBUTE_VALUE_LEVEL_ONE_NAME, h.ATTRIBUTE_VALUE_LEVEL_ONE_NAME) client_financeparent_mapping
left outer join {{ source("salesforce_sources", "account") }} account on ((trim(case when contains(right(salesforce_account,7),'A-')=TRUE then right(salesforce_account,7) else 'UNKNOWN' end)=account.ACCOUNT_ID__C))
left outer join {{ source("salesforce_sources", "account") }} AccountParent on (coalesce(account.PARENTID, account.ID) = AccountParent.ID)                    
on a.client = client_financeparent_mapping.client
left outer join {{ source("adaptive_comm_sources", "client_salesforceid_mapping") }} csm on a.client = csm.client_name
left outer join {{ ref("stg_account_hierarchy") }} b on csm.salesforce_id = b.act_id
left outer join {{ source("adaptive_comm_sources", "client_financeparent_mapping") }} cfm 
on lower(trim(cfm.client)) = lower(trim(a.client))
where A.CLIENT not in ('Operational Initiatives - Go Get', 'Operational Initiatives') 

UNION

select distinct
            null as srcclientkey,
            null as clid,
             nvl(REGEXP_SUBSTR(SUBSTRING(a.client, LENGTH(a.client) - POSITION('-' IN REVERSE(a.client)) + 2), '\\d+'), REGEXP_SUBSTR(a.client, '\\d+')) AS clientnumber,
            a.client as clientname,
            nvl(cfm.FINANCE_PARENT,a.client) as clientparentname,
            coalesce(AccountParent.ID,b.act_parent_unid) ACT_PARENT_UNID,
            coalesce(AccountParent.ACCOUNT_ID__C,b.act_parent_id) ACT_PARENT_ID,
            coalesce(AccountParent.NAME,b.act_parent_name) ACT_PARENT_NAME,
            coalesce(account.ID,b.act_unid) ACT_UNID,
            coalesce(account.ACCOUNT_ID__C,b.act_id) ACT_ID,
            coalesce(account.NAME,b.act_name) ACT_NAME,
            coalesce(account.ZELIS_STATUS__C,b.act_zelis_status) ACT_ZELIS_STATUS,
            b.act_active,
            b.act_create_date,
            b.act_type ACT_TYPE,
            b.team_sr_ccs,
            b.team_sr_pps,
            b.team_sr_com,
            b.team_am_ccs,
            b.team_am_pps,
            b.team_am_def,
            null as sourcesystemid,
            lower(nvl(client_financeparent_mapping.finance_parent, a.client)) as financeparent,
            '6' as src_sys_id,
            concat('6', '_', a.client) as src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ source("adaptive_comm_sources", "forecast_rev") }} a
        left outer join
    (select distinct A.CLIENT, e.ATTRIBUTE_VALUE_LEVEL_ONE_NAME finance_parent, h.ATTRIBUTE_VALUE_LEVEL_ONE_NAME salesforce_account, max(to_date(a.yearmonth, 'MONYYYY')) MaxRevenueYearMonth
from {{ source("adaptive_comm_sources", "forecast_rev") }} a
inner join {{ source("adaptive_comm_sources", "dimensions") }} d on (a.CLIENT = d.DIMENSION_VALUE_NAME and d.ATTRIBUTE_NAME = 'Parent -Finance')
inner join {{ source("adaptive_comm_sources", "HIERARCHY_ATTRIBUTES") }} e on (d.attribute_id = e.attribute_id and d.ATTRIBUTE_VALUE_ID = e.product_id)
left outer join {{ source("adaptive_comm_sources", "dimensions") }} g on (a.Client = g.DIMENSION_VALUE_NAME and g.ATTRIBUTE_NAME = 'Account Name ID')
left outer join {{ source("adaptive_comm_sources", "HIERARCHY_ATTRIBUTES") }} h on (g.attribute_id = h.attribute_id and g.ATTRIBUTE_VALUE_ID = h.product_id)
where A.CLIENT not in ('2023 New Sales', '2022 New Sales', 'Uptake', 'NSA - 2023 Plan', 'Operational Initiatives','NSA - 2022 Plan', 'Operational Initiatives - Go Get', 'Client (Uncategorized)')     
group by A.CLIENT, e.ATTRIBUTE_VALUE_LEVEL_ONE_NAME, h.ATTRIBUTE_VALUE_LEVEL_ONE_NAME
order by A.CLIENT, e.ATTRIBUTE_VALUE_LEVEL_ONE_NAME, h.ATTRIBUTE_VALUE_LEVEL_ONE_NAME) client_financeparent_mapping
left outer join {{ source("salesforce_sources", "account") }} account on ((trim(case when contains(right(salesforce_account,7),'A-')=TRUE then right(salesforce_account,7) else 'UNKNOWN' end)=account.ACCOUNT_ID__C))
left outer join {{ source("salesforce_sources", "account") }} AccountParent on (coalesce(account.PARENTID, account.ID) = AccountParent.ID)                    
on a.client = client_financeparent_mapping.client
left outer join {{ source("adaptive_comm_sources", "client_salesforceid_mapping") }} csm on a.client = csm.client_name
left outer join {{ ref("stg_account_hierarchy") }} b on csm.salesforce_id = b.act_id
left outer join {{ source("adaptive_comm_sources", "client_financeparent_mapping") }} cfm 
on lower(trim(cfm.client)) = lower(trim(a.client))
where A.CLIENT not in ('Operational Initiatives - Go Get', 'Operational Initiatives') 
    )
select *
from stg_adaptive_client