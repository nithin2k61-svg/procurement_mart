{{ config(materialized="table", tags=["monthly"]) }}

with
    fact_comms_aggr as (
        select
            dim_client_id,
            dim_product_type_id,
            dim_source_system_id,
            dim_business_unit_id,
            dim_date_id,
            ptfm_min_dt,
            dcs_count_imp,
            eob_count_prt,
            doc_elim_rate,
            src_uniq_cd,
            getdate() as row_cre_dt,
            'SF_Admin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SF_Admin' as row_mod_usr_id
        from {{ ref("intr_fact_comms_aggr") }}
    )

select *
from fact_comms_aggr
