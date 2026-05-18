@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Sales Cycle Report - Interface View'

@Analytics.dataCategory: #CUBE

@AbapCatalog.viewEnhancementCategory: [#NONE]
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.sqlViewAppendName: 'ZXX_I_SLRPT'

define root view entity ZXX_I_SalesReport

  as select from I_SalesOrder as SalesOrder

  left outer to one join I_CompanyCode as Company
    on Company.CompanyCode = SalesOrder.CompanyCode

  left outer to one join I_SalesOrganization as SalesOrg
    on SalesOrg.SalesOrganization = SalesOrder.SalesOrganization

  left outer to one join I_DistributionChannelText as DistChanText
    on  DistChanText.DistributionChannel = SalesOrder.DistributionChannel
    and DistChanText.Language            = $session.system_language

  // 1:1 join — aggregated per SalesOrder to avoid row multiplication
  left outer to one join ZXX_I_BillingSummary as Billing
    on  Billing.SalesOrder = SalesOrder.SalesOrder
    and Billing.Currency   = SalesOrder.TransactionCurrency

  // 1:1 join — aggregated per SalesOrder to avoid row multiplication
  left outer to one join ZXX_I_DeliverySummary as Delivery
    on Delivery.SalesOrder = SalesOrder.SalesOrder

  association [0..*] to I_SalesOrderItem as _SalesOrderItem
    on _SalesOrderItem.SalesOrder = SalesOrder.SalesOrder

{
      // ── Dimensions ──────────────────────────────────────────────
      @Analytics.dimension: true
      @ObjectModel.text.element: ['CompanyCodeName']
  key SalesOrder.CompanyCode                      as CompanyCode,

      @Analytics.dimension: true
      @ObjectModel.text.element: ['SalesOrganizationName']
  key SalesOrder.SalesOrganization                as SalesOrganization,

      @Analytics.dimension: true
      @ObjectModel.text.element: ['DistributionChannelName']
  key SalesOrder.DistributionChannel              as DistributionChannel,

      @Analytics.dimension: true
  key SalesOrder.SalesOrder                       as SalesOrder,

      // ── Attributes ──────────────────────────────────────────────
      SalesOrder.CreationDate                     as CreationDate,
      SalesOrder.SalesOrderDate                   as SalesOrderDate,
      SalesOrder.OverallSDProcessStatus           as OverallStatus,
      SalesOrder.TransactionCurrency              as Currency,

      Company.CompanyCodeName                     as CompanyCodeName,
      SalesOrg.SalesOrganizationName              as SalesOrganizationName,
      DistChanText.DistributionChannelName        as DistributionChannelName,

      // ── Measures — Order ────────────────────────────────────────
      @Analytics.measure: true
      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'Currency'
      SalesOrder.TotalNetAmount                   as OrderValueNet,

      @Analytics.measure: true
      @DefaultAggregation: #COUNT_DISTINCT
      SalesOrder.SalesOrder                       as SalesOrderCount,

      // ── Measures — Invoice (from ZXX_I_BillingSummary) ──────────
      @Analytics.measure: true
      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'Currency'
      coalesce( Billing.InvoiceValueNet, cast( 0 as abap.curr(23,2) ) ) as InvoiceValueNet,

      @Analytics.measure: true
      @DefaultAggregation: #SUM
      coalesce( Billing.InvoiceCount, 0 )         as InvoiceCount,

      // ── Measures — Delivery (from ZXX_I_DeliverySummary) ────────
      @Analytics.measure: true
      @DefaultAggregation: #SUM
      coalesce( Delivery.DeliveryCount, 0 )       as DeliveryCount,

      // ── Calculated KPI Measures ──────────────────────────────────
      // FulfilmentPercent: DeliveryCount / SalesOrderCount * 100
      @Analytics.measure: true
      @DefaultAggregation: #SUM
      cast(
        case when SalesOrder.TotalNetAmount <> 0
          then ( coalesce( Billing.InvoiceValueNet, cast( 0 as abap.curr(23,2) ) )
                 / SalesOrder.TotalNetAmount ) * 100
          else 0
        end as abap.dec(5,2)
      )                                           as BillingPercent,

      @Analytics.measure: true
      @DefaultAggregation: #SUM
      cast(
        case when coalesce( Delivery.DeliveryCount, 0 ) > 0
          then 100
          else 0
        end as abap.dec(5,2)
      )                                           as FulfilmentPercent,

      // ── Associations ────────────────────────────────────────────
      _SalesOrderItem

}
