# NYC-Taxi-Rides-Analysis-Streaming
I have to implement the following 3 queries using Flink SQL. The implementation of each query might require several select statements and maybe you need to define views in order to breakdown the complexity of the query and address the requirements.
Schemas for the data
 

We have three tables: Rides, Fares and DriverChanges.

 

The schemas for these tables and the meaning of their data can be found in https://github.com/ververica/sql-training/wiki/Introduction-to-SQL-on-Flink (Links to an external site.). Also, the link contains description about the built-in and user-defined functions already available and that you might need to use to implement the queries in this project.

 

You have to implement the following 3 queries using Flink SQL. The implementation of each query might require several select statements and maybe you need to define views in order to breakdown the complexity of the query and address the requirements.


## Queries

### Query 1: Average idle time per hour per area
 

We need to find the average idle time, in minutes, taxis usually spend within a time window of one hour within a specific area. The final output for this query should be (areaId, avg(idleTime)) of the area within 1 hour.

### Query 2: Frequent Routes
 

The goal of the query is to find the top 10 most frequent routes during the last 30 minutes. A route is represented by a starting areaID and an ending areaID. All routes completed within the last 30 minutes are considered for the query. A route is completed when we observe a ride start followed by a ride end for the same taxi.

 

The output should be the starting area Id, end area Id, and the number of completed trips for the top 10 most frequent routes.

 
### Query 3: Profitable areas
 

The goal of this query is to identify the profitability per area for taxi drivers. The profitability of an area is determined by dividing the area profit by the number of empty taxis in that area within the last 15 minutes. The profit that originates from an area is computed by calculating the average fare + tip for trips that started in the area and ended within the last 15 minutes. The number of empty taxis in an area is the sum of taxis that had a drop-off location in that area less than 30 minutes ago and had no following pickup yet.
