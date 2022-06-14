/* 
1 - find successive trip (start follow by end).
2 - get routes during the last 30 minutes.
3 - get area for pickup city and dropoff area.
4 - add id for each row in window after sort the window records by number of trips.
5 - get first 10 rows in window. 
*/

select route, ridesCount, rankRoute from(
	SELECT *, ROW_NUMBER() OVER (PARTITION BY s_interval, e_interval ORDER BY ridesCount DESC) as rankRoute FROM (
		SELECT  
			route,
			TUMBLE_START(matchTime , INTERVAL '30' MINUTES) as s_interval,	
			TUMBLE_END(matchTime , INTERVAL '30' MINUTES) as e_interval,
			count( DISTINCT rideId) as ridesCount
		FROM Rides
		MATCH_RECOGNIZE (
		  PARTITION BY taxiId
		  ORDER BY rideTime
		  
		  MEASURES 
		    rideId as rideId,
		    MATCH_ROWTIME() as matchTime,
		    CONCAT(cast(toAreaId(S.lon, S.lat) as varchar ) ,':', cast(toAreaId(E.lon, E.lat)  as varchar )) AS route

		  AFTER MATCH SKIP PAST LAST ROW
		  PATTERN (S E)
		  DEFINE
		    S AS S.isStart,
		    E AS NOT E.isStart 
		)
		GROUP BY TUMBLE(matchTime, INTERVAL '30' MINUTES), route
		
	) 
	  
) WHERE rankRoute <= 10;

