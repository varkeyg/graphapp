select holder_cik, holding_name, period_date, sym, sum(quantity) as shares
from holdings
where holder_cik ='1067983'
and sym = 'AAPL'
group by holder_cik, holding_name, period_date, sym