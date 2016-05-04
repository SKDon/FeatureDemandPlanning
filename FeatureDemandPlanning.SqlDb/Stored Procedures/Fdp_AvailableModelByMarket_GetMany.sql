CREATE PROCEDURE [dbo].[Fdp_AvailableModelByMarket_GetMany]   
	  @FdpVolumeHeaderId	INT
	, @MarketId				INT
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
		dbo.fn_Fdp_AvailableModelByMarket_GetMany(@FdpVolumeHeaderId, @MarketId) AS M
		WHERE
		M.Available = 1
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
		ORDER BY 
		M.DisplayOrder
		
		SELECT TOP 1 
			  @TotalDisplayRecords = TotalDisplayRecords
			, @TotalRecords = TotalRecords
			, @TotalPages = TotalPages 
		FROM @Models;
	END
	
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
	@Models