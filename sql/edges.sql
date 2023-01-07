select distinct holder_cik ||cusip || '-'|| period_date as '~id',
       'Holder-to_Holding-edge' as '~label',
       holder_cik as '~from',
       cusip || '-'|| period_date as '~to',
       date_filed
  from holdings;
