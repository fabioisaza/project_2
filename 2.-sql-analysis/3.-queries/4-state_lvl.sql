--State View
WITH Z AS (
--Total Votes
	SELECT state_lvl_election_id
	,	SUM(canvotes) AS totalvotes
	FROM clean_general_electiondata
	GROUP BY state_lvl_election_id
)

SELECT name_id
,	G.state_lvl_election_id
,	electionyear
,	electiondate
,	partycode
,	partyname
,	racecode
,	racename
,	racename_category
-- ,	countycode
-- ,	countyname
,	district_circuitnumber
,	group_seatnumber
,	cannamefirst
,	cannamemiddle
,	cannamelast
,	runningmate
,	SUM(canvotes) AS canvotes
,	MAX(Z.totalvotes) AS totalvotes
,	ROUND(100*SUM(canvotes)/CAST(MAX(Z.totalvotes) AS numeric), 2) AS percent_canvotes
,	ROW_NUMBER() OVER (PARTITION BY G.state_lvl_election_id ORDER BY SUM(canvotes) DESC) AS place
,	CASE WHEN (ROW_NUMBER() OVER (PARTITION BY G.state_lvl_election_id ORDER BY SUM(canvotes) DESC)) = 1 THEN 1 ELSE 0 END AS winner
,	local_state_election
INTO state_lvl_electiondata
FROM clean_general_electiondata G
LEFT JOIN Z ON G.state_lvl_election_id = Z.state_lvl_election_id
GROUP BY name_id
,	G.state_lvl_election_id
,	electionyear
,	electiondate
,	partycode
,	partyname
,	racecode
,	racename
,	racename_category
-- ,	countycode
-- ,	countyname
,	district_circuitnumber
,	group_seatnumber
,	cannamefirst
,	cannamemiddle
,	cannamelast
,	runningmate
,	local_state_election
ORDER BY G.state_lvl_election_id;


	
	
