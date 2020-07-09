WITH Z AS (
	SELECT *
	FROM general_election2000
	
	UNION ALL
	
	SELECT *
	FROM general_election2002
	
	UNION ALL
	
	SELECT *
	FROM general_election2004
	
	UNION ALL
	
	SELECT *
	FROM general_election2006
	
	UNION ALL
	
	SELECT *
	FROM general_election2008
	
	UNION ALL
	
	SELECT *
	FROM general_election2010
	
	UNION ALL
	
	SELECT *
	FROM general_election2012
	
	UNION ALL
	
	SELECT *
	FROM general_election2014
	
	UNION ALL
	
	SELECT *
	FROM general_election2016
	
	UNION ALL
	
	SELECT *
	FROM general_election2018
)

----Check to see if all years were successfully imported:

-- SELECT date_part('year', electiondate) AS year
-- ,	COUNT(DISTINCT date_part('year', electiondate))
-- FROM Z
-- GROUP BY date_part('year', electiondate)


--Import master table into database

SELECT *
-- INTO general_electiondata
FROM Z


