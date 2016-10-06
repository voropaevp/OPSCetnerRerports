SELECT
  c.friendlyName                                              AS "Master Server",
  a.policyName                                                AS "Policy Name",
  d.srcStorageUnit                                            AS "Source STU",
  d.destStorageUnit                                           AS "Dest STU",
  b.id                                                        AS "Dest Media ID",
  b.barcode                                                   AS "Dest Barcode",
  UTCBigIntToNomTime(b.exirationTime)                         AS "Dest Media Exiration",
  UTCBigIntToNomTime(a.startTime)                             AS "Duplication Start Time",
  SecToTime(DATEDIFF(MINUTE, UTCBigIntToNomTime(a.startTime), UTCBigIntToNomTime(
      a.endTime)))                                            AS "Job Duration(Minutes)",
  CAST(a.bytesWritten / 1024 / 1024 / 1024 AS NUMERIC(20, 2)) AS "Backup Size, MB"
FROM "nb_JobBackupAttributesArchive" d
  LEFT JOIN "domain_MasterServer" c ON (c.id = a.masterServerId)
  LEFT JOIN "domain_JobArchive" a ON (a.masterServerId = d.masterServerId AND a.jobId = d.jobId)
  LEFT JOIN "domain_Media" b ON (a.masterServerId = b.masterServerId AND b.id = d.destMediaId)
WHERE a.statusCode = 0 AND
      a.type = 4 AND
      DATEDIFF(hours, UTCBigIntToNomTime(startTime), GETDATE()) <= 24
;