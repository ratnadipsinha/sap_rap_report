@EndUserText.label: 'Sales Cycle Report - Projection View (ALP)'
@AccessControl.authorizationCheck: #INHERITED
@Metadata.allowExtensions: true

@UI.headerInfo: {
  typeName:       'Sales Report',
  typeNamePlural: 'Sales Reports',
  title:          { type: #STANDARD, value: 'CompanyCode' },
  description:    { type: #STANDARD, value: 'SalesOrganizationName' }
}

@UI.chart: [
  {
    qualifier:  'InvBySalesOrg',
    chartType:  #DONUT,
    title:      'Invoice Value by Sales Organisation',
    dimensions: ['SalesOrganization'],
    measures:   ['InvoiceValueNet'],
    dimensionAttributes: [{
      dimension: 'SalesOrganization',
      role:      #SERIES
    }],
    measureAttributes: [{
      measure:     'InvoiceValueNet',
      role:        #AXIS_1,
      asDataPoint: true
    }]
  },
  {
    qualifier:  'OrdVsInvBySalesOrg',
    chartType:  #BAR_GROUPED,
    title:      'Order vs Invoice Value by Sales Org',
    dimensions: ['SalesOrganization', 'CompanyCode'],
    measures:   ['OrderValueNet', 'InvoiceValueNet'],
    dimensionAttributes: [
      { dimension: 'SalesOrganization', role: #CATEGORY },
      { dimension: 'CompanyCode',       role: #SERIES   }
    ],
    measureAttributes: [
      { measure: 'OrderValueNet',   role: #AXIS_1 },
      { measure: 'InvoiceValueNet', role: #AXIS_1 }
    ]
  }
]

@UI.dataPoint: {
  qualifier:   'OrderValueKPI',
  value:       'OrderValueNet',
  title:       'Total Order Value',
  criticality: #NEUTRAL
}

@UI.dataPoint: {
  qualifier: 'FulfilmentKPI',
  value:     'FulfilmentPercent',
  title:     'Fulfilment %',
  criticalityCalculation: {
    improvementDirection:    #MAXIMIZE,
    toleranceRangeLowValue:  70,
    toleranceRangeHighValue: 90,
    deviationRangeLowValue:  50,
    deviationRangeHighValue: 100
  }
}

@UI.dataPoint: {
  qualifier: 'BillingKPI',
  value:     'BillingPercent',
  title:     'Billing %',
  criticalityCalculation: {
    improvementDirection:    #MAXIMIZE,
    toleranceRangeLowValue:  70,
    toleranceRangeHighValue: 90,
    deviationRangeLowValue:  50,
    deviationRangeHighValue: 100
  }
}

define root view entity ZXX_C_SalesReport
  provider contract analytical_query
  as projection on ZXX_I_SalesReport

{
      @UI.selectionField: [{ position: 10 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CompanyCode', element: 'CompanyCode' } }]
      CompanyCode,

      @UI.selectionField: [{ position: 20 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_SalesOrganization', element: 'SalesOrganization' } }]
      SalesOrganization,

      @UI.selectionField: [{ position: 30 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_DistributionChannelText', element: 'DistributionChannel' } }]
      DistributionChannel,

      @UI.selectionField: [{ position: 40 }]
      CreationDate,

      @UI.lineItem: [{ position: 10, label: 'Company Code' }]
      CompanyCodeName,

      @UI.lineItem: [{ position: 20, label: 'Sales Organisation' }]
      SalesOrganizationName,

      @UI.lineItem: [{ position: 30, label: 'Distribution Channel' }]
      DistributionChannelName,

      @UI.lineItem: [{ position: 40, label: 'Sales Orders' }]
      SalesOrderCount,

      @UI.lineItem: [{ position: 50, label: 'Order Value (Net)', dataPointElement: 'OrderValueKPI' }]
      @Semantics.amount.currencyCode: 'Currency'
      OrderValueNet,

      @UI.lineItem: [{ position: 60, label: 'Invoice Value (Net)', dataPointElement: 'BillingKPI' }]
      @Semantics.amount.currencyCode: 'Currency'
      InvoiceValueNet,

      @UI.lineItem: [{ position: 70, label: 'Fulfilment %', dataPointElement: 'FulfilmentKPI' }]
      FulfilmentPercent,

      @UI.lineItem: [{ position: 80, label: 'Billing %' }]
      BillingPercent,

      Currency,
      SalesOrder,
      SalesOrderDate,
      OverallStatus
}
