
WITH Z AS (
	SELECT G1.*
	,	G2.partycode AS prev_winner4_partycode
	,	G2.partyname AS prev_winner4_partyname
	,	LTRIM(CONCAT(G2.cannamefirst, ' ', G2.cannamemiddle, ' ', G2.cannamelast)) AS prev_winner4_canname
	FROM clean_general_electiondata G1
	LEFT JOIN clean_general_electiondata G2 ON G2.electionyear = CASE WHEN MOD((CAST(G1.electionyear AS bigint) - 2000), 4) = 0 THEN G1.electionyear - 4 
			 														  WHEN MOD((CAST(G1.electionyear AS bigint) - 2000), 2) = 0 THEN G1.electionyear - 2 
			 														  ELSE 0 END 
											AND G1.racecode = G2.racecode
											AND G1.countycode = G2.countycode
											AND G1.district_circuitnumber = G2.district_circuitnumber
											AND G1.group_seatnumber = G2.group_seatnumber
	WHERE G2.place = 1
	AND (
		G1.racename_category LIKE '%President%'
		OR G1.racename_category LIKE '%Senator%'
		OR G1.racename_category LIKE '%Representative%'
	)
)

,	Y AS (
	SELECT Z.*
	,	CASE WHEN Z.partycode = Z.prev_winner4_partycode THEN 1 ELSE 0 END AS prev_winner4_same_party
	,	CONCAT('12', F.fips) AS geo_fips 
	FROM Z
	LEFT JOIN geo_fips F ON CONCAT(Z.countyname, ' County') = F.county
)

,	X AS (
	SELECT Y.*
	,	U.avg_monthly_annual_value
	,	U.q1_avg_monthly_value
	,	U.q2_avg_monthly_value
	,	U.q3_avg_monthly_value
	,	U.q4_avg_monthly_value
	FROM Y
	LEFT JOIN unemployment_aggregations U ON Y.geo_fips = U.geo_fips AND Y.electionyear = U.year
)	

,	W AS (
	SELECT ROW_NUMBER() OVER (PARTITION BY candidate_id ORDER BY name_id) AS dup_check
	,	X.*
	,	CAST(REPLACE(C1."Population", ',', '') AS bigint) AS Population
	,	CAST(REPLACE(C1."GDP", ',', '') AS bigint) AS GDP
	,	CAST(REPLACE(C1."Personal Income", ',', '') AS bigint) AS "Personal Income"
	,	CAST(REPLACE(C1."Per Capita Personal Income", ',', '') AS bigint) AS "Per Capita Personal Income"
	,	CAST(REPLACE(C2.population, ',', '') AS bigint) AS Population2
	,	REPLACE(C2."Total Violent Crime", ',', '') AS "Total Violent Crime"
	,	CAST(REPLACE(C2."Violent Crime Rate Per 100k", ',', '') AS numeric) AS "Violent Crime Rate Per 100k"
	,	REPLACE(C2."Violent Crime Rate Change", ',', '') AS "Violent Crime Rate Change"
	,	YT."First Primary" AS First_Primary_TO
	,	YT."Second Primary" AS Second_Primary_TO
	,	YT."General Election"
	,	CASE WHEN partycode = 'DEM' THEN 1 ELSE 0 END AS Is_Democrat
	,	CASE WHEN partycode = 'REP' THEN 1 ELSE 0 END AS Is_Republican
	,	CASE WHEN partycode NOT IN ('DEM', 'REP') THEN 1 ELSE 0 END AS Is_Independent
	FROM X
	LEFT JOIN county_analysis C1 ON X.geo_fips = C1."GeoFips" 
								 AND X.electionyear = CAST(C1."TimePeriod" AS bigint)
	LEFT JOIN mastercrimedata C2 ON X.countyname = CASE WHEN C2.county = 'Desoto' 		THEN 'DeSoto' 
														WHEN C2.county = 'Miami Dade'	THEN 'Miami-Dade'
														ELSE C2.county END
								 AND X.electionyear = C2.year
	LEFT JOIN yearly_turnout YT ON X.electionyear = YT."Year"
	WHERE place = 1 
)

SELECT *
-- INTO incumbency_analysis
FROM W
WHERE dup_check = 1
ORDER BY candidate_id
-- ,	electionyear
-- ,	countycode;
-- ,	place
;

-- ALTER TABLE incumbency_analysis ADD PRIMARY KEY (candidate_id);

-- SELECT candidate_id
-- ,	COUNT(candidate_id)
-- FROM incumbency_analysis
-- GROUP BY candidate_id 
-- HAVING COUNT(candidate_id) > 1
-- ORDER BY candidate_id

-- SELECT *
-- FROM incumbency_analysis
-- WHERE candidate_id = 16631

				 

