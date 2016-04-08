

CREATE VIEW [dbo].[Fdp_Trim_VW] AS

	SELECT 
		  D.Id				AS DocumentId
		, D.Programme_Id	AS ProgrammeId
		, D.Gateway
		, ISNULL(T.Created_On, D.Created_On) AS CreatedOn
		, T.Created_By		AS CreatedBy
		, T.Name
		, T.Abbreviation
		, T.[Level]
		, M.Id				AS ModelId
		, M.BMC
		, CASE
			WHEN DPCK.Market_Id = -1 THEN NULL
			WHEN DPCK.Market_Id = 0 THEN NULL
			ELSE DPCK.Market_Id
		  END
		  AS MarketId
		, ISNULL(DPCK.DPACK, T.DPCK) AS DPCK
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
	JOIN OXO_Programme_Model	AS M	ON D.Programme_Id	= M.Programme_Id
										AND M.Active		= 1
	JOIN OXO_Programme_Trim		AS T	ON M.Trim_Id		= T.Id
										AND T.Active		= 1
	LEFT JOIN OXO_Item_Data_DPK AS DPCK	ON M.Id				= DPCK.Model_Id
										AND D.Id			= DPCK.OXO_Doc_Id
	WHERE
	ISNULL(D.Archived, 0) = 0

	UNION

	SELECT 
		  D.Id				AS DocumentId
		, D.Programme_Id	AS ProgrammeId
		, D.Gateway
		, T.Created_On		AS CreatedOn
		, T.Created_By		AS CreatedBy
		, T.Name
		, T.Abbreviation
		, T.[Level]
		, M.Id				AS ModelId
		, M.BMC
		, CASE
			WHEN DPCK.Market_Id = -1 THEN NULL
			WHEN DPCK.Market_Id = 0 THEN NULL
			ELSE DPCK.Market_Id
		  END
		  AS MarketId
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
	JOIN OXO_Archived_Programme_Model		AS M	ON	D.Programme_Id	= M.Programme_Id
													AND M.Active		= 1
	JOIN OXO_Archived_Programme_Trim		AS T	ON	D.Id			= T.Doc_Id
													AND M.Trim_Id		= T.Id
	LEFT JOIN OXO_Item_Data_DPK				AS DPCK	ON	M.Id			= DPCK.Model_Id
													AND D.Id			= DPCK.OXO_Doc_Id
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
		, CAST(NULL AS INT)		AS ModelId
		, T.BMC
		, CAST(NULL AS INT)		AS MarketId
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