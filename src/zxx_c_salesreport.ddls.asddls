@EndUserText.label: 'Sales Cycle Report - Projection View (ALP)'
@AccessControl.authorizationCheck: #INHERITED
@Metadata.allowExtensions: true

// ── ALP Floor Plan ───────────────────────────────────────────────
@UI.headerInfo: {
  typeName:       'Sales Report',
  typeNamePlural: 'Sales Reports',
  title:          { type: #STANDARD, value: 'CompanyCode' },
  description:    { type: #STANDARD, value: 'SalesOrganizationName' }
}

// ── Chart 1: Donut — Invoice Value by Sales Org ──────────────────
@UI.chart: [{
  qualifier:      'InvBySalesOrg',
  chartType:      #DONUT,
  title:          'Invoice Value by Sales Organisation',
  dimensions:     ['SalesOrganization'],
  measures:       ['OrderValueNet'],
  dimensionAttributes: [{
    dimension: 'SalesOrganization',
    role:      #SERIES
  }],
  measureAttributes: [{
    measure:   'OrderValueNet',
    role:      #AXIS_1,
    asDataPoint: true
  }]
}]

// ── Chart 2: Grouped Bar — Order vs Invoice by Sales Org ─────────
@UI.chart: [{
  qualifier:      'OrdVsInvBySalesOrg',
  chartType:      #BAR_GROUPED,
  title:          'Order vs Invoice Value by Sales Org (grouped by Company)',
  dimensions:     ['SalesOrganization', 'CompanyCode'],
  measures:       ['OrderValueNet'],
  dimensionAttributes: [
    { dimension: 'SalesOrganization', role: #CATEGORY },
    { dimension: 'CompanyCode',       role: #SERIES   }
  ],
  measureAttributes: [{
    measure: 'OrderValueNet',
    role:    #AXIS_1
  }]
}]

// ── KPI Data Points ───────────────────────────────────────────────
@UI.dataPoint: #{
  qualifier:   'OrderValueKPI',
  value:       'OrderValueNet',
  title:       'Total Order Value',
  criticality: #NEUTRAL
}

@UI.dataPoint: #{
  qualifier: 'FulfilmentKPI',
  value:     'FulfilmentPercent',
  title:     'Fulfilment %',
  criticalityCalculation: {
    improvementDirection:     #MAXIMIZE,
    toleranceRangeLowValue:   70,
    toleranceRangeHighValue:  90,
    deviationRangeLowValue:   50,
    deviationRangeHighValue:  100
  }
}

@UI.dataPoint: #{
  qualifier: 'BillingKPI',
  value:     'BillingPercent',
  title:     'Billing %',
  criticalityCalculation: {
    improvementDirection:     #MAXIMIZE,
    toleranceRangeLowValue:   70,
    toleranceRangeHighValue:  90,
    deviationRangeLowValue:   50,
    deviationRangeHighValue:  100
  }
}

define root view entity ZXX_C_SalesReport
  provider contract analytical_query
  as projection on ZXX_I_SalesReport

{
      // ── Selection Fields (Filter Bar) ────────────────────────────
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

      // ── Line Item Columns (Summary Table) ────────────────────────
      @UI.lineItem: [{ position: 10, label: 'Company Code' }]
      CompanyCodeName,

      @UI.lineItem: [{ position: 20, label: 'Sales Organisation' }]
      SalesOrganizationName,

      @UI.lineItem: [{ position: 30, label: 'Distribution Channel' }]
      DistributionChannelName,

      @UI.lineItem: [{ position: 40, label: 'Sales Orders' }]
      SalesOrderCount,

      @UI.lineItem: [{
        position:  50,
        label:     'Order Value (Net)',
        dataPointElement: 'OrderValueKPI'
      }]
      @Semantics.amount.currencyCode: 'Currency'
      OrderValueNet,

      @UI.lineItem: [{
        position: 60,
        label:    'Invoice Value (Net)'
      }]
      @Semantics.amount.currencyCode: 'Currency'
      InvoiceValueNet,

      @UI.lineItem: [{
        position:         70,
        label:            'Fulfilment %',
        dataPointElement: 'FulfilmentKPI',
        criticality:      #( FulfilmentPercent )
      }]
      FulfilmentPercent,

      @UI.lineItem: [{
        position:         80,
        label:            'Billing %',
        dataPointElement: 'BillingKPI',
        criticality:      #( BillingPercent )
      }]
      BillingPercent,

      Currency,
      SalesOrder,
      SalesOrderDate,
      OverallStatus
}
