@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Billing Summary per Sales Order'

@Analytics.dataCategory: #DIMENSION

define view entity ZXX_I_BillingSummary
  as select from I_SalesOrderItem
{
  key SalesOrder                              as SalesOrder,
  key TransactionCurrency                     as Currency,

      @DefaultAggregation: #SUM
      @Semantics.amount.currencyCode: 'Currency'
      sum( NetAmount )                        as InvoiceValueNet,

      @DefaultAggregation: #COUNT_DISTINCT
      count( distinct SalesOrderItem )        as InvoiceCount
}
group by
  SalesOrder,
  TransactionCurrency
