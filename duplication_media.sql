-- Pavel Voropaev
-- OPS Center 7.7.3 report
-- 

SELECT
  b.friendlyName                      AS "Master Server",
  c.policyName                        AS "Policy Name",
  a.srcStorageUnit                    AS "Source STU",
  a.destStorageUnit                   AS "Dest STU",
  d.id                                AS "Dest Media ID",
  d.barcode                           AS "Dest Barcode",
  UTCBigIntToNomTime(d.exirationTime) AS "Dest Media Exiration",
  UTCBigIntToNomTime(c.startTime)     AS "Duplication Start Time",
  SecToTime(DATEDIFF(MINUTE, UTCBigIntToNomTime(c.startTime), UTCBigIntToNomTime(
      c.endTime)))                                            AS "Job Duration(Minutes)",
  CAST(c.bytesWritten / 1024 / 1024 / 1024 AS NUMERIC(20, 2)) AS "Backup Size, MB"
FROM "nb_JobBackupAttributesArchive" a
  LEFT JOIN "domain_MasterServer" b ON (b.id = a.masterServerId)
  LEFT JOIN "domain_JobArchive" c ON (c.masterServerId = a.masterServerId AND c.jobId = a.jobId)
  LEFT JOIN "domain_Media" d ON (c.masterServerId = d.masterServerId AND d.id = a.destMediaId)
WHERE c.statusCode = 0 AND
      c.type = 4 AND
      DATEDIFF(hour, UTCBigIntToNomTime(startTime), GETDATE()) <= 24
;