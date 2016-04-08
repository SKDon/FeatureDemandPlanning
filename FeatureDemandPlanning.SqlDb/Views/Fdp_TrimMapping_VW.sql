







CREATE VIEW [dbo].[Fdp_TrimMapping_VW] AS

	SELECT
		  T.CreatedOn
		, T.CreatedBy
		, T.DocumentId
		, T.ProgrammeId
		, T.Gateway
		, T.Name			AS ImportTrim
		, T.Name			AS MappedTrim
		, T.Abbreviation
		, T.[Level]
		, T.ModelId
		, T.BMC
		, T.MarketId
		, T.DPCK
		, CAST(0 AS BIT)	AS IsMappedTrim
		, T.IsFdpTrim
		, T.TrimId
		, T.FdpTrimId
		, CAST(NULL AS INT)	AS FdpTrimMappingId
		, T.IsActive
		, T.UpdatedOn
		, T.UpdatedBy
		, T.IsArchived
		
	FROM
	OXO_Programme				AS P
	JOIN Fdp_Trim_VW			AS T	ON	P.Id			= T.ProgrammeId
	LEFT JOIN Fdp_TrimMapping	AS M	ON	T.DocumentId	= M.DocumentId
										AND T.BMC			= M.BMC
										AND	T.TrimId		= M.TrimId
										AND M.IsActive		= 1
	WHERE
	P.Active = 1
	AND
	M.FdpTrimMappingId IS NULL
											
	UNION
	
	SELECT 
		  M.CreatedOn
		, M.CreatedBy
		, T.DocumentId
		, T.ProgrammeId
		, T.Gateway
		, M.ImportTrim			AS ImportTrim
		, T.Name				AS MappedTrim
		, T.Abbreviation
		, T.[Level]
		, T.ModelId
		, T.BMC
		, T.MarketId
		, T.DPCK		
		, CAST(1 AS BIT)		AS IsMappedTrim
		, T.IsFdpTrim
		, T.TrimId
		, NULL					AS FdpTrimId
		, M.FdpTrimMappingId
		, M.IsActive
		, M.UpdatedOn
		, M.UpdatedBy
		, T.IsArchived
		
	FROM
	OXO_Programme			AS P
	JOIN Fdp_Trim_VW		AS T	ON	P.Id			= T.ProgrammeId
	JOIN Fdp_TrimMapping	AS M	ON	T.DocumentId	= M.DocumentId
									AND T.BMC			= M.BMC
									AND	T.TrimId		= M.TrimId
									AND M.IsActive		= 1
	WHERE
	P.Active = 1