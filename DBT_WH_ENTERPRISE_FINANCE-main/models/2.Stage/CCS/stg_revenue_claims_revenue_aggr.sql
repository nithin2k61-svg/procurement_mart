{{ config(materialized="table", tags=["monthly"]) }}

with
    stg_revenue_claims_revenue_aggr as (
        select
            fj.cmid,
            dc.dimclientkey,
            case when dsch.product in ('PPO Network') and dsch.in_oon = 'OON' then 'PPO'
                when dsch.product in ('Negotiations') and dsch.in_oon = 'OON' then 'Negotiations'
                when dsch.product in ('RBP') and dsch.in_oon = 'OON' then 'RBP'
                when dsch.product = 'Expert Claims Review' then 'HBR'
                when dsch.product = 'Editing' then 'Claim Editing'
                else 'Unknown'
            end as product_type,
            monthdate.dateday as tranyearmonth,
            '1' as src_sys_id,
            '1' as businessunit,
            min(ptfmn.ptfm_min_dt) as ptfm_min_dt,
            coalesce(sum(fj.revenuegross), 0.00) revenue_amount,
            coalesce(sum(fj.cmallowedhit), 0.00) cmallowedhit,
            coalesce(sum(fj.claimcountrepriced), 0.00) claimcountrepriced,
            coalesce(sum(fj.savingsgross), 0.00) savingsgross

        from {{ source("caidwh_sources", "factjournal") }} fj
        inner join
            {{ source("caidwh_sources", "dimdate") }} ddrk
            on (fj.dimdatejournalkey = ddrk.dimdatekey)
        inner join
            {{ source("caidwh_sources", "dimdate") }} monthdate
            on (
                dateadd(day, ((-1 * day(ddrk.dateday)) + 1), ddrk.dateday)
                = monthdate.dateday
            )
        inner join
            {{ source("caidwh_sources", "dimclaimeligible") }} dcs
            on (fj.dimclaimeligiblekey = dcs.dimclaimeligiblekey)
        inner join
            {{ source("caidwh_sources", "dimproduct") }} dp
            on (fj.dimproductkey = dp.dimproductkey)
        inner join
            {{ source("caidwh_sources", "dimclient") }} dc
            on (fj.dimclientkey = dc.dimclientkey)
        inner join
            {{ source("caidwh_sources", "DimSavingsChannel") }} dsch
            on (fj.dimsavingschannelkey = dsch.dimsavingschannelkey)
        inner join
            {{ source("caidwh_sources", "dimsystemofrecord") }} dsys
            on (fj.dimsystemofrecordkey = dsys.dimsystemofrecordkey)
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
            on fj.dimclientkey = ptfmn.dimclientkey

        where
            monthdate.dateyear >= 2019 and monthdate.dateday < '2023-07-01'
            and product_type in ('HBR', 'Claim Editing', 'Negotiations', 'PPO', 'RBP')
            and dsys.issystemofrecord = 'Y' and fj.sourcesystemclaimid <> 0
            and fj.del_indc = 0

        group by
            fj.cmid,
            dc.dimclientkey,
            product_type,
            tranyearmonth,
            src_sys_id,
            businessunit
union all

        select
            fj.cmid,
            dc.dimclientkey,
            case when dsch.SAVINGSCHANNELHIERARCHY_2 in ('Supplemental PPO') then 'PPO'
                when dsch.SAVINGSCHANNELHIERARCHY_2 in ('Negotiations') then 'Negotiations'
                when dsch.SAVINGSCHANNELHIERARCHY_2 in ('Reference Based Pricing') then 'RBP'
                when dsch.SAVINGSCHANNELHIERARCHY_2 in ('Hospital Bill Review') then 'HBR'
                when dsch.SAVINGSCHANNELHIERARCHY_2 in ('Claims Editing') then 'Claim Editing'
                else 'Unknown'
            end as product_type,
            monthdate.dateday as tranyearmonth,
            '1' as src_sys_id,
            '1' as businessunit,
            min(ptfmn.ptfm_min_dt) as ptfm_min_dt,
            coalesce(sum(fj.revenuegross), 0.00) revenue_amount,
            coalesce(sum(fj.cmallowedhit), 0.00) cmallowedhit,
            coalesce(sum(fj.claimcountrepriced), 0.00) claimcountrepriced,
            coalesce(sum(fj.savingsgross), 0.00) savingsgross

        from {{ source("caidwh_sources", "factjournal") }} fj
        inner join
            {{ source("caidwh_sources", "dimdate") }} ddrk
            on (fj.dimdatejournalkey = ddrk.dimdatekey)
        inner join
            {{ source("caidwh_sources", "dimdate") }} monthdate
            on (
                dateadd(day, ((-1 * day(ddrk.dateday)) + 1), ddrk.dateday)
                = monthdate.dateday
            )
        inner join
            {{ source("caidwh_sources", "dimclaimeligible") }} dcs
            on (fj.dimclaimeligiblekey = dcs.dimclaimeligiblekey)
        inner join
            {{ source("caidwh_sources", "dimproduct") }} dp
            on (fj.dimproductkey = dp.dimproductkey)
        inner join
            {{ source("caidwh_sources", "dimclient") }} dc
            on (fj.dimclientkey = dc.dimclientkey)
        inner join
            {{ source("caidwh_sources", "DimWorkdaySavingsChannel") }} dsch
            on (fj.dimworkdaysavingschannelkey = dsch.dimworkdaysavingschannelkey)
        inner join
            {{ source("caidwh_sources", "dimsystemofrecord") }} dsys
            on (fj.dimsystemofrecordkey = dsys.dimsystemofrecordkey)
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
            on fj.dimclientkey = ptfmn.dimclientkey

        where
            monthdate.dateday >= '2023-07-01'
            and product_type in ('HBR', 'Claim Editing', 'Negotiations', 'PPO', 'RBP')
            and dsys.issystemofrecord = 'Y' and fj.sourcesystemclaimid <> 0
            and fj.del_indc = 0

        group by
            fj.cmid,
            dc.dimclientkey,
            product_type,
            tranyearmonth,
            src_sys_id,
            businessunit
    )
select *
from stg_revenue_claims_revenue_aggr
