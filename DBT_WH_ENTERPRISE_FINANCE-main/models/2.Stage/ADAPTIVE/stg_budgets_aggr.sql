{{ config(materialized="table", tags=["monthly"]) }}

with
    stg_budgets_aggr as (
        select
            dcs.payor as client,
            monthdate.dateday as tranyearmonthdate,
            case when dcs.product_subgroup = 'Bill Review and Audit' then 'HBR'
            when dcs.product_subgroup = 'Claim Edit' then 'Claim Editing'
            when dcs.product_subgroup = 'Communications' then 'Communication-Product'
            when dcs.product_subgroup = 'Communications SAAS' then 'SAAS'
            when dcs.product_subgroup = 'Enrollment' then 'Enrollment-Product'
            when dcs.product_subgroup = 'PPO Networks' then 'PPO' else product_subgroup end 
            as producttype,
            6 as src_sys_id,
            case when dcs.PRODUCT_GRP in ('OON', 'EDITING', 'BILL REVIEW & AUDIT') then '1'
            when dcs.PRODUCT_GRP in ('ID CARDS', 'CHECK/EOB') then '3'
            when dcs.PRODUCT_GRP = 'PAYMENTS' then '2' else '-1' end as businessunit,            
            concat(src_sys_id, '_', client) as srcuniqcd_dim_client,
            concat('7', '_', producttype) as srcuniqcd_dim_product_type,
            concat('7', '_', src_sys_id) as srcuniqcd_dim_source_system,
            concat('7', '_', businessunit) as srcuniqcd_dim_business_unit,
            min(ptfmn.ptfm_min_dt) as ptfm_min_dt,
            sum(dcs.rev_plan_plan) as rev_plan_plan

        from {{ source("ch_reference_sources", "CH_MONTHLY_BUDGET") }} dcs
        inner join
            {{ source("caidwh_sources", "dimdate") }} monthdate
            on (
                dateadd(day, ((-1 * day(dcs.rev_plan_date)) + 1), dcs.rev_plan_date)
                = monthdate.dateday
            )
        left join
            (
                select payor, min(rev_plan_date) as ptfm_min_dt
                from {{ source("ch_reference_sources", "CH_MONTHLY_BUDGET") }}
                where rev_plan_date <> '2000-01-01'
                group by payor
            ) ptfmn
            on dcs.payor = ptfmn.payor

        where
          
             tranyearmonthdate >= date_trunc('YEAR', dateadd(year, -4, getdate())) and tranyearmonthdate < '2023-01-01'
        group by
            client,
            tranyearmonthdate,
            producttype,
            src_sys_id,
            businessunit,
            srcuniqcd_dim_client,
            srcuniqcd_dim_product_type,
            srcuniqcd_dim_source_system,
            srcuniqcd_dim_business_unit

union
        select
            dcs.payor as client,
            monthdate.dateday as tranyearmonthdate,
            dcs.product_subgroup producttype,
            6 as src_sys_id,
            case when producttype.PRODUCT_TYPE_CATEGORY in ('% of Saving Products', 'PayerCompass + NR') then '1'
            when (producttype.PRODUCT_TYPE_CATEGORY in( 'Network Solutions Products') and producttype.PRODUCT_TYPE='Primary') then '1' 
            when producttype.PRODUCT_TYPE_CATEGORY in ('ID CARDS', 'CHECK/EOB') then '3'
            when producttype.PRODUCT_TYPE_CATEGORY in ('Payments/Comms','PayerSponsored','e-Pay') and producttype.product not in ('PRD0038 Enrollment', 'PRD0039 Member Communications', 'PRD0043 Other Revenue') then '2' 
            when producttype.PRODUCT_TYPE_CATEGORY = 'Payments/Comms' and producttype.product in ('PRD0038 Enrollment', 'PRD0039 Member Communications', 'PRD0043 Other Revenue') then '3' 
            when producttype.PRODUCT_TYPE_CATEGORY in( 'Sapphire Digital Products') then '4' 
            when (producttype.PRODUCT_TYPE_CATEGORY in( 'Network Solutions Products') and producttype.PRODUCT_TYPE='ZNA') then '4' else '-1' end as businessunit,  
            concat(src_sys_id, '_', client) as srcuniqcd_dim_client,
            concat('7', '_', producttype) as srcuniqcd_dim_product_type,
            concat('7', '_', src_sys_id) as srcuniqcd_dim_source_system,
            concat('7', '_', businessunit) as srcuniqcd_dim_business_unit,
            min(ptfmn.ptfm_min_dt) as ptfm_min_dt,
            sum(dcs.rev_plan_plan) as rev_plan_plan

        from {{ source("ch_reference_sources", "CH_MONTHLY_BUDGET") }} dcs
        inner join
            {{ source("caidwh_sources", "dimdate") }} monthdate
            on (
                dateadd(day, ((-1 * day(dcs.rev_plan_date)) + 1), dcs.rev_plan_date)
                = monthdate.dateday
            )
        left join
            (
                select payor, min(rev_plan_date) as ptfm_min_dt
                from {{ source("ch_reference_sources", "CH_MONTHLY_BUDGET") }}
                where rev_plan_date <> '2000-01-01'
                group by payor
            ) ptfmn
            on dcs.payor = ptfmn.payor
        left outer join
            {{ source("cons_sources", "ref_producttype") }} producttype
            on (dcs.product_subgroup = producttype.product)

        where tranyearmonthdate >= '2023-01-01'
           
        group by
            client,
            tranyearmonthdate,
            producttype,
            src_sys_id,
            businessunit,
            srcuniqcd_dim_client,
            srcuniqcd_dim_product_type,
            srcuniqcd_dim_source_system,
            srcuniqcd_dim_business_unit
    )
select *
from stg_budgets_aggr
