WITH Z AS (
	SELECT ROW_NUMBER() OVER (ORDER BY series_id, year, period) AS county_month_id 
	,	series_id
	,	LEFT(RIGHT(series_id, LENGTH(series_id)-5), LENGTH(RIGHT(series_id, LENGTH(series_id)-5))-10) AS geo_fips
	,	year
	,	CASE WHEN period IN ('M01', 'M02', 'M03') THEN 'Q1'
			 WHEN period IN ('M04', 'M05', 'M06') THEN 'Q2'
			 WHEN period IN ('M07', 'M08', 'M09') THEN 'Q3'
			 WHEN period IN ('M10', 'M11', 'M12') THEN 'Q4'
			 ELSE '' END
		AS quarter
	,	label
	,	value
	FROM unemployment
)

,	Y AS (
	SELECT series_id
	,	geo_fips
	,	year
	,	quarter
	,	ROUND(AVG(value), 2) AS avg_monthly_quarter_value
	FROM Z
	GROUP BY series_id
	,	geo_fips
	,	year
	,	quarter
-- 	ORDER BY series_id
-- 	,	geo_fips
-- 	,	year
-- 	,	quarter
)

,	X AS (
	SELECT series_id
	,	geo_fips
	,	year
	,	ROUND(AVG(value), 2) AS avg_monthly_annual_value
	FROM Z
	GROUP BY series_id
	,	geo_fips
	,	year
)

SELECT ROW_NUMBER() OVER (ORDER BY X.series_id, X.geo_fips, X.year) AS county_year_id
,	X.series_id
,	X.geo_fips
,	X.year
,	MAX(X.avg_monthly_annual_value) AS avg_monthly_annual_value
,	MAX(CASE WHEN quarter = 'Q1' THEN avg_monthly_quarter_value ELSE 0 END) AS q1_avg_monthly_value 
,	MAX(CASE WHEN quarter = 'Q2' THEN avg_monthly_quarter_value ELSE 0 END) AS q2_avg_monthly_value 
,	MAX(CASE WHEN quarter = 'Q3' THEN avg_monthly_quarter_value ELSE 0 END) AS q3_avg_monthly_value
,	MAX(CASE WHEN quarter = 'Q4' THEN avg_monthly_quarter_value ELSE 0 END) AS q4_avg_monthly_value
-- INTO unemployment_aggregations
FROM X
LEFT JOIN Y ON X.series_id = Y.series_id AND X.geo_fips = Y.geo_fips AND X.year = Y.year
GROUP BY X.series_id
,	X.geo_fips
,	X.year
ORDER BY X.series_id
,	X.geo_fips
,	X.year;

-- ALTER TABLE unemployment_aggregations ADD PRIMARY KEY (county_year_id)