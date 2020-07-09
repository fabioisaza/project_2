
-- SELECT DISTINCT racename
-- FROM general_electiondata
-- ORDER BY racename

-- SELECT DISTINCT juris1num
-- FROM general_electiondata
-- ORDER BY juris1num

-- SELECT *
-- FROM general_electiondata
-- WHERE precincts <> precinctsreporting

-- SELECT electionyear
-- ,	COUNT(DISTINCT countyname)
-- FROM clean_general_electiondata
-- GROUP BY electionyear

WITH Z AS (
	SELECT ROW_NUMBER() OVER (ORDER BY electiondate ASC, racename ASC, countyname ASC, canvotes DESC) AS candidate_id
	,	RANK() OVER (ORDER BY electiondate ASC, racecode ASC,  COALESCE(juris1num, '0') ASC, COALESCE(juris2num, '0') ASC, countyname ASC) AS county_lvl_election_id
	,	RANK() OVER (ORDER BY electiondate ASC, racecode ASC,  COALESCE(juris1num, '0') ASC, COALESCE(juris2num, '0') ASC) AS state_lvl_election_id
	,	date_part('year', electiondate) AS electionyear
	,	electiondate
	,	partycode
	,	partyname
	,	racecode
	,	racename
	,	CASE WHEN racename LIKE '%Shall%Judge%be%retained%' 
			   OR racename LIKE '%Shall%Justice%be%retained%' 
			   OR racename LIKE '%JUDICIAL%'
			   OR racename LIKE '%COURTS%'
			   OR racename LIKE '%Judge%'									THEN 'Judicial'
			 WHEN racename LIKE '%Governor%'								THEN 'Governor'
			 WHEN racename LIKE '%President%United%States'					THEN 'President of the United States'
			 WHEN racename LIKE '%No.%:%' 
			   OR racename LIKE '%Amendment%' 
			   OR racename LIKE '%Property%' 
			   OR racename LIKE '%PROPERTY%'
			   OR racename LIKE '%Prohibit%' 
			   OR racename LIKE '%PROHIBIT%'
			   OR racename LIKE '%Provision%'	
			   OR racename LIKE '%Domain%'
			   OR racename LIKE '%Requir%' 
			   OR racename LIKE '%REQUIR%'
			   OR racename LIKE '%LIMIT%'
			   OR racename LIKE '%Revision%' 
			   OR racename LIKE '%Right%' 
			   OR racename LIKE '%Exempt%' 
			   OR racename LIKE '%EXEMPT%'
			   OR racename LIKE '%Use%'	
			   OR racename LIKE '%Gambling%' 
			   OR racename LIKE '%Conservation%' 
			   OR racename LIKE '%Relig%' 
			   OR racename LIKE '%RELIG%'
			   OR racename LIKE '%Abuse%'
			   OR racename LIKE '%SERVICE%'
			   OR racename LIKE '%Referend%' 
			   OR racename LIKE '%REFEREND%'
			   OR racename LIKE '%Initiative%'
			   OR racename LIKE '%Operation%'
			   OR racename LIKE '%Planning%'
			   OR racename LIKE '%Shall%be%approved%'
			   OR racename LIKE '%Shall%be%vote%'
			   OR racename LIKE '%Benefit%'
			   OR racename LIKE '%Protect%' 
			   OR racename LIKE '%Tax%'
			   OR racename LIKE '%TAX%'
			   OR racename LIKE '%STANDARD%'
			   OR racename LIKE '%Option%'
			   OR racename LIKE 'End%'						   			THEN 'Ballot initiative/Amendment'
			 WHEN racename LIKE '%District%' 
			   OR racename LIKE	'% Dist%' 								THEN 'Municipal District'
			 WHEN racename LIKE '%Commissioner%'						THEN 'Commissioners'
			 WHEN racename LIKE '%Authority%' 
			   OR racename LIKE '%Defender%'
			   OR racename LIKE '%STUDENT%BODY%'						THEN 'Minor office'
			 ELSE racename END 
		AS racename_category
	,	countycode
	,	CASE WHEN countycode = 'DES' 	THEN 'DeSoto' 					ELSE countyname 					END AS countyname 
	,	COALESCE(juris1num, '0') AS district_circuitnumber
	,	COALESCE(juris2num, '0') AS group_seatnumber
	,	precincts
	,	CASE WHEN cannamemiddle = '/' 	THEN '' 						ELSE COALESCE(cannamefirst, '') 	END AS cannamefirst
	,	CASE WHEN cannamemiddle = '/' 	THEN ''							ELSE COALESCE(cannamemiddle, '')	END AS cannamemiddle
	,	CASE WHEN cannamemiddle = '/'	THEN cannamefirst				ELSE COALESCE(cannamelast, '')		END AS cannamelast 
	,	CASE WHEN cannamemiddle = '/' 	THEN cannamelast			 	ELSE '' 							END AS runningmate
	,	canvotes
	FROM general_electiondata
)

