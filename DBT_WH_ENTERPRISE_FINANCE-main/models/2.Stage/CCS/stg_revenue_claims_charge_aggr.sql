{{ config(materialized="table", tags=["monthly"]) }}

with
    stg_revenue_claims_charge_aggr as (
        select
            fc.cmid,
            dc.dimclientkey,
            case
                when dsch.product in ('PPO Network') and dsch.in_oon = 'OON' then 'PPO'
                when dsch.product in ('Negotiations') and dsch.in_oon = 'OON' then 'Negotiations'
                when dsch.product in ('RBP') and dsch.in_oon = 'OON' then 'RBP'
                when dsch.product = 'Expert Claims Review' then 'HBR'
                when dsch.product = 'Editing' then 'Claim Editing' else 'Unknown'
            end as product_type,
            monthdate.dateday as tranyearmonth,
            '1' as src_sys_id,
            '1' as businessunit,
            min(ptfmn.ptfm_min_dt) as ptfm_min_dt,
            coalesce(sum(cmallowed), 0.00) as charged_amount,
            coalesce(sum(claimcount), 0.00) as claimcount,
            coalesce(sum(cmcharges), 0.00) as cmcharges,
            coalesce(sum(claimcountisdisputed), 0.00) as claimcountisdisputed

        from {{ source("caidwh_sources", "factclaim") }} fc
        inner join
            {{ source("caidwh_sources", "dimclaimeligible") }} dcs
            on (fc.dimclaimeligiblekey = dcs.dimclaimeligiblekey)
        inner join
            {{ source("caidwh_sources", "dimdate") }} ddrk
            on (fc.dimdatereceivedkey = ddrk.dimdatekey)
        inner join
            {{ source("caidwh_sources", "dimdate") }} monthdate
            on (
                dateadd(day, ((-1 * day(ddrk.dateday)) + 1), ddrk.dateday)
                = monthdate.dateday
            )
        inner join
            {{ source("caidwh_sources", "dimproduct") }} dp
            on (fc.dimproductkey = dp.dimproductkey)
            
        inner join
            {{ source("caidwh_sources", "dimclient") }} dc
            on (fc.dimclientkey = dc.dimclientkey)
         
           
        inner join
            {{ source("caidwh_sources", "DimSavingsChannel") }} dsch
            on (fc.dimsavingschannelkey = dsch.dimsavingschannelkey)
        inner join
            {{ source("caidwh_sources", "dimsystemofrecord") }} dsys
            on (fc.dimsystemofrecordkey = dsys.dimsystemofrecordkey)
        left join
            (
                select fc.dimclientkey, min(dd.dateday) as ptfm_min_dt
                from {{ source("caidwh_sources", "factclaim") }} fc
                inner join
                    {{ source("caidwh_sources", "dimdate") }} dd
                    on dd.dimdatekey = fc.dimdatereceivedkey
                where fc.del_indc = 0
                and dd.dateday <> '2000-01-01'
                group by fc.dimclientkey
            ) ptfmn
            on fc.dimclientkey = ptfmn.dimclientkey

        where
             dcs.DimClaimEligibleKey = 1
            and monthdate.dateyear >= 2020
            and product_type in ('HBR', 'Claim Editing', 'Negotiations', 'PPO', 'RBP')
            and dp.subproduct not in ('Savings -No Invoice', 'Medrouter', 'Directional PEPM','Unknown')
            and  dc.company not in ('GlobalCare, Inc.', 'PPOPlus', 'PHX West', 'HFN', 'AMCO' )
            and dsys.DimSystemOfRecordKey = 2
            and fc.sourcesystemclaimid <> 0
            and fc.del_indc = 0

        group by
            fc.cmid,
            dc.dimclientkey,
            product_type,
            tranyearmonth,
            src_sys_id,
            businessunit
    )
select *
from stg_revenue_claims_charge_aggr
