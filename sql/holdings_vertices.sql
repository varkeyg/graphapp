select distinct cusip || '-'|| period_date  as '~id',
       'Holding' as label,
       sym,
       cusip,
       holding_name,
       sec_type,
       substr(period_date,1,4)||'-'||substr(period_date,5,2)||'-'||substr(period_date,7,2) as 'period_date:Date',
       sum(cast (market_value as decimal)) as market_value, sum(cast (quantity as integer)) as 'quantity:Int'
  from holdings
  where sym in ('AAPL', 'CAT')
group by sym, cusip, holding_name, period_date
order by sym desc;

select * from holdings