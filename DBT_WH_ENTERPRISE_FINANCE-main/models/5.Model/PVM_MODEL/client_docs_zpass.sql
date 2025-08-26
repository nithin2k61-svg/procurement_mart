{{ config(materialized="view") }}
with
    client_docs_zpass as (
        select
            account_id as sf_id,
            clientname,
            financeparent,
            account_name,
            account_parent_name,
            clientparentname,
            srcclientkey,
            dc.src_sys_id,
            case
                when dc.src_sys_id = 2
                then 'ZPASS'
                when dc.src_sys_id = 3
                then 'DOCS'
                else 'OTHERS'
            end as source_sys_name
        from {{ ref("dim_client") }} dc
        inner join
            {{ ref("dim_source_system") }} ss on dc.src_sys_id = ss.sourcesystemid
        where dc.src_sys_id in (2, 3) and account_id is not null
        order by dc.clientname, ss.sourcesystemname
    )
select *
from client_docs_zpass