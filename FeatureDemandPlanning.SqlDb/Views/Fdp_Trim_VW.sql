



CREATE VIEW [dbo].[Fdp_Trim_VW] AS

	SELECT 
		  D.Id				AS DocumentId
		, T.Programme_Id	AS ProgrammeId
		, G.Gateway
		, ISNULL(T.Created_On, D.Created_On) AS CreatedOn
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
		, ISNULL(T.Active, 0) AS IsActive
		, CAST(0 AS BIT)    AS IsArchived
	FROM
	OXO_Doc						AS D
	JOIN OXO_Programme_Trim		AS T	ON D.Programme_Id	= T.Programme_Id
	JOIN Fdp_Gateways_VW		AS G	ON T.Programme_Id	= G.ProgrammeId
										AND G.IsArchived	= 0
	WHERE
	ISNULL(D.Archived, 0) = 0

	UNION

	SELECT 
		  D.Id				AS DocumentId
		, T.Programme_Id	AS ProgrammeId
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
		, ISNULL(T.Active, 0)			AS IsActive
		, CAST(1 AS BIT)	AS IsArchived
	FROM
	OXO_Doc									AS D
	JOIN OXO_Archived_Programme_Trim		AS T	ON D.Id				= T.Doc_Id
	JOIN Fdp_Gateways_VW					AS G	ON T.Programme_Id	= G.ProgrammeId
													AND G.IsArchived	= 1
	WHERE
	ISNULL(D.Archived, 0) = 1
	
	
	UNION
	
	SELECT
		  D.Id					AS DocumentId 
		, T.ProgrammeId
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
		, ISNULL(D.Archived, 0) AS IsArchived
	FROM 
	OXO_Doc	AS D
	JOIN Fdp_Trim AS T ON D.Programme_Id = T.ProgrammeId
						AND D.Gateway		= T.Gateway
	JOIN Fdp_TrimLevels	AS L ON T.FdpTrimId = L.FdpTrimId
	WHERE
	T.IsActive = 1