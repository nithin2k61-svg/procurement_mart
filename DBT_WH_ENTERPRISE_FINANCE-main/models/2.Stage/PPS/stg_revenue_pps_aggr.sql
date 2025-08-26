{{ config(materialized="table", tags=["monthly"]) }}

with
    stg_revenue_pps_aggr as (
        select
            pyre.paymentid,
            case
                when dpyr.masterpayerid is null
                then dpyr.payerid
                else dpyr.masterpayerid
            end as client,
            monthdate.dateday as tranyearmonthdate,
            case
                when pol.paymentpolicyid = 22
                then 'PayerBrandedVCC'
                when
                    pyre.productlineid in (0, -2, -4, -5, -6, -7,-8,-9,-10,-17,-19,-20,-21,-23,-24,-25,-26,-27)
                then 'PayerSponsored'
                when pyre.productlineid in (1, 2, 7, 8)
                then 'VCC'
                when pyre.productlineid in (3, -15, 6)
                then 'ACH+'
                when pyre.productlineid = 4
                then 'Check'
                else 'Unknown'
            end as producttype,
            '2' as src_sys_id,
            '2' as businessunit,
            concat(src_sys_id, '_', client) as srcuniqcd_dim_client,
            concat('7', '_', producttype) as srcuniqcd_dim_product_type,
            concat('7', '_', src_sys_id) as srcuniqcd_dim_source_system,
            concat('7', '_', businessunit) as srcuniqcd_dim_business_unit,
            coalesce(sum(paymentamount), 0) volume_amount,
            coalesce(sum(interchange), 0) gross_revenue_amount,
            1 as realization_rate,
            0 as net_revenue_amount,
            pyre.PROVIDERID,
			 concat(src_sys_id, '_', pyre.PROVIDERID) as srcuniqcd_dim_provider
        from {{ source("ppswh_comm_sources", "PayerRevenue") }} pyre
        inner join
            {{ source("caidwh_sources", "dimdate") }} monthdate
            on (dateadd(day, ((-1 * day(date)) + 1), date) = monthdate.dateday)
        inner join
            {{ source("ppswh_dbo_sources", "Payer") }} dpyr
            on (pyre.payerid = dpyr.payerid)
        left outer join
            (
                select paymentid, paymentpolicyid
                from {{ source("ppswh_dbo_sources", "PaymentPolicy") }}
                where paymentpolicyid = 22
            ) pol
            on (pyre.paymentid = pol.paymentid)
        where
            producttype in ('PayerBrandedVCC', 'PayerSponsored', 'VCC', 'ACH+', 'Check')
            and monthdate.dateyear >= 2019
        group by
            pyre.paymentid,
            client,
            tranyearmonthdate,
            producttype,
            src_sys_id,
            businessunit,
            srcuniqcd_dim_client,
            srcuniqcd_dim_product_type,
            srcuniqcd_dim_source_system,
            srcuniqcd_dim_business_unit,
            pyre.PROVIDERID,
		   srcuniqcd_dim_provider 

        union all
select
prt.paymentid,
case when dpyr.masterpayerid is null then dpyr.payerid else dpyr.masterpayerid end as client,
monthdate.dateday as tranyearmonthdate,
case when pol.paymentpolicyid = 22 then 'PayerBrandedVCC'
when prt.productlineid in (0,-2,-4,-5,-6,-7,-8,-9,-10,-17,-19,-20,-21,-23,-24,-25,-26,-27) then 'PayerSponsored'
when prt.productlineid in (1, 2, 7, 8) then 'VCC' 
when prt.productlineid in (3, -15, 6) then 'ACH+'
when prt.productlineid = 4 then 'Check' else 'Unknown'end as producttype,
'2' as src_sys_id,
'2' as businessunit,
concat(src_sys_id, '_', client) as srcuniqcd_dim_client,
concat('7', '_', producttype) as srcuniqcd_dim_product_type,
concat('7', '_', src_sys_id) as srcuniqcd_dim_source_system,
concat('7', '_', businessunit) as srcuniqcd_dim_business_unit,
0 volume_amount,
coalesce(sum(-1 * prt.amount),0) gross_revenue_amount,
1 as realization_rate,
0 as net_revenue_amount,
t2.providerid as providerid,
concat(src_sys_id, '_', t2.providerid) as srcuniqcd_dim_provider
from {{ source("ppswh_accounting_sources", "PaymentRevenueTransactions_tbl") }}  as prt
inner join {{ source("ppswh_accounting_sources", "RevenueTransactionType") }} as t1 on t1.TransactionTypeID = prt.TransactionTypeID
inner join {{ source('ppswh_dbo_sources','ProviderPayments')}} as t2 on prt.paymentid=t2.paymentid
inner join  {{ source("caidwh_sources", "dimdate") }} as monthdate on dateadd(day,((-1 * day(prt.transactioncreatedon)) + 1),prt.transactioncreatedon)= monthdate.dateday
inner join  {{ source("ppswh_dbo_sources", "Payer") }} dpyr on (prt.payerid = dpyr.payerid)
left outer join (
                select paymentid, paymentpolicyid
                from  {{ source("ppswh_dbo_sources", "PaymentPolicy") }}
                where paymentpolicyid = 22
            ) pol on (prt.paymentid = pol.paymentid)
where monthdate.dateyear >= 2019 and t1.subtype='Deduction'
and producttype in ('PayerBrandedVCC', 'PayerSponsored', 'VCC', 'ACH+', 'Check') and prt.amount <>0
group by
prt.paymentid,
client,
tranyearmonthdate,
producttype,
src_sys_id,
businessunit,
srcuniqcd_dim_client,
srcuniqcd_dim_product_type,
srcuniqcd_dim_source_system,
srcuniqcd_dim_business_unit,
providerid,
srcuniqcd_dim_provider
    )
select *
from stg_revenue_pps_aggr
