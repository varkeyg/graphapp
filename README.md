
### Graph Server setup

- Install [docker](https://docs.docker.com/engine/install/ubuntu/)
- clone this repository `git clone git@github.com:varkeyg/graphapp.git`
- run `graphapp/docker_run.sh`. This will take a few minutes first time
- The above will create a docker container with apache tinkerpop and all dependecies inside. It will start the tinkerpop server also and log you into a terminal
- start the gremlin client by typing in `gremlin.sh`
- There is a sample gremlin script file `script.gremlin` which has a example to create a graph with 2 vertices and 1 edge. On the gremlin console started in above step, you can run the script by `:load /home/graph-user/graphapp/script.gremlin`
- You can create more queries and run by `:load your-script-file-with-full-path` or do interactive queries on gremlin console

### Demo graph application
The above script downloads this repository to graphapp directory in the container. The resources folder contains a small sqlite database called `holdings.db`. This contains a table called `holdings`.

To view the contents, run `sqlite3 /home/graph-user/graphapp/resources/holdings.db`
Then you can do `select * from holdings` to see the data

### Overview of the data
The data contains stock holdings of major investment companies like Warren Buffet's Berkshire Hathaway at the end of each quarter. 
for example:
```
select holder_name, holding_name, period_date, sum(quantity) as shares
from holdings
where holder_cik ='1067983'
and sym = 'AAPL'
group by holder_name, holding_name, period_date
```
| holder\_name           | holding\_name | period\_date | shares    |
|:-----------------------|:--------------|:-------------|:----------|
| BERKSHIRE HATHAWAY INC | APPLE INC     | 20211231     | 887135554 |
| BERKSHIRE HATHAWAY INC | APPLE INC     | 20220331     | 890923410 |
| BERKSHIRE HATHAWAY INC | APPLE INC     | 20220630     | 894802319 |
| BERKSHIRE HATHAWAY INC | APPLE INC     | 20220930     | 894802319 |


### Graph Modelling and converting the data to graph (gremlin) format. 

One way to model this data as a graph is to create vertices for `holders` and `holdings` and connect them via `edges` for each `period`. Graph models need a unique identifier for a vertex called `id`. usually denoted as `~id` and a label to define the type of vertex. Here we can use `holder_cik` -> Holder's company identifier key defined by securities exchange commission (SEC). Holdings can be identified by sym (symbol). However, some stock holdings does not have symbols. Alternatively we can use CUSIP for the same purpose. Cusip is an alternate identifier. 


#### Lets create holder vertices. 

```
sqlite3 -header -csv holdings.db  "select distinct holder_cik as '~id','Holder'as '~label', holder_name from holdings;" > holder_vertices.csv
```
| \~id    | \~label  | holder\_name                 |
|:--------|:-------|:-----------------------------|
| 1067983 | Holder | BERKSHIRE HATHAWAY INC       |
| 1350694 | Holder | Bridgewater Associates, LP   |
| 1037389 | Holder | RENAISSANCE TECHNOLOGIES LLC |
| 93751   | Holder | STATE STREET CORP            |


#### Holdings vertices (for simplicity, lets create a vertex for each holding period. This can be further modelled more elegantly)
```
sqlite3 -header -csv holdings.db  "
select distinct cusip || '-'|| period_date  as '~id',
       'Holding' as '~label',
       sym,
       holding_name,
       sec_type,
       substr(period_date,1,4)||'-'||substr(period_date,5,2)||'-'||substr(period_date,7,2) as 'period_date:Date',
       sum(cast (market_value as decimal)) as 'market_value:Double',
       sum(cast (quantity as integer)) as 'quantity:Int'
  from holdings
  where sym in ('AAPL', 'CAT')
group by sym, cusip, holding_name, period_date
order by sym desc;" > holding_vertices.csv
```

Here we have defined holdings vertices with a few properties and data types

| \~id               | \~label   | sym  | holding\_name   | sec\_type | period\_date:Date | market\_value:Double | quantity:Int |
|:-------------------|:--------|:-----|:----------------|:----------|:------------------|:---------------------|:-------------|
| 149123101-20211231 | Holding | CAT  | CATERPILLAR INC | COM       | 2021-12-31        | 8499373000           | 41111408     |
| 149123101-20220331 | Holding | CAT  | CATERPILLAR INC | COM       | 2022-03-31        | 9131971000           | 40983625     |
| 149123101-20220630 | Holding | CAT  | CATERPILLAR INC | COM       | 2022-06-30        | 7152932000           | 40014164     |
| 149123101-20220930 | Holding | CAT  | CATERPILLAR INC | COM       | 2022-09-30        | 6592882000           | 40180899     |
| 037833100-20211231 | Holding | AAPL | APPLE INC       | COM       | 2021-12-31        | 270426188000         | 1522927235   |
| 037833100-20220331 | Holding | AAPL | APPLE INC       | COM       | 2022-03-31        | 263537489000         | 1509292061   |
| 037833100-20220630 | Holding | AAPL | APPLE INC       | COM       | 2022-06-30        | 204979018000         | 1499261395   |
| 037833100-20220930 | Holding | AAPL | APPLE INC       | COM       | 2022-09-30        | 205621196000         | 1487852369   |

#### Edges between holder and holdings
```
sqlite3 -header -csv holdings.db  "
select distinct holder_cik ||cusip || '-'|| period_date as '~id',
       'Holder-to_Holding-edge' as '~label',
       holder_cik as '~from',
       cusip || '-'|| period_date as '~to',
       date_filed
  from holdings;" > edges.csv
```

| \~id                      | \~label                   | \~from  | \~to               | date\_filed |
|:--------------------------|:------------------------|:--------|:-------------------|:------------|
| 106798300287Y109-20211231 | Holder-to\_Holding-edge | 1067983 | 00287Y109-20211231 | 20220214    |
| 106798300507V109-20211231 | Holder-to\_Holding-edge | 1067983 | 00507V109-20211231 | 20220214    |
| 1067983023135106-20211231 | Holder-to\_Holding-edge | 1067983 | 023135106-20211231 | 20220214    |
| 1067983025816109-20211231 | Holder-to\_Holding-edge | 1067983 | 025816109-20211231 | 20220214    |
| 1067983037833100-20211231 | Holder-to\_Holding-edge | 1067983 | 037833100-20211231 | 20220214    |


### Converting the csv data to Gremlin format
Kelvin has provided a nice [utility](https://github.com/awslabs/amazon-neptune-tools/tree/master/csv-gremlin) to convert the data. The docker container downloads it also. 

You can convert the csv files into gremlin statements by running:`generate_vert_edges.sh`

### Loading data into graph.

- start the gremlin console `gremlin.sh`

```

gremlin> graph = TinkerGraph.open()
gremlin> g = graph.traversal()


```
