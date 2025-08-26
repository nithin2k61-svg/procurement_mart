{{ config(materialized="view") }}

with
    buproductmix as (
        select distinct dim_business_unit_id, dim_product_type_id
        from {{ ref("FACT_claims") }} fc
        where year(fc.dateday) >= year(current_date) - 3 and dateday < current_date
        union
        select distinct dim_business_unit_id, dim_product_type_id
        from {{ ref("FACT_budgets") }} fc
        where year(fc.dateday) >= year(current_date) - 3 and dateday < current_date
        union
        select distinct dim_business_unit_id, dim_product_type_id
        from {{ ref("FACT_comms") }} fc
        where year(fc.dateday) >= year(current_date) - 3 and dateday < current_date
        union
        select distinct dim_business_unit_id, dim_product_type_id
        from {{ ref("FACT_revenue") }} fc
        where year(fc.dateday) >= year(current_date) - 3 and dateday < current_date
        union
        select distinct dim_business_unit_id, dim_product_type_id
        from {{ ref("FACT_payments") }} fc
        where year(fc.dateday) >= year(current_date) - 3 and dateday < current_date
    ),
    uniquevalues as (
        select distinct
            bu."Business Unit", bu.dim_business_unit_id, pt."Product Profile Group"
        from buproductmix mix
        join
            {{ ref("DIM_business_unit") }} bu
            on mix.dim_business_unit_id = bu.dim_business_unit_id
        join
            {{ ref("DIM_product_type_ch") }} pt
            on pt.dim_product_type_id = mix.dim_product_type_id
        where
            pt."Product Profile Active Flag" = 1
            and concat(bu."Business Unit", '-', "Product Type Group")
            not in ('Communications-NEGOTIATIONS', 'Payments-EOB', 'Payments-ID Cards')
    ),
    businessunits as (
        select distinct
            0 as parentid,
            dense_rank() over (order by dim_business_unit_id) as id,
            "Business Unit" as name,
            dim_business_unit_id
        from uniquevalues
    ),
    productgroups as (
        select
            bu.id as parentid,
            dense_rank() over (
                order by bu.dim_business_unit_id, "Product Profile Group"
            )
            + (select max(id) from businessunits) as id,
            "Product Profile Group" as name,
            bu.name as "Business Unit"
        from uniquevalues uv
        join businessunits bu on uv.dim_business_unit_id = bu.dim_business_unit_id
    ),
    metrics as (
        select 'Start Date' as metricname, 1 as metricorder
        union
        select 'Payors', 2
        union
        select 'Revenue', 3
        union
        select 'Attainment', 4
    ),
    metricmix as (
        select
            pg.id as parentid,
            dense_rank() over (order by pg.id, metricorder)
            + (select max(id) from productgroups) as id,
            metricname as name,
            "Business Unit",
            pg.name as "Product Type"
        from metrics m
        join productgroups pg on 1 = 1
    ),
    profiletree as (
        select parentid, id, name, name as "Business Unit", null as "Product Type"
        from businessunits
        union
        select parentid, id, name, "Business Unit", name
        from productgroups
        union
        select parentid, id, name, "Business Unit", "Product Type"
        from metricmix
        order by 2
    ),
    parentaccounts as (
        select distinct "Account Parent ID"
        from {{ ref("DIM_client_ch") }}
        where "Account Parent ID" is not null
    ),
    dim_product_profile_map as (
        select distinct
            "Account Parent ID",
            parentid "Hierarchy ID",
            id "Profile Tree ID",
            name "Profile Tree Name",
            "Business Unit",
            "Product Type"
        from parentaccounts
        join profiletree on 1 = 1
        order by "Account Parent ID", id
    )
select *
from dim_product_profile_map