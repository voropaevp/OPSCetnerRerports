CREATE FUNCTION SecToTime(seconds INT)
  RETURNS CHAR(20)
AS
  BEGIN
    RETURN (
      (SELECT RIGHT('00' + CAST(CAST(floor(seconds / 3600) AS NUMERIC(3)) AS CHAR(3)), 2)) + ':' +
      (SELECT RIGHT('00' + CAST(CAST(floor(seconds / 60) % 60 AS NUMERIC(2)) AS CHAR(2)), 2)) + ':' +
      (SELECT RIGHT('00' + CAST(CAST(seconds % 60 AS NUMERIC(2)) AS CHAR(2)), 2))
    )
  END;