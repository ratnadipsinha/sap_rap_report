@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Delivery Summary per Sales Order'

@Analytics.dataCategory: #DIMENSION

define view entity ZXX_I_DeliverySummary
  as select from I_SalesOrderItem
{
  key SalesOrder                              as SalesOrder,

      @DefaultAggregation: #SUM
      @Semantics.quantity.unitOfMeasure: 'RequestedQuantityUnit'
      sum( RequestedQuantity )               as DeliveredQuantity,

      @DefaultAggregation: #COUNT_DISTINCT
      count( distinct SalesOrderItem )       as DeliveryCount,

      RequestedQuantityUnit                  as BaseUnit
}
group by
  SalesOrder,
  RequestedQuantityUnit
