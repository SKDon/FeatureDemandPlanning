CREATE PROCEDURE [dbo].[Fdp_AvailableModelByMarket_GetMany]   
	  @FdpVolumeHeaderId	INT
	, @MarketId				INT
AS
	SET NOCOUNT ON;
	
	DECLARE @DocumentId		INT;
	DECLARE @ProgrammeId	INT;
	DECLARE @Gateway		NVARCHAR(100);
	
	SELECT TOP 1
		  @DocumentId	= D.Id
		, @ProgrammeId	= D.Programme_Id
		, @Gateway		= D.Gateway
	FROM
	Fdp_VolumeHeader	AS H
	JOIN OXO_Doc		AS D ON H.DocumentId = D.Id
	WHERE
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId;
	
	WITH OxoData AS
	(
		SELECT OD.Model_Id 
		FROM OXO_ITEM_DATA_MBM OD WITH(NOLOCK)
		WHERE OD.OXO_Doc_Id = @DocumentId
		AND OD.OXO_Code = 'Y'	
		AND OD.Market_Id = @MarketId
		AND Active = 1
	)
	, FdpData AS
	(
		SELECT DISTINCT FdpModelId
		FROM Fdp_TakeRateSummaryByModelAndMarket_VW
		WHERE 
		ProgrammeId = @ProgrammeId
		AND 
		Gateway = @Gateway
		AND
		(@MarketId IS NULL OR MarketId = @MarketId)
		AND
		FdpModelId IS NOT NULL
	)
	SELECT 
		  MODELS.StringIdentifier 
		, MODELS.DisplayOrder
		, MODELS.VehicleName
		, MODELS.VehicleAKA
		, MODELS.ModelYear
		, MODELS.DisplayFormat
		, MODELS.Name
		, MODELS.NameWithBR
		, MODELS.Id
		, MODELS.FdpModelId
		, MODELS.BMC
		, MODELS.ProgrammeId
		, MODELS.BodyId
		, MODELS.EngineId
		, MODELS.TransmissionId
		, MODELS.TrimId
		, MODELS.FdpTrimId
		, MODELS.DPCK
		, MODELS.TrimLevel
		, MODELS.CoA
		, MODELS.Active
		, MODELS.CreatedBy
		, MODELS.CreatedOn
		, MODELS.UpdatedBy
		, MODELS.LastUpdated
		, MODELS.Shape
		, MODELS.KD
		, CAST(CASE WHEN @MarketId IS NULL THEN 1 ELSE MODELS.Available END AS BIT) AS Available
	FROM
	(	
		SELECT DISTINCT 
		'O' + CAST(M.Id AS NVARCHAR(10)) AS StringIdentifier,
   		DisplayOrder,	
		VehicleName,
		VehicleAKA,
		ModelYear,    
		DisplayFormat,        
		Name,       
		NameWithBR,   
		M.Id  AS Id,
		NULL AS FdpModelId,
		M.BMC,
		M.Programme_Id  AS ProgrammeId,  
		M.Body_Id  AS BodyId,  
		M.Engine_Id  AS EngineId,
		M.Transmission_Id  AS TransmissionId,  
		M.Trim_Id  AS TrimId, 
		NULL AS FdpTrimId,
		M.DPCK,
		M.[Level] AS TrimLevel,
		M.CoA, 
		M.Active,  
		M.Created_By  AS CreatedBy,  
		M.Created_On  AS CreatedOn,  
		M.Updated_By  AS UpdatedBy,  
		M.Last_Updated  AS LastUpdated,
		Shape,
		M.KD,
		CASE WHEN A.Model_Id IS NULL THEN 0
		ELSE 1
		END AS Available
	                 
		FROM dbo.FN_Programme_Models_Get(@ProgrammeId, @DocumentId)  M
		LEFT OUTER JOIN OxoData A
		ON M.ID = A.Model_Id
	    
		UNION
	    
		SELECT 
			  'F' + CAST(M.FdpModelId AS NVARCHAR(10)) AS StringIdentifier
			, M.DisplayOrder
			, M.VehicleName
			, M.VehicleAKA
			, M.ModelYear    
			, M.DisplayFormat        
			, M.Name       
			, M.NameWithBR   
			, NULL			AS Id
			, M.FdpModelId
			, M.BMC
			, M.ProgrammeId  
			, M.BodyId
			, M.EngineId
			, M.TransmissionId  
			, M.TrimId
			, M.FdpTrimId
			, M.DPCK
			, M.[Level] AS TrimLevel
			, M.CoA
			, M.IsActive	AS Active  
			, M.CreatedBy 
			, M.CreatedOn  
			, M.UpdatedBy 
			, M.UpdatedOn AS LastUpdated
			, Shape
			, M.KD
			, CAST(1 AS BIT) AS Available
		FROM
		Fdp_Model_VW	AS M
		JOIN FdpData	AS D	ON	M.FdpModelId = D.FdpModelId
		WHERE
		M.ProgrammeId = @ProgrammeId
		AND
		M.Gateway = @Gateway
    )
    AS MODELS
    ORDER BY
	MODELS.DisplayOrder;