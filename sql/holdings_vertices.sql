select sym, cusip, holding_name, period_date, sum(market_value) as market_value, sum(quantity) as quantity from holdings
group by sym, cusip, holding_name, period_date