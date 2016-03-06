CREATE FUNCTION dbo.fn_Fdp_AvailableModelByMarket_GetMany
(
	  @FdpVolumeHeaderId	INT
	, @MarketId				INT
)
RETURNS 
@AvailableModel TABLE 
(
	  StringIdentifier  NVARCHAR(20)
   	, DisplayOrder		INT				NULL
	, VehicleName		NVARCHAR(1000)
	, VehicleAKA		NVARCHAR(1000)
	, ModelYear			NVARCHAR(100)	NULL
	, DisplayFormat		NVARCHAR(1000)	NULL      
	, Name				NVARCHAR(4000)	NULL
	, NameWithBR		NVARCHAR(4000)	NULL
	, Id				INT				NULL
	, FdpModelId		INT				NULL
	, BMC				NVARCHAR(40)	NULL
	, ProgrammeId		INT
	, BodyId			INT
	, EngineId			INT
	, TransmissionId	INT  
	, TrimId			INT				NULL
	, FdpTrimId			INT				NULL
	, DPCK				NVARCHAR(40)	NULL
	, TrimLevel			NVARCHAR(2000)	NULL
	, CoA				NVARCHAR(20)	NULL
	, Active			BIT
	, CreatedBy			NVARCHAR(32)
	, CreatedOn			DATETIME
	, UpdatedBy			NVARCHAR(32)	NULL
	, LastUpdated		DATETIME		NULL
	, Shape				NVARCHAR(100)	NULL
	, KD				BIT				NULL
	, Available			BIT
)
AS
BEGIN
	;WITH OxoData AS
	(
		SELECT OD.Model_Id 
		FROM 
		Fdp_VolumeHeader AS H
		JOIN OXO_ITEM_DATA_MBM AS OD WITH(NOLOCK) ON H.DocumentId = OD.OXO_Doc_Id
		WHERE
		H.FdpVolumeHeaderId = @FdpVolumeHeaderId
		AND OD.OXO_Code = 'Y'	
		AND OD.Market_Id = @MarketId
		AND Active = 1
	)
	, FdpData AS
	(
		SELECT DISTINCT FdpModelId
		FROM Fdp_TakeRateSummaryByModelAndMarket_VW
		WHERE
		FdpVolumeHeaderId = @FdpVolumeHeaderId
		AND
		(@MarketId IS NULL OR MarketId = @MarketId)
		AND
		FdpModelId IS NOT NULL
	)
	INSERT INTO @AvailableModel
	(
		  StringIdentifier  
		, DisplayOrder		
		, VehicleName		
		, VehicleAKA		
		, ModelYear			
		, DisplayFormat		
		, Name				
		, NameWithBR		
		, Id				
		, FdpModelId		
		, BMC				
		, ProgrammeId		
		, BodyId			
		, EngineId			
		, TransmissionId	
		, TrimId			
		, FdpTrimId			
		, DPCK				
		, TrimLevel			
		, CoA				
		, Active			
		, CreatedBy			
		, CreatedOn			
		, UpdatedBy			
		, LastUpdated		
		, Shape				
		, KD				
		, Available			
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
	                 
		FROM 
		Fdp_VolumeHeader_VW AS H
		CROSS APPLY dbo.FN_Programme_Models_Get(H.ProgrammeId, H.DocumentId)  M
		LEFT JOIN OxoData A ON M.ID = A.Model_Id
		WHERE
		H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	    
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
		Fdp_VolumeHeader_VW		AS H
		JOIN Fdp_Model_VW		AS M	ON	H.ProgrammeId	= M.ProgrammeId
										AND H.Gateway		= M.Gateway
		JOIN FdpData			AS D	ON	M.FdpModelId	= D.FdpModelId
		WHERE
		H.FdpVolumeHeaderId = @FdpVolumeHeaderId
    )
    AS MODELS
    ORDER BY
	MODELS.DisplayOrder;
	
	RETURN 
END