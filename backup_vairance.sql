-- Pavel Voropaev
-- OPS Center 7.7.3 report for backup variance, which sometimes appears broken in updated OPS Center
-- Variance is calculated using annual average.
-- Picks up only full schedules which where completed partially or successfully for the last 7 days


SELECT
  c.friendlyName                                                                                  AS "Master Server",
  a.clientName                                                                                    AS "Client Name",
  a.policyName                                                                                    AS "Policy Name",
  a.scheduleName                                                                                  AS "Schedule Name",
  UTCBigIntToNomTime(
      a.startTime)                                                                                AS "Last Backup Start Time",
  SecToTime(DATEDIFF(MINUTE, UTCBigIntToNomTime(a.startTime), UTCBigIntToNomTime(
      a.endTime)))                                                                                AS "Job Duration(Minutes)",
  CAST(a.bytesWritten / 1024 / 1024 / 1024 AS NUMERIC(20, 2))                                     AS "Backup Size, MB",
  b.avgbytesWritten                                                                               AS "Average Backup Size",
  COALESCE(CAST((b.avgbytesWritten - a.bytesWritten) / b.avgbytesWritten AS NUMERIC(20, 2)), 999) AS "Variance"
FROM "domain_JobArchive" a
  LEFT JOIN "domain_MasterServer" c ON (c.id = a.masterServerId)
  LEFT JOIN
  (SELECT
     masterServerId,
     clientName,
     AVG(bytesWritten) AS avgbytesWritten
   FROM domain_JobArchive
   WHERE
     scheduleType = 0 AND
     (statusCode < 2) AND
     type = 0 AND
     DATEDIFF(MONTH, UTCBigIntToNomTime(startTime), GETDATE()) <= 12
   GROUP BY masterServerId, clientName) b ON (a.masterServerId = b.masterServerId AND a.clentName = b.clientName)
WHERE a.scheduleType = 0 AND
      (a.statusCode < 2) AND
      a.type = 0 AND
      DATEDIFF(DAY, UTCBigIntToNomTime(startTime), GETDATE()) <= 7
ORDER BY "Variance" DESC