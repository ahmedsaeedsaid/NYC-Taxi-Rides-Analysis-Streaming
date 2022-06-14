/* 
1 - find successive trip (start follow by end).
2 - get Idle Time by minute.
3 - get area for pickup city.
4 - get avarage idle time for each area.
*/

SELECT areaId, avg(idleTime) AS avgIdleTime
FROM Rides
MATCH_RECOGNIZE (
  PARTITION BY taxiId
  ORDER BY rideTime
  
  MEASURES 
    timestampDiff(MINUTE,S.rideTime,E.rideTime )AS idleTime,
    MATCH_ROWTIME() as matchTime,
    toAreaId(S.lon, S.lat) as areaId
    
  AFTER MATCH SKIP PAST LAST ROW
  PATTERN (S E)
  DEFINE
    S AS S.isStart,
    E AS NOT E.isStart
)
Group by areaId, Hour(matchTime, INTERVAL '1' HOUR);
