cd resources/

sqlite3 -header -csv holdings.db  "select distinct holder_cik as '~id','Holder'as '~label', holder_name from holdings;" > holder_vertices.csv

sqlite3 -header -csv holdings.db  "
select distinct cusip || '-'|| period_date  as '~id',
       'Holding' as '~label',
       sym,
       holding_name,
       replace(sec_type,'$',' ') as sec_type,
       substr(period_date,1,4)||'-'||substr(period_date,5,2)||'-'||substr(period_date,7,2) as 'period_date:Date',
       sum(cast (market_value as decimal)) as 'market_value:Double',
       sum(cast (quantity as integer)) as 'quantity:Long'
  from holdings
group by sym, cusip, holding_name, period_date
order by sym desc;" > holding_vertices.csv

sqlite3 -header -csv holdings.db  "
select distinct holder_cik ||cusip || '-'|| period_date as '~id',
       'Holder-to_Holding-edge' as '~label',
       holder_cik as '~from',
       cusip || '-'|| period_date as '~to',
       date_filed
  from holdings;" > edges.csv

python3 /home/graph-user/amazon-neptune-tools/csv-gremlin/csv-gremlin.py holder_vertices.csv > holder_vertices.gremlin
python3 /home/graph-user/amazon-neptune-tools/csv-gremlin/csv-gremlin.py holding_vertices.csv > holding_vertices.gremlin
python3 /home/graph-user/amazon-neptune-tools/csv-gremlin/csv-gremlin.py edges.csv > edges.gremlin





