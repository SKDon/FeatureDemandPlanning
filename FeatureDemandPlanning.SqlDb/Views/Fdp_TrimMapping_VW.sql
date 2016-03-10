


CREATE VIEW [dbo].[Fdp_TrimMapping_VW] AS

	SELECT
		  T.DocumentId 
		, T.CreatedOn
		, T.CreatedBy
		, T.ProgrammeId
		, T.Gateway
		, T.Name			AS ImportTrim
		, T.Name			AS MappedTrim
		, T.Abbreviation
		, T.[Level]
		, T.BMC
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
	Fdp_Trim_VW	AS T
											
	UNION
	
	SELECT 
		  T.DocumentId
		, M.CreatedOn
		, M.CreatedBy
		, T.ProgrammeId
		, T.Gateway
		, M.ImportTrim			AS ImportTrim
		, T.Name				AS MappedTrim
		, T.Abbreviation
		, T.[Level]
		, M.BMC
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
	Fdp_Trim_VW				AS T
	JOIN Fdp_TrimMapping	AS M	ON	T.TrimId			= M.TrimId
									AND	T.ProgrammeId		= M.ProgrammeId
									AND T.Gateway			= M.Gateway
									AND M.IsActive			= 1