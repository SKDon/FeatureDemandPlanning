CREATE PROCEDURE dbo.Fdp_MarketGroup_GetMany
	@DocumentId INT
AS
	SET NOCOUNT ON;

	WITH Models AS
	(
		SELECT
			  MG.MarketGroupId
			, SUM(OxoVariantCount) AS OxoVariantCount
			, SUM(FdpVariantCount) AS FdpVariantCount
			, SUM(OxoVariantCount) + SUM(FdpVariantCount) AS VariantCount
		FROM
		(
			SELECT 
				  D1.Market_Group_Id			AS MarketGroupId
				, COUNT(DISTINCT D1.Model_Id) AS OxoVariantCount
				, 0 AS FdpVariantCount
			FROM 
			Fdp_VolumeHeader			AS H
			JOIN OXO_Doc				AS D	ON	H.DocumentId	= D.Id
			JOIN OXO_Programme_Model	AS M	ON	D.Programme_Id	= M.Programme_Id
												AND M.Active		= 1
			JOIN OXO_Item_Data_MBM		AS D1	ON	M.Id			= D1.Model_Id
			WHERE
			D.Id = @DocumentId
			GROUP BY
			D1.Market_Group_Id

			UNION

			SELECT
					D1.MarketGroupId
					, 0 AS OxoVariantCount
					, COUNT(DISTINCT D1.FdpModelId) AS FdpVariantCount
			FROM
			Fdp_VolumeHeader			AS H
			JOIN OXO_Doc				AS D	ON	H.DocumentId	= D.Id
			JOIN Fdp_Model_VW			AS M	ON	D.Programme_Id	= M.ProgrammeId
												AND D.Gateway		= M.Gateway
			JOIN Fdp_VolumeDataItem		AS D1	ON	M.FdpModelId	= D1.FdpModelId
			WHERE
			D.Id = @DocumentId
			GROUP BY
			D1.MarketGroupId
		)
		AS MG
		GROUP BY
		MG.MarketGroupId
	)
	, MarketGroups AS
	(
		SELECT 
			  DISTINCT 'Programme'	AS [Type]
			, M.Market_Group_Id		AS Id
			, D.Programme_Id		AS ProgrammeId
			, M.Market_Group_Name	AS GroupName
			, M.Display_Order
		FROM
		Fdp_VolumeHeader						AS H
		JOIN OXO_Doc							AS D ON H.DocumentId	= H.DocumentId
		JOIN OXO_Programme_MarketGroupMarket_VW AS M ON D.Programme_Id	= M.Programme_Id
		WHERE
		D.Id = @DocumentId	
	)	
		
	SELECT 
		  G.[Type]
		, G.Id
		, G.ProgrammeId
		, G.GroupName
		, G.Display_Order
		, ISNULL(M.VariantCount, 0) AS VariantCount
	FROM 
	MarketGroups		AS G
	LEFT JOIN Models	AS M	ON G.Id = M.MarketGroupId
	ORDER BY 
	Display_Order;
	    		    
	WITH Models AS
	(
		SELECT
			  M.MarketId
			, SUM(M.OxoVariantCount) AS OxoVariantCount
			, SUM(M.FdpVariantCount) AS FdpVariantCount
			, SUM(M.OxoVariantCount) + SUM(FdpVariantCount) AS VariantCount
		FROM
		(
			SELECT 
				  D1.Market_Id					AS MarketId
				, COUNT(DISTINCT D1.Model_Id)	AS OxoVariantCount
				, 0 AS FdpVariantCount
			FROM 
			Fdp_VolumeHeader			AS H
			JOIN OXO_Doc				AS D	ON	H.DocumentId	= D.Id
			JOIN OXO_Programme_Model	AS M	ON	D.Programme_Id	= M.Programme_Id
												AND M.Active		= 1
			JOIN OXO_Item_Data_MBM		AS D1	ON	M.Id			= D1.Model_Id
			WHERE
			D.Id = @DocumentId
			GROUP BY
			D1.Market_Id

			UNION

			SELECT
				  D1.MarketId
				, 0 AS OxoVariantCount
				, COUNT(DISTINCT D1.FdpModelId) AS FdpVariantCount
			FROM
			Fdp_VolumeHeader			AS H
			JOIN OXO_Doc				AS D	ON	H.DocumentId	= D.Id
			JOIN Fdp_Model_VW			AS M	ON	D.Programme_Id	= M.ProgrammeId
												AND D.Gateway		= M.Gateway
			JOIN Fdp_VolumeDataItem		AS D1	ON	M.FdpModelId	= D1.FdpModelId
			WHERE
			D.Id = @DocumentId
			GROUP BY
			D1.MarketId
		)
		AS M
		GROUP BY
		M.MarketId
	)
	, Markets AS
	(
		SELECT Distinct 
			M.Market_Id,
			M.Market_Name,
			M.WHD AS WHD,
			M.PAR AS PAR_X,
			M.PAR AS PAR_L,
			M.Market_Group_Id,
			M.SubRegion,
			M.SubRegionOrder
		FROM 
		Fdp_VolumeHeader						AS H
		JOIN OXO_Doc							AS D	ON	H.DocumentId	= D.Id
		JOIN OXO_Programme_MarketGroupMarket_VW AS M	ON	D.Programme_Id	= M.Programme_Id
		WHERE 
		D.Id = @DocumentId	
	)
	SELECT 
		  MK.Market_Id			AS Id
		, MK.Market_Name		AS Name
		, MK.WHD
		, MK.PAR_X
		, MK.PAR_L
		, MK.Market_Group_Id	AS ParentId
		, MK.SubRegion
		, MK.SubRegionOrder
		, ISNULL(M.VariantCount, 0) AS VariantCount  
	FROM Markets MK
	LEFT JOIN Models M ON MK.Market_Id = M.MarketId
	ORDER BY 
	ParentId, SubRegionOrder, SubRegion, Name;