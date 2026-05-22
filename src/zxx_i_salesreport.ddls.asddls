@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Sales Cycle Report - Interface View'
@Analytics.dataCategory: #CUBE
@AbapCatalog.viewEnhancementCategory: [#NONE]

define view entity ZXX_I_SalesReport
  as select from zxx_salesdata
{
  key sales_order                       as SalesOrder,
      sales_org                         as SalesOrganization,
      company_code                      as CompanyCode,
      dist_channel                      as DistributionChannel,
      creation_date                     as CreationDate,
      creation_date                     as SalesOrderDate,
      status                            as OverallStatus,
      currency                          as Currency,
      company_code                      as CompanyCodeName,
      sales_org                         as SalesOrganizationName,
      dist_channel                      as DistributionChannelName,
      order_value                       as OrderValueNet,
      sales_order                       as SalesOrderCount,
      invoice_value                     as InvoiceValueNet,
      invoice_cnt                       as InvoiceCount,
      delivery_cnt                      as DeliveryCount,
      fulfil_pct                        as FulfilmentPercent,
      billing_pct                       as BillingPercent
}
