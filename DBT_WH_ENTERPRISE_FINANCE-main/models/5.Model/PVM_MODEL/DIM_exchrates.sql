{{ config(materialized="view") }}

with
    dim_exchrates as (
        select DISTINCT ACCOUNT_NAME,ACCOUNT_CODE
        from {{ ref("dim_exchrates") }}
    )
select * from dim_exchrates