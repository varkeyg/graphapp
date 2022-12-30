select holder_name, holding_name, period_date, sum(quantity) as shares
from holdings
where holder_cik ='1067983'
and sym = 'AAPL'
group by holder_name, holding_name, period_date