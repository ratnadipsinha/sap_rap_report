@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Delivery Summary per Sales Order'

@Analytics.dataCategory: #DIMENSION

define view entity ZXX_I_DeliverySummary
  as select from I_DeliveryDocumentItem
{
  key SalesOrder                              as SalesOrder,

      @DefaultAggregation: #SUM
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      sum( ActualDeliveryQuantity )           as DeliveredQuantity,

      @DefaultAggregation: #COUNT_DISTINCT
      count( distinct DeliveryDocument )      as DeliveryCount,

      BaseUnit
}
group by
  SalesOrder,
  BaseUnit
