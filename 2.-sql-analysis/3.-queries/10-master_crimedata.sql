WITH Z AS (
	SELECT *
	FROM crimedata2000
	
	UNION ALL
	
	SELECT *
	FROM crimedata2002
	
	UNION ALL
	
	SELECT *
	FROM crimedata2004
	
	UNION ALL
	
	SELECT *
	FROM crimedata2006
	
	UNION ALL
	
	SELECT *
	FROM crimedata2008
	
	UNION ALL
	
	SELECT *
	FROM crimedata2010
	
	UNION ALL
	
	SELECT *
	FROM crimedata2012
	
	UNION ALL
	
	SELECT *
	FROM crimedata2014
	
	UNION ALL
	
	SELECT *
	FROM crimedata2016
)


SELECT *
INTO mastercrimedata
FROM Z
WHERE Year IS NOT NULL