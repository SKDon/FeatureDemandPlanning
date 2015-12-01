


CREATE VIEW [dbo].[Fdp_Trim_VW] AS

	SELECT 
		  T.Programme_Id	AS ProgrammeId
		, G.Gateway
		, T.Created_On		AS CreatedOn
		, T.Created_By		AS CreatedBy
		, T.Name
		, T.Abbreviation
		, T.[Level]
		, NULL				AS BMC
		, T.DPCK
		, T.Display_Order	AS DisplayOrder
		, T.Last_Updated	AS UpdatedOn
		, T.Updated_By		AS UpdatedBy
		, CAST(0 AS BIT)	AS IsFdpTrim
		, T.Id				AS TrimId
		, NULL				AS FdpTrimId
		, T.Active			AS IsActive
	FROM
	OXO_Programme_Trim		AS T
	JOIN Fdp_Gateways_VW	AS G	ON T.Programme_Id	= G.ProgrammeId
	
	UNION
	
	SELECT 
		  T.ProgrammeId
		, T.Gateway
		, T.CreatedOn
		, T.CreatedBy
		, T.TrimName			AS Name
		, T.TrimAbbreviation	AS Abbreviation
		, T.TrimLevel			AS [Level]
		, T.BMC
		, T.DPCK
		, L.[Level]				AS DisplayOrder
		, T.UpdatedOn
		, T.UpdatedBy
		, CAST(1 AS BIT)		AS IsFdpTrim
		, NULL					AS TrimId
		, T.FdpTrimId
		, T.IsActive
		
	FROM Fdp_Trim AS T
	JOIN Fdp_TrimLevels	AS L ON T.FdpTrimId = L.FdpTrimId
	WHERE
	T.IsActive = 1