# DBT Procurement Data Warehouse

## Overview
This is a standalone dbt project for building a comprehensive procurement data mart. It implements a dimensional model following Kimball methodology with staging, intermediate, and mart layers.

## Project Structure
```
DBT_WH_PROCUREMENT_MART/
├── models/
│   ├── 1.Source/                    # Source definitions
│   ├── 2.Stage/PROCUREMENT/         # Staging layer (data cleansing)
│   ├── 3.Inter/PROCUREMENT/         # Intermediate layer (business logic)
│   └── 4.Mart/PROCUREMENT/          # Mart layer (dimensional model)
├── macros/                          # Custom macros
├── tests/                           # Data quality tests
├── analyses/                        # Ad-hoc analyses
├── seeds/                           # Reference data
├── snapshots/                       # SCD Type 2 snapshots
├── dbt_project.yml                  # Project configuration
├── packages.yml                     # Package dependencies
└── README.md                        # This file
```

## Data Model

### Fact Tables (6)
1. **`fact_purchase_orders`** - Purchase order transactions (Grain: PO line item)
2. **`fact_supplier_invoices`** - Supplier invoice transactions (Grain: Invoice)
3. **`fact_expense_reports`** - Employee expense reports (Grain: Expense report)
4. **`fact_requisitions`** - Purchase requisitions (Grain: Requisition)
5. **`fact_receipts`** - Goods/services receipts (Grain: Receipt)
6. **`fact_payments`** - Supplier payments (Grain: Payment transaction)

### Dimension Tables (9)
1. **`dim_supplier`** - Supplier master data (SCD Type 2)
2. **`dim_company`** - Company/legal entity information
3. **`dim_cost_center`** - Cost center hierarchy
4. **`dim_spend_category`** - Procurement category classifications
5. **`dim_currency`** - Currency reference data
6. **`dim_buyer`** - Buyer/purchaser information
7. **`dim_location`** - Location/site reference
8. **`dim_project`** - Project tracking
9. **`dim_date`** - Date dimension (standard)

### Source Tables (13 Bronze Layer Tables)
- BUSINESS_PROCESS_TRANSACTIONS_OF_TYPE_AWAITING_ACTION
- CUSTOMIZED_PURCHASE_ORDERS
- EXPENSE_REPORTS
- EXTRACT_SUPPLIERS
- INPROGRESS_REQUISITIONS_OPENED_BY_TERMINATED_WORKERS
- INVOICE_BALANCE_REMAINING_10_PCTG
- INVOICE_MATCH_EXCEPTIONS
- RECEIPT_WITH_REQUISITIONER
- REQUISITIONS_BY_COMPANY
- SETTLEMENT_RUNS
- SUPPLIER_INVOICES
- SUPPLIER_PAYMENTS
- ZELIS_PAID_SUPPLIER_INVOICES

## Key Features

### Data Architecture
- **3-Layer Architecture**: Stage → Inter → Mart
- **Dimensional Modeling**: Star schema with fact and dimension tables
- **SCD Type 2**: Change tracking for key dimensions
- **Audit Columns**: Complete lineage tracking
- **Unknown Members**: -1 records for referential integrity

### Business Capabilities
- **Spend Analysis**: By supplier, category, cost center, time
- **Purchase Order Lifecycle**: End-to-end procurement tracking
- **Supplier Performance**: Delivery, quality, compliance metrics
- **Cash Flow Management**: Payables and payment forecasting
- **Project Spend Tracking**: Project-based procurement analytics
- **Multi-Currency Support**: Global procurement operations

## Getting Started

### Prerequisites
- dbt Core 1.0+
- Snowflake connection
- Python 3.8+

### Installation
1. Clone this repository
2. Install dependencies:
   ```bash
   dbt deps
   ```
3. Configure your `profiles.yml` for Snowflake connection
4. Test connection:
   ```bash
   dbt debug
   ```

### Running the Project
1. **Run staging models**:
   ```bash
   dbt run --models 2.Stage
   ```

2. **Run intermediate models**:
   ```bash
   dbt run --models 3.Inter
   ```

3. **Run mart models**:
   ```bash
   dbt run --models 4.Mart
   ```

4. **Run all models**:
   ```bash
   dbt run
   ```

5. **Run tests**:
   ```bash
   dbt test
   ```

### Environment Configuration

Update `dbt_project.yml` with your environment-specific settings:
- Database names for dev/qa/prod
- Schema configurations
- Materialization strategies

## Data Quality

### Tests Implemented
- **Referential Integrity**: Foreign key relationships
- **Data Quality**: Not null, unique constraints
- **Business Rules**: Custom validation tests

### Monitoring
- Row count validation
- Data freshness checks
- Schema evolution tracking

## Deployment

### Environments
- **Development**: Individual developer environments
- **QA**: Quality assurance testing
- **Production**: Live production environment

### CI/CD Pipeline
1. Code review process
2. Automated testing
3. Environment promotion
4. Production deployment

## Business Intelligence Integration

This data mart supports various BI tools:
- **Tableau**: Pre-built dashboard templates
- **Power BI**: Semantic model definitions
- **Looker**: LookML models
- **Custom Analytics**: Direct SQL access

## Maintenance

### Regular Tasks
- Monitor data quality tests
- Update documentation
- Performance optimization
- Schema evolution management

### Support
For questions or issues, please contact the Data Engineering team.

## Version History
- **v1.0.0**: Initial procurement mart implementation
  - Complete dimensional model
  - 6 fact tables, 9 dimensions
  - Full data lineage and testing