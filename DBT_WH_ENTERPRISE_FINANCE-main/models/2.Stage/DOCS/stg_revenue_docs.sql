{{ config(materialized="table", tags=["monthly"]) }}

with
    stg_revenue_docs as (
        select
            c.cclientid,
            c.cname,
            d.cformatid,
            to_date(concat(left(a.cbatchnumber, 6), '01'), 'YYYYMMDD') transaction_yearmonth,
            trim(b.cdescription) as product_description,
            f.cdescription pricing_point_description,
            case
                when
                    f.cdescription in (
                        'Material', 'Service Fees', 'Per Job Fees', 'Zelis Payee Center'
                    )
                    and d.cformatid = '000'
                then 'Enrollment-Product'
                when
                    f.cdescription in (
                        'Material', 'Service Fees', 'Per Job Fees', 'Zelis Payee Center'
                    )
                    and d.cformatid = '001'
                then 'Communication-Product'
                when f.cdescription in ('Shipping And Handling') and d.cformatid = '000'
                then 'Enrollment-Postage'
                when f.cdescription in ('Shipping And Handling') and d.cformatid = '001'
                then 'Communication-Postage'
                when
                    f.cdescription is null
                    and d.cformatid = '001'
                    and product_description in ('DCM Service Charge')
                then 'Communication-Product'
                when
                    f.cdescription is null
                    and d.cformatid = '000'
                    and product_description in ('DCM Service Charge')
                then 'Enrollment-Product'
                when
                    f.cdescription is null
                    and d.cformatid = '001'
                    and product_description
                    in ('Other Postage Freight', 'USPS Postage Freight')
                then 'Communication-Postage'
                when
                    f.cdescription is null
                    and d.cformatid = '000'
                    and product_description
                    in ('Other Postage Freight', 'USPS Postage Freight')
                then 'Enrollment-Postage'
                else 'Unknown'
            end as product_type,           
            case 
                when lower(product_description)
                    in ('dcm service charge', 'dcm zelis electronic no pay value share', 'other postage freight',
                    'providers choice dcm', 'usps postage freight', 'rcm vendor dcm', 'dcm clever letter service charge',
                    'dcm vpay electronic no pay value share')
                then sum(a.naggregatedvalue) end as rate,
                1 as quantity,
            '3' as src_sys_id,
            '3' as businessunit
        from {{ source("docsclient_aggregation_sources", "data") }} a
        inner join
            {{ source("docsshared_reference_sources", "aggregatetypes") }} b
            on (a.caggregatedtype = b.caggregatetype)
        inner join
            {{ source("docsshared_client_sources", "Clients") }} c
            on (c.cclientid = a.cclientid)
        inner join
            {{ source("docsshared_client_sources", "clientformatsettings") }} d
            on (c.cclientid = d.cclientid and a.cformatid = d.cformatid)
        left outer join
            {{ source("docsshared_reference_sources", "parts") }} e
            on (b.ipricingpoint = e.ipartid)
        left outer join
            {{ source("docsshared_reference_sources", "pricingpointcategory") }} f
            on (f.ipricingpointcategory = e.ipricingpointcategory)
        where
            transaction_yearmonth >= '2019-01-01'
            and b.caggregationcategory in ('00', '01')
            and trim(b.cdescription) not in (
                'Checks',
                'Expedited Checks',
                'Image Only Document Count',
                'Impressions',
                'Lockbox Delivery',
                'Spoiled Card Sets',
                'Spoiled Card Singles',
                'Spoiled Page Impressions',
                'White Paper',
                'Cross Client Consolidation',
                'Impression Count',
                'Package Count',
                'Sheet Count',
                'Total Postage'
            )
        group by
            c.cclientid,
            c.cname,
            d.cformatid,
            to_date(concat(left(a.cbatchnumber, 6), '01'), 'YYYYMMDD'),
            trim(b.cdescription),
            f.cdescription,
            product_type,
            quantity

        union all

        select
            clients.cclientid,
            clients.cname,
            pricing.cformatid,
            dateday as transaction_yearmonth,
            trim(parts.cname) as product_description,
            null pricing_point_description,
            case
                when
                    pricing_point_description is null
                    and pricing.cformatid = '001'
                    and product_description
                    in ('DOCS System Admin Fee', 'Terrorist Watchlist Service Fee')
                then 'Communication-Product'
                when
                    pricing_point_description is null
                    and pricing.cformatid = '000'
                    and product_description
                    in ('DOCS System Admin Fee', 'Terrorist Watchlist Service Fee')
                then 'Enrollment-Product'
                else 'Unknown'
            end as product_type,
            yprice as rate,
            1 as quantity,
            '3' as src_sys_id,
            '3' as businessunit
        from {{ source("docsshared_client_sources", "pricing") }}
        inner join
            {{ source("docsshared_reference_sources", "parts") }}
            on (parts.cpartid = pricing.cpartid)
        inner join
            {{ source("docsshared_client_sources", "Clients") }}
            on (clients.cclientid = pricing.cclientid)
        inner join
            (
                select distinct monthdate.dateday
                from {{ source("caidwh_sources", "dimdate") }}
                inner join
                    {{ source("caidwh_sources", "dimdate") }} monthdate
                    on (
                        dateadd(day, ((-1 * day(dimdate.dateday)) + 1), dimdate.dateday)
                        = monthdate.dateday
                    )
            ) zz
        where
            cfeetype = '01'
            and dateday between tbegineffectivedate and tendeffectivedate
            and yprice <> 0
            and dateday >= '2019-01-01'
            and dateday <= getdate()

        order by 4
    )
select *
from stg_revenue_docs
