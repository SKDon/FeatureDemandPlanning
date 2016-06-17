CREATE PROCEDURE [dbo].[Fdp_TakeRateDataModel_GetModels]   
	  @FdpVolumeHeaderId	INT
	, @MarketId				INT
	, @BMC					NVARCHAR(5) = NULL
	, @DPCK					NVARCHAR(5) = NULL
	, @PageIndex			INT = NULL
	, @PageSize				INT = NULL
	, @TotalRecords			INT OUTPUT
	, @TotalDisplayRecords	INT OUTPUT
	, @TotalPages			INT OUTPUT
AS
	SET NOCOUNT ON;
	
	DECLARE @Models AS TABLE
	(
		  StringIdentifier		NVARCHAR(40) 	NULL
		, DisplayOrder			INT				NULL
		, VehicleName			NVARCHAR(2000) 	NULL
		, VehicleAKA			NVARCHAR(2000) 	NULL
		, ModelYear				NVARCHAR(200) 	NULL
		, DisplayFormat			NVARCHAR(2000) 	NULL
		, Name					NVARCHAR(MAX)	NULL
		, NameWithBR			NVARCHAR(MAX)	NULL
		, Id					INT				NULL
		, FdpModelId			INT				NULL
		, BMC					NVARCHAR(80)	NULL
		, ProgrammeId			INT				NULL
		, BodyId				INT				NULL
		, EngineId				INT				NULL
		, TransmissionId		INT				NULL
		, TrimId				INT				NULL
		, FdpTrimId				INT				NULL
		, DPCK					NVARCHAR(80)	NULL
		, TrimLevel				NVARCHAR(4000)	NULL
		, CoA					NVARCHAR(40)	NULL
		, Active				BIT				NULL
		, CreatedBy				NVARCHAR(64)	NULL
		, CreatedOn				DATETIME		NULL
		, UpdatedBy				NVARCHAR(64)	NULL		
		, LastUpdated			DATETIME		NULL
		, Shape					NVARCHAR(200)	NULL
		, KD					BIT				NULL
		, Available				BIT				NULL
		, TotalRecords			INT				NULL
		, TotalDisplayRecords	INT				NULL
		, TotalPages			INT				NULL
	)
	
	IF @PageIndex IS NULL
	BEGIN
		PRINT '1'
		INSERT INTO @Models
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
		FROM
		dbo.fn_Fdp_AvailableModelByMarketWithPaging_GetMany(@FdpVolumeHeaderId, @MarketId, NULL, NULL) AS M
		WHERE
		M.Available = 1
		AND
		(@BMC IS NULL OR M.BMC = @BMC)
		AND
		(@DPCK IS NULL OR M.DPCK = @DPCK)
		ORDER BY 
		M.DisplayOrder
		
		SELECT @TotalPages = 1, @TotalDisplayRecords = COUNT(1), @TotalRecords = COUNT(1) FROM @Models
	END
	ELSE
	BEGIN
		PRINT '2'
		INSERT INTO @Models
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
			, TotalRecords			
			, TotalDisplayRecords	
			, TotalPages			
		)
		SELECT
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
			, TotalRecords
			, TotalDisplayRecords
			, TotalPages
		FROM
		dbo.fn_Fdp_AvailableModelByMarketWithPaging_GetMany(@FdpVolumeHeaderId, @MarketId, @PageIndex, @PageSize) AS M
		WHERE
		M.Available = 1
		AND
		(@BMC IS NULL OR M.BMC = @BMC)
		AND
		(@DPCK IS NULL OR M.DPCK = @DPCK)
		ORDER BY 
		M.DisplayOrder
		
		SELECT TOP 1 
			  @TotalDisplayRecords = TotalDisplayRecords
			, @TotalRecords = TotalRecords
			, @TotalPages = TotalPages 
		FROM @Models;
	END
	
	SELECT 
	  M.StringIdentifier		
	, M.DisplayOrder			
	, M.VehicleName			
	, M.VehicleAKA			
	, M.ModelYear				
	, M.DisplayFormat			
	, M.Name					
	, M.NameWithBR			
	, M.Id								
	, M.BMC					
	, M.ProgrammeId			
	, M.BodyId				
	, M.EngineId				
	, M.TransmissionId		
	, M.TrimId							
	, M.DPCK					
	, M.TrimLevel				
	, M.CoA					
	, M.Active				
	, M.CreatedBy				
	, M.CreatedOn				
	, M.UpdatedBy				
	, M.LastUpdated			
	, M.Shape					
	, M.KD					
	, M.Available
	, S.TotalVolume AS Volume
	, S.PercentageTakeRate			
	FROM
	@Models AS M
	LEFT JOIN Fdp_TakeRateSummaryByModelAndMarket_VW AS S ON M.Id = S.ModelId
														  AND
														  (
															(@MarketId IS NULL AND S.MarketId IS NULL)
															OR
															(@MarketId IS NOT NULL AND S.MarketId = @MarketId)								
														  )
	ORDER BY
	DisplayOrder;