,	A AS (
	SELECT county_lvl_election_id
	,	SUM(canvotes) AS county_totalvotes
	FROM Z
	GROUP BY county_lvl_election_id
)

,	Y AS (
	SELECT candidate_id
	,	RANK() OVER (ORDER BY cannamefirst ASC, cannamemiddle ASC, cannamelast ASC) AS name_id 
	,	Z.county_lvl_election_id
	,	state_lvl_election_id
	,	electionyear
	,	electiondate
	,	partycode
	,	partyname
	,	racecode
	,	racename
	,	racename_category
	,	countycode
	,	countyname
	,	district_circuitnumber
	,	group_seatnumber
	,	precincts
	,	cannamefirst
	,	cannamemiddle
	,	cannamelast 
	,	runningmate
	,	canvotes
	,	A.county_totalvotes
	FROM Z
	LEFT JOIN A ON Z.county_lvl_election_id = A.county_lvl_election_id
	-- ORDER BY electiondate
	-- ,	racename
	-- ,	countyname
	-- ORDER BY election_id ASC
)
	
,	X AS (
	SELECT  electiondate
	,	racename
	,	district_circuitnumber
	,	group_seatnumber
	,	cannamefirst
	,	cannamemiddle
	,	cannamelast
	,	COUNT(countyname) AS county_lvl_on_ballot_count
	FROM Y
	GROUP BY electiondate
	,	racename
	,	district_circuitnumber
	,	group_seatnumber
	,	cannamefirst
	,	cannamemiddle
	,	cannamelast
	-- ORDER BY COUNT(countyname) DESC
)

,	W AS (
	SELECT Y.*
	,	X.county_lvl_on_ballot_count
	FROM Y
	LEFT JOIN X ON Y.electiondate = X.electiondate 
		  	   AND Y.racename = X.racename 
			   AND Y.district_circuitnumber = X.district_circuitnumber 
			   AND Y.group_seatnumber = X.group_seatnumber
			   AND Y.cannamefirst = X.cannamefirst
			   AND Y.cannamemiddle = X.cannamemiddle
			   AND Y.cannamelast = X.cannamelast
	-- ORDER BY county_lvl_election_id
)

,	V AS (
	SELECT county_lvl_election_id
	,	MAX(county_lvl_on_ballot_count) AS max_county_lvl_on_ballot_count
	FROM W
	GROUP BY county_lvl_election_id
)

SELECT W.*
,	V.max_county_lvl_on_ballot_count
,	CASE WHEN V.max_county_lvl_on_ballot_count = 67 /*OR racename = 'United States Representative'*/ THEN 'State Election' ELSE 'Local Election' END AS local_state_election
	,	CASE WHEN W.county_totalvotes = 0 THEN 0
			 ELSE ROUND(100*W.canvotes/CAST(W.county_totalvotes AS numeric), 2) END
		AS county_percent_canvotes 
,	ROW_NUMBER() OVER (PARTITION BY W.county_lvl_election_id ORDER BY W.canvotes DESC) AS place
-- INTO clean_general_electiondata
FROM W
LEFT JOIN V ON W.county_lvl_election_id = V.county_lvl_election_id
ORDER BY county_lvl_election_id;

-- ALTER TABLE clean_general_electiondata ADD PRIMARY KEY (candidate_id)


