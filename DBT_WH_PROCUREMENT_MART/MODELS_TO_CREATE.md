# Complete List of Models to Create

## Already Created ✅
- `/models/1.Source/PROCUREMENT_Sources.yml`
- `/models/1.Source/Sequence_Generation_sources.yml`
- `/models/2.Stage/PROCUREMENT/stg_suppliers.sql`
- `/models/2.Stage/PROCUREMENT/stg_purchase_orders.sql`
- `/models/2.Stage/PROCUREMENT/stg_supplier_invoices.sql`
- `/models/2.Stage/PROCUREMENT/stg_expense_reports.sql`
- `/models/2.Stage/PROCUREMENT/stg_requisitions.sql`
- `/models/2.Stage/PROCUREMENT/stg_receipts.sql`
- `/models/2.Stage/PROCUREMENT/stg_payments.sql`
- `/models/2.Stage/PROCUREMENT/schema.yml`

## Still Need to Create 📝

### 3.Inter/PROCUREMENT/ (8 files)
- `intr_dim_supplier.sql`
- `intr_dim_company.sql`
- `intr_dim_spend_category.sql`
- `intr_dim_cost_center.sql`
- `intr_dim_currency.sql`
- `intr_dim_buyer.sql`
- `intr_dim_location.sql`
- `intr_dim_project.sql`
- `intr_fact_purchase_orders.sql`
- `intr_fact_supplier_invoices.sql`
- `intr_fact_requisitions.sql`
- `intr_fact_receipts.sql`
- `intr_fact_payments.sql`
- `schema.yml`

### 4.Mart/PROCUREMENT/ (15 files)
- `dim_supplier.sql`
- `dim_company.sql`
- `dim_spend_category.sql`
- `dim_cost_center.sql`
- `dim_currency.sql`
- `dim_buyer.sql`
- `dim_location.sql`
- `dim_project.sql`
- `fact_purchase_orders.sql`
- `fact_supplier_invoices.sql`
- `fact_expense_reports.sql`
- `fact_requisitions.sql`
- `fact_receipts.sql`
- `fact_payments.sql`
- `schema.yml`

## Additional Files
- `.gitignore`
- `package-lock.yml`
- Sample `profiles.yml`

## Key Patterns to Follow

### Intermediate Dimension Pattern
```sql
{{ config(materialized="table", tags=["daily"]) }}

with
    intr_dim_[entity] as (
        select distinct
            [ENTITY]_CODE,
            [ENTITY]_NAME,
            [additional attributes],
            src_sys_id,
            src_uniq_cd,
            row_cre_dt,
            row_cre_usr_id,
            row_mod_dt,
            row_mod_usr_id
        from {{ ref("stg_[source]") }}
    )

select * from intr_dim_[entity]
```

### Mart Dimension Pattern
```sql
{{
    config(
        materialized="incremental",
        dist="src_uniq_cd",
        unique_key="src_uniq_cd",
        on_schema_change="sync_all_columns",
    )
}}

with
    dim_[entity] as (
        select
            {{ source("sequence_sources", "dim[entity]idkey") }}.nextval as dim_[entity]_id,
            a.[attributes],
            a.src_sys_id,
            a.src_uniq_cd,
            a.row_cre_dt,
            a.row_cre_usr_id,
            a.row_mod_dt,
            a.row_mod_usr_id
        from {{ ref("intr_dim_[entity]") }} a
        
        [SCD Type 2 logic if incremental]
        
        union all
        
        [Unknown member record]
    )

select * from dim_[entity]
```

### Fact Table Pattern
```sql
{{ config(materialized="table", tags=["daily"]) }}

with
    fact_[entity] as (
        select
            [dimension foreign keys],
            [measures],
            [attributes],
            src_sys_id,
            src_uniq_cd,
            getdate() as row_cre_dt,
            'SFAdmin' as row_cre_usr_id,
            getdate() as row_mod_dt,
            'SFAdmin' as row_mod_usr_id
        from {{ ref("intr_fact_[entity]") }}
    )

select * from fact_[entity]
```

## Notes
- All models follow the same patterns established in the original finance warehouse
- SCD Type 2 implemented for key dimensions (supplier, company, etc.)
- Unknown members (-1) for all dimensions
- Proper foreign key relationships with tests
- Complete audit trail with src_sys_id, src_uniq_cd, timestamps