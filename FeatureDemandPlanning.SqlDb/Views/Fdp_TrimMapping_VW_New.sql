CREATE VIEW [dbo].[Fdp_TrimMapping_VW_New] AS

	SELECT 
		  T.CreatedOn
		, T.CreatedBy
		, P.Id				AS ProgrammeId
		, T.Gateway			AS Gateway
		, T.Name			AS ImportTrim
		, T.Name			AS MappedTrim
		, T.Abbreviation
		, T.[Level]		
		, CAST(0 AS BIT)	AS IsMappedTrim
		, T.IsFdpTrim
		, T.TrimId
		, T.FdpTrimId
		, CAST(NULL AS INT)	AS FdpTrimMappingId
		, T.UpdatedOn
		, T.UpdatedBy
		
	FROM
	OXO_Programme		AS P
	JOIN Fdp_Trim_VW	AS T	ON	P.Id = T.ProgrammeId
											
	UNION
	
	SELECT 
		  M.CreatedOn
		, M.CreatedBy
		, T.ProgrammeId
		, T.Gateway
		, M.ImportTrim			AS ImportTrim
		, T.Name				AS MappedTrim
		, T.Abbreviation
		, T.[Level]		
		, CAST(1 AS BIT)		AS IsMappedTrim
		, T.IsFdpTrim
		, T.TrimId
		, NULL					AS FdpTrimId
		, M.FdpTrimMappingId
		, M.UpdatedOn
		, M.UpdatedBy
		
	FROM
	Fdp_Trim_VW				AS T
	JOIN Fdp_TrimMapping	AS M	ON	T.TrimId			= M.TrimId
									AND	T.ProgrammeId		= M.ProgrammeId
									AND T.Gateway			= M.Gateway
									AND M.IsActive			= 1