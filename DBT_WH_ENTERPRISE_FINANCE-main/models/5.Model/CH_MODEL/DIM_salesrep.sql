{{ config(materialized="view") }}

with
    dim_salesrep as (
        select distinct
            u1."Name" as "Sales Representative",
            concat(to_varchar(c.team_sr_ccs), '-', to_varchar(c.team_sr_pps), '-', to_varchar(c.team_sr_com)) salesrepjoin
        from {{ ref("dim_client") }} c
        left join
            {{ source("ads_reporting_sources", "dimuser") }} u1
            on c.team_sr_ccs = u1."UserID"
        where
            concat(to_varchar(c.team_sr_ccs), '-', to_varchar(c.team_sr_pps), '-', to_varchar(c.team_sr_com)) is not null

        union
        
        select distinct
            u2."Name" as "Sales Representative",
            concat(to_varchar(c.team_sr_ccs), '-', to_varchar(c.team_sr_pps), '-', to_varchar(c.team_sr_com)) salesrepjoin
        from {{ ref("dim_client") }} c
        left join
            {{ source("ads_reporting_sources", "dimuser") }} u2
            on c.team_sr_pps = u2."UserID"
        where
            concat(to_varchar(c.team_sr_ccs), '-', to_varchar(c.team_sr_pps), '-', to_varchar(c.team_sr_com)) is not null

        union

        select distinct
            u3."Name" as "Sales Representative",
            concat(to_varchar(c.team_sr_ccs), '-', to_varchar(c.team_sr_pps), '-', to_varchar(c.team_sr_com)) salesrepjoin
        from {{ ref("dim_client") }} c
        left join
            {{ source("ads_reporting_sources", "dimuser") }} u3
            on c.team_sr_com = u3."UserID"
        where
            concat(to_varchar(c.team_sr_ccs), '-', to_varchar(c.team_sr_pps), '-', to_varchar(c.team_sr_com)) is not null
    )
select * from dim_salesrep