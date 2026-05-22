@EndUserText.label : 'Sales Data'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED

define table zxx_salesdata {
  key mandt         : abap.clnt not null;
  key sales_order   : abap.char(10) not null;
  company_code      : abap.char(4);
  sales_org         : abap.char(4);
  dist_channel      : abap.char(2);
  creation_date     : abap.dats;
  status            : abap.char(2);
  currency          : abap.char(5);
  order_value       : abap.dec(23,2);
  invoice_value     : abap.dec(23,2);
  invoice_cnt       : abap.int4;
  delivery_cnt      : abap.int4;
  fulfil_pct        : abap.dec(5,2);
  billing_pct       : abap.dec(5,2);
}
