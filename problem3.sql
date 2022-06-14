/* 
1 - create view for to get empty Taxies (emptyTaxies) during the last 30 minute.
2 - create view for to get fares (fares) during the last 30 minute.
3 - join two views by areaId and same end Time
*/
WITH emptyTaxies AS (
	Select areaId, count(distinct taxiId) as emptyIds, TUMBLE_END(matchTime, INTERVAL '30' minute) as exceedTime from (
	  	SELECT  *
			FROM Rides
			MATCH_RECOGNIZE (
			  PARTITION BY taxiId
			  ORDER BY rideTime
			  MEASURES
			    MATCH_ROWTIME() as matchTime,
			    toAreaId(E.lon, E.lat) as areaId

			  AFTER MATCH SKIP PAST LAST ROW
			  PATTERN (S E) Within  interval '15' MINUTE
			  DEFINE
			    S AS S.isStart,
			    E AS NOT E.isStart
			)
	  ) Group by areaId, TUMBLE(matchTime, INTERVAL '30' minute)
)

, fares AS (
	select 
		areaId, 
		avg(fare + tip) as profit, 
		TUMBLE_END(matchTime, INTERVAL '30' minute) as exceedTime 
		from (
			select Rides.*, Fares.* from Rides, Fares
				WHERE Fares.rideId = Rides.rideId
			      		AND Fares.payTime BETWEEN Rides.rideTime - INTERVAL '10' MINUTE AND Rides.rideTime
		)
		MATCH_RECOGNIZE (
		   PARTITION BY rideId
		   ORDER BY rideTime
		   MEASURES
		      fare as fare,
		      tip as tip,
		      toAreaId(S.lon, S.lat) as areaId, 
		      MATCH_ROWTIME() as matchTime
		   AFTER MATCH SKIP PAST LAST ROW
		   PATTERN (S E) Within  interval '15' minute
		   DEFINE
		      S AS S.isStart,
		      E AS NOT E.isStart
		)
		group by areaId, TUMBLE(matchTime, INTERVAL '30' minute)
)

SELECT
  e.areaId, 
  f.profit / e.emptyIds as profitability, 
  e.exceedTime
FROM emptyTaxies as e, fares as f
WHERE
   e.areaId =  f.areaId 
   AND e.exceedTime = f.exceedTime;
