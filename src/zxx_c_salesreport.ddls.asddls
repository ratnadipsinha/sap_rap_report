@EndUserText.label: 'Sales Cycle Report - Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true

@UI.headerInfo: {
  typeName:       'Sales Report',
  typeNamePlural: 'Sales Reports'
}

define view entity ZXX_C_SalesReport
  as projection on ZXX_I_SalesReport

{
      @UI.selectionField: [{ position: 10 }]
      @UI.lineItem: [{ position: 10, label: 'Sales Order' }]
  key SalesOrder,

      @UI.selectionField: [{ position: 20 }]
      @UI.lineItem: [{ position: 20, label: 'Company Code' }]
      CompanyCode,

      @UI.selectionField: [{ position: 30 }]
      @UI.lineItem: [{ position: 30, label: 'Sales Org' }]
      SalesOrganization,

      @UI.selectionField: [{ position: 40 }]
      @UI.lineItem: [{ position: 40, label: 'Dist Channel' }]
      DistributionChannel,

      @UI.lineItem: [{ position: 50, label: 'Creation Date' }]
      CreationDate,

      @UI.lineItem: [{ position: 60, label: 'Status' }]
      OverallStatus,

      @UI.lineItem: [{ position: 70, label: 'Order Value' }]
      OrderValueNet,

      @UI.lineItem: [{ position: 80, label: 'Invoice Value' }]
      InvoiceValueNet,

      @UI.lineItem: [{ position: 90, label: 'Fulfilment %' }]
      FulfilmentPercent,

      @UI.lineItem: [{ position: 100, label: 'Billing %' }]
      BillingPercent,

      Currency,
      SalesOrderDate,
      SalesOrderCount,
      InvoiceCount,
      DeliveryCount,
      CompanyCodeName,
      SalesOrganizationName,
      DistributionChannelName
}
