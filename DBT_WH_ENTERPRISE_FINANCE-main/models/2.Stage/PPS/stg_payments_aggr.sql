{{ config(materialized="table", tags=["monthly"]) }}

with
    stg_payments_aggr as (
        select
            pps.payerid as client,
            pps.calendardate as tranyearmonthdate,
            pps.product_grp producttype,
            2 as src_sys_id,
            '2' as businessunit,
            concat(src_sys_id, '_', client) as srcuniqcd_dim_client,
            concat('7', '_', producttype) as srcuniqcd_dim_product_type,
            concat('7', '_', src_sys_id) as srcuniqcd_dim_source_system,
            concat('7', '_', businessunit) as srcuniqcd_dim_business_unit,
            min(pps.ptfm_min_dt) as ptfm_min_dt,
            sum(pps.pps_count) as pps_count,
            sum(pps.pps_amount) as pps_amount,
            sum(ppp.extracted_count) / sum(ppp.gross_payment_count) as pps_adopt_rate
        from
            (
                select
                    fep.payerid,
                    pdt.ptfm_min_dt,
                    md.calendardate,
                    'VCC' as product_grp,
                    sum(
                        select_print_count + select_download_count + select_fax_count
                    ) as pps_count,
                    sum(
                        select_print_amount + select_download_amount + select_fax_amount
                    ) as pps_amount
                from
                    {{ source("ppswh_ext_sources", "FactDailyExtractedPayments") }}
                    as fep
                inner join
                    {{ source("ppswh_dbo_sources", "DIMDATE") }} as dd
                    on dd.datekey = fep.prepassdatekey
                inner join
                    {{ source("ppswh_dbo_sources", "DIMDATE") }} as md
                    on (
                        dateadd(day, ((-1 * day(dd.calendardate)) + 1), dd.calendardate)
                        = md.calendardate
                    )
                inner join
                    (
                        select fep.payerid, min(dd.calendardate) as ptfm_min_dt
                        from
                            {{
                                source(
                                    "ppswh_ext_sources", "FactDailyExtractedPayments"
                                )
                            }} as fep
                        inner join
                            {{ source("ppswh_dbo_sources", "DIMDATE") }} as dd
                            on dd.datekey = fep.prepassdatekey
                        where dd.calendardate <> '2000-01-01'
                        group by fep.payerid
                    ) as pdt
                    on (pdt.payerid = fep.payerid)
                group by fep.payerid, pdt.ptfm_min_dt, md.calendardate, product_grp

                union all

                select
                    fep.payerid,
                    pdt.ptfm_min_dt,
                    md.calendardate,
                    'PayerSponsored' as product_grp,
                    sum(
                        case
                            when fep.entitytypeid = 6
                            then vra_direct_count + vra_direct_epc_count
                            else 0
                        end
                    ) as pps_count,
                    sum(
                        case
                            when fep.entitytypeid = 6
                            then vra_direct_amount + vra_direct_epc_amount
                            else 0
                        end
                    ) as pps_amount
                from
                    {{ source("ppswh_ext_sources", "FactDailyExtractedPayments") }}
                    as fep
                inner join
                    {{ source("ppswh_dbo_sources", "DIMDATE") }} as dd
                    on dd.datekey = fep.prepassdatekey
                inner join
                    {{ source("ppswh_dbo_sources", "DIMDATE") }} as md
                    on (
                        dateadd(day, ((-1 * day(dd.calendardate)) + 1), dd.calendardate)
                        = md.calendardate
                    )
                inner join
                    (
                        select fep.payerid, min(dd.calendardate) as ptfm_min_dt
                        from
                            {{
                                source(
                                    "ppswh_ext_sources", "FactDailyExtractedPayments"
                                )
                            }} as fep
                        inner join
                            {{ source("ppswh_dbo_sources", "DIMDATE") }} as dd
                            on dd.datekey = fep.prepassdatekey
                        where dd.calendardate <> '2000-01-01'                            
                        group by fep.payerid
                    ) as pdt
                    on (pdt.payerid = fep.payerid)
                group by fep.payerid, pdt.ptfm_min_dt, md.calendardate, product_grp

                union all

                select
                    fep.payerid,
                    pdt.ptfm_min_dt,
                    md.calendardate,
                    'PayerBrandedVCC' as product_grp,
                    sum(vra_card_count) as pps_count,
                    sum(vra_card_amount) as pps_amount
                from
                    {{ source("ppswh_ext_sources", "FactDailyExtractedPayments") }}
                    as fep
                inner join
                    {{ source("ppswh_dbo_sources", "DIMDATE") }} as dd
                    on dd.datekey = fep.prepassdatekey
                inner join
                    {{ source("ppswh_dbo_sources", "DIMDATE") }} as md
                    on (
                        dateadd(day, ((-1 * day(dd.calendardate)) + 1), dd.calendardate)
                        = md.calendardate
                    )
                inner join
                    (
                        select fep.payerid, min(dd.calendardate) as ptfm_min_dt
                        from
                            {{
                                source(
                                    "ppswh_ext_sources", "FactDailyExtractedPayments"
                                )
                            }} as fep
                        inner join
                            {{ source("ppswh_dbo_sources", "DIMDATE") }} as dd
                            on dd.datekey = fep.prepassdatekey
                        where dd.calendardate <> '2000-01-01'                                                        
                        group by fep.payerid
                    ) as pdt
                    on (pdt.payerid = fep.payerid)
                group by fep.payerid, pdt.ptfm_min_dt, md.calendardate, product_grp

                union all

                select
                    fep.payerid,
                    pdt.ptfm_min_dt,
                    md.calendardate,
                    'ACH+' as product_grp,
                    sum(
                        case when fep.entitytypeid = 6 then vra_direct_count else 0 end
                    ) as pps_count,
                    sum(
                        case when fep.entitytypeid = 6 then vra_direct_amount else 0 end
                    ) as pps_amount
                from
                    {{ source("ppswh_ext_sources", "FactDailyExtractedPayments") }}
                    as fep
                inner join
                    {{ source("ppswh_dbo_sources", "DIMDATE") }} as dd
                    on dd.datekey = fep.prepassdatekey
                inner join
                    {{ source("ppswh_dbo_sources", "DIMDATE") }} as md
                    on (
                        dateadd(day, ((-1 * day(dd.calendardate)) + 1), dd.calendardate)
                        = md.calendardate
                    )
                inner join
                    (
                        select fep.payerid, min(dd.calendardate) as ptfm_min_dt
                        from
                            {{
                                source(
                                    "ppswh_ext_sources", "FactDailyExtractedPayments"
                                )
                            }} as fep
                        inner join
                            {{ source("ppswh_dbo_sources", "DIMDATE") }} as dd
                            on dd.datekey = fep.prepassdatekey
                        where dd.calendardate <> '2000-01-01'                                                        
                        group by fep.payerid
                    ) as pdt
                    on (pdt.payerid = fep.payerid)
                group by fep.payerid, pdt.ptfm_min_dt, md.calendardate, product_grp

                union all

                select
                    fpp.payerid,
                    pdt.ptfm_min_dt,
                    md.calendardate,
                    'Check' as product_grp,
                    sum(
                        exclude_payer_tin_count
                        + exclude_group_count
                        + exclude_payer_tin_count
                        + exclude_bankaccount_count
                        + non_qualified_count
                        + missingprepass_count
                        + small_payment_count
                        + otherfilters_count
                    ) as pps_count,
                    sum(
                        exclude_payer_tin_amount
                        + exclude_group_amount
                        + exclude_payer_tin_amount
                        + exclude_bankaccount_amount
                        + non_qualified_amount
                        + missingprepass_amount
                        + small_payment_amount
                        + otherfilters_amount
                    ) as pps_amount
                from
                    {{ source("ppswh_ext_sources", "FACTDAILYPREPASSPAYMENTS") }} as fpp
                inner join
                    {{ source("ppswh_dbo_sources", "DIMDATE") }} as dd
                    on dd.datekey = fpp.fileimportdatekey
                inner join
                    {{ source("ppswh_dbo_sources", "DIMDATE") }} as md
                    on (
                        dateadd(day, ((-1 * day(dd.calendardate)) + 1), dd.calendardate)
                        = md.calendardate
                    )
                inner join
                    (
                        select fpp.payerid, min(dd.calendardate) as ptfm_min_dt
                        from
                            {{
                                source(
                                    "ppswh_ext_sources", "FACTDAILYPREPASSPAYMENTS"
                                )
                            }} as fpp
                        inner join
                            {{ source("ppswh_dbo_sources", "DIMDATE") }} as dd
                            on dd.datekey = fpp.fileimportdatekey
                        where dd.calendardate <> '2000-01-01'                                                        
                        group by fpp.payerid
                    ) as pdt
                    on (pdt.payerid = fpp.payerid)
                group by fpp.payerid, pdt.ptfm_min_dt, md.calendardate, product_grp

                union all

                select
                    fep.payerid,
                    pdt.ptfm_min_dt,
                    md.calendardate,
                    'Check' as product_grp,
                    sum(paymenterror_count) as pps_count,
                    sum(paymenterror_amount) as pps_amount
                from
                    {{ source("ppswh_ext_sources", "FactDailyExtractedPayments") }}
                    as fep
                inner join
                    {{ source("ppswh_dbo_sources", "DIMDATE") }} as dd
                    on dd.datekey = fep.prepassdatekey
                inner join
                    {{ source("ppswh_dbo_sources", "DIMDATE") }} as md
                    on (
                        dateadd(day, ((-1 * day(dd.calendardate)) + 1), dd.calendardate)
                        = md.calendardate
                    )
                inner join
                    (
                        select fep.payerid, min(dd.calendardate) as ptfm_min_dt
                        from
                            {{
                                source(
                                    "ppswh_ext_sources", "FactDailyExtractedPayments"
                                )
                            }} as fep
                        inner join
                            {{ source("ppswh_dbo_sources", "DIMDATE") }} as dd
                            on dd.datekey = fep.prepassdatekey
                        where dd.calendardate <> '2000-01-01'                                                        
                        group by fep.payerid
                    ) as pdt
                    on (pdt.payerid = fep.payerid)
                group by fep.payerid, pdt.ptfm_min_dt, md.calendardate, product_grp

                union all

                select
                    fpp.payerid,
                    pdt.ptfm_min_dt,
                    md.calendardate,
                    'Check' as product_grp,
                    sum(
                        case
                            when fpp.entitytypeid = 6 then exclude_provider_count else 0
                        end
                    ) as pps_count,
                    sum(
                        case
                            when fpp.entitytypeid = 6
                            then exclude_provider_amount
                            else 0
                        end
                    ) as pps_amount
                from
                    {{ source("ppswh_ext_sources", "FACTDAILYPREPASSPAYMENTS") }} as fpp
                inner join
                    {{ source("ppswh_dbo_sources", "DIMDATE") }} as dd
                    on dd.datekey = fpp.fileimportdatekey
                inner join
                    {{ source("ppswh_dbo_sources", "DIMDATE") }} as md
                    on (
                        dateadd(day, ((-1 * day(dd.calendardate)) + 1), dd.calendardate)
                        = md.calendardate
                    )
                inner join
                    (
                        select fpp.payerid, min(dd.calendardate) as ptfm_min_dt
                        from
                            {{
                                source(
                                    "ppswh_ext_sources", "FACTDAILYPREPASSPAYMENTS"
                                )
                            }} as fpp
                        inner join
                            {{ source("ppswh_dbo_sources", "DIMDATE") }} as dd
                            on dd.datekey = fpp.fileimportdatekey
                        where dd.calendardate <> '2000-01-01'                                                        
                        group by fpp.payerid
                    ) as pdt
                    on (pdt.payerid = fpp.payerid)
                group by fpp.payerid, pdt.ptfm_min_dt, md.calendardate, product_grp
            ) as pps

        left join
            (
                select
                    fpp.payerid,
                    md.calendardate,
                    sum(gross_payment_count) as gross_payment_count,
                    sum(
                        case
                            when fpp.entitytypeid = 6 then fpp.extracted_count else 0
                        end
                    ) as extracted_count
                from
                    {{ source("ppswh_ext_sources", "FACTDAILYPREPASSPAYMENTS") }} as fpp
                inner join
                    {{ source("ppswh_dbo_sources", "DIMDATE") }} as dd
                    on dd.datekey = fpp.fileimportdatekey
                inner join
                    {{ source("ppswh_dbo_sources", "DIMDATE") }} as md
                    on (
                        dateadd(day, ((-1 * day(dd.calendardate)) + 1), dd.calendardate)
                        = md.calendardate
                    )
                group by fpp.payerid, md.calendardate
            ) as ppp
            on (ppp.payerid = pps.payerid and ppp.calendardate = pps.calendardate)
        where pps.calendardate >= date_trunc('YEAR', dateadd(year, -3, getdate()))
        group by pps.payerid, pps.calendardate, pps.product_grp
        having sum(pps.pps_count) > 0
        order by pps.payerid, pps.calendardate, pps.product_grp
    )
select *
from stg_payments_aggr
