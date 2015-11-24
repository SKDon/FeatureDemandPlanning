


CREATE VIEW [dbo].[Fdp_TrimMapping_VW] AS

	SELECT 
		  NULL			AS FdpTrimMappingId
		, T.Created_On	AS CreatedOn
		, T.Created_By	AS CreatedBy
		, P.Id			AS ProgrammeId
		, G.Gateway
		, T.Id			AS TrimId
		, T.Name		AS ImportTrim
		, T.Name		AS MappedTrim
		, T.[Level]
		, T.DPCK
		, T.Last_Updated	AS UpdatedOn
		, T.Updated_By		AS UpdatedBy
		, CAST(0 AS BIT) AS IsMappedTrim
	FROM
	OXO_Programme				AS P
	JOIN Fdp_Gateways_VW		AS G	ON	P.Id		= G.ProgrammeId
	JOIN OXO_Programme_Trim		AS T	ON	P.Id		= T.Programme_Id
	LEFT JOIN Fdp_TrimMapping	AS M	ON	P.Id		= M.ProgrammeId
										AND	T.Id		= M.TrimId
										AND G.Gateway	= M.Gateway
										AND M.IsActive	= 1
	WHERE
	M.FdpTrimMappingId IS NULL
	
	UNION
	
	SELECT 
		  M.FdpTrimMappingId
		, M.CreatedOn
		, M.CreatedBy
		, P.Id			AS ProgrammeId
		, G.Gateway
		, T.Id			AS TrimId
		, M.ImportTrim	AS ImportTrim
		, T.Name		AS MappedTrim
		, T.[Level]
		, T.DPCK
		, T.Last_Updated	AS UpdatedOn
		, T.Updated_By		AS UpdatedBy
		, CAST(1 AS BIT) AS IsMappedTrim
	FROM
	OXO_Programme				AS P
	JOIN Fdp_Gateways_VW		AS G	ON	P.Id		= G.ProgrammeId
	JOIN OXO_Programme_Trim		AS T	ON	P.Id		= T.Programme_Id
	JOIN Fdp_TrimMapping		AS M	ON	P.Id		= M.ProgrammeId
										AND	T.Id		= M.TrimId
										AND G.Gateway	= M.Gateway
										AND M.IsActive	= 1