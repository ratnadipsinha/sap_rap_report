@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Sales Cycle Report - Interface View'
@Analytics.dataCategory: #CUBE
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AbapCatalog.sqlViewAppendName: 'ZXX_I_SLRPT'

define root view entity ZXX_I_SalesReport
  as select from zxx_salesdata
{
      // ── Dimensions ──────────────────────────────────────────────
      @Analytics.dimension: true
  key sales_order                       as SalesOrder,

      @Analytics.dimension: true
      sales_org                         as SalesOrganization,

      @Analytics.dimension: true
      company_code                      as CompanyCode,

      @Analytics.dimension: true
      dist_channel                      as DistributionChannel,

      // ── Attributes ──────────────────────────────────────────────
      creation_date                     as CreationDate,
      @UI.hidden: true
      creation_date                     as SalesOrderDate,
      status                            as OverallStatus,
      currency                          as Currency,

      // Text fields — same as key for trial (no join to text tables)
      company_code                      as CompanyCodeName,
      sales_org                         as SalesOrganizationName,
      dist_channel                      as DistributionChannelName,

      // ── Measures — Order ────────────────────────────────────────
      @Analytics.measure: true
      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'Currency'
      order_value                       as OrderValueNet,

      @Analytics.measure: true
      @DefaultAggregation: #COUNT_DISTINCT
      sales_order                       as SalesOrderCount,

      // ── Measures — Invoice ───────────────────────────────────────
      @Analytics.measure: true
      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'Currency'
      invoice_value                     as InvoiceValueNet,

      @Analytics.measure: true
      @DefaultAggregation: #SUM
      invoice_cnt                       as InvoiceCount,

      @Analytics.measure: true
      @DefaultAggregation: #SUM
      delivery_cnt                      as DeliveryCount,

      // ── KPI Measures ─────────────────────────────────────────────
      @Analytics.measure: true
      @DefaultAggregation: #SUM
      fulfil_pct                        as FulfilmentPercent,

      @Analytics.measure: true
      @DefaultAggregation: #SUM
      billing_pct                       as BillingPercent
}
