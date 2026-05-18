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

  association [0..*] to I_SalesOrderItem         as _SalesOrderItem
    on _SalesOrderItem.SalesOrder = SalesOrder.SalesOrder

  association [0..*] to I_BillingDocument        as _BillingDocument
    on _BillingDocument.SDDocument = SalesOrder.SalesOrder

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

      // ── Measures — Invoice (via association) ────────────────────
      @Analytics.measure: true
      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'Currency'
      SalesOrder.TotalNetAmount - SalesOrder.TotalNetAmount as InvoiceValueNet, -- replaced in projection via association

      // ── Calculated Measures ─────────────────────────────────────
      @Analytics.measure: true
      @DefaultAggregation: #SUM
      cast( 0 as abap.dec(5,2) )                 as FulfilmentPercent,

      @Analytics.measure: true
      @DefaultAggregation: #SUM
      cast( 0 as abap.dec(5,2) )                 as BillingPercent,

      // ── Associations ────────────────────────────────────────────
      _SalesOrderItem,
      _BillingDocument

}
