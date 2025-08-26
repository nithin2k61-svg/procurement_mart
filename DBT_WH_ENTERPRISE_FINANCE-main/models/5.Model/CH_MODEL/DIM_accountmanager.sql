{{ config(materialized="view") }}

with
    dim_accountmanager as (
        select distinct
            team_am_ccs as "Account Manager",
            concat(to_varchar(IFNULL(c.team_am_ccs,' ')), '-', to_varchar(IFNULL(c.team_am_pps,' ')), '-', to_varchar(IFNULL(c.team_am_def,' '))) accountmgrjoin
        from {{ ref("dim_client") }} c
        where
            concat(to_varchar(IFNULL(c.team_am_ccs,' ')), '-', to_varchar(IFNULL(c.team_am_pps,' ')), '-', to_varchar(IFNULL(c.team_am_def,' '))) is not null
        union
        select distinct
            team_am_pps "Account Manager",
            concat(to_varchar(IFNULL(c.team_am_ccs,' ')), '-', to_varchar(IFNULL(c.team_am_pps,' ')), '-', to_varchar(IFNULL(c.team_am_def,' '))) accountmgrjoin
        from {{ ref("dim_client") }} c
        where
            concat(to_varchar(IFNULL(c.team_am_ccs,' ')), '-', to_varchar(IFNULL(c.team_am_pps,' ')), '-', to_varchar(IFNULL(c.team_am_def,' '))) is not null
        union
        select distinct
            c.team_am_def "Account Manager",
            concat(to_varchar(IFNULL(c.team_am_ccs,' ')), '-', to_varchar(IFNULL(c.team_am_pps,' ')), '-', to_varchar(IFNULL(c.team_am_def,' '))) accountmgrjoin
        from {{ ref("dim_client") }} c
        where
            concat(to_varchar(IFNULL(c.team_am_ccs,' ')), '-', to_varchar(IFNULL(c.team_am_pps,' ')), '-', to_varchar(IFNULL(c.team_am_def,' '))) is not null
    )
select * from dim_accountmanager