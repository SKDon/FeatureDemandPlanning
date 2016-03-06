CREATE PROCEDURE [dbo].[Fdp_AvailableModelByMarket_GetMany]   
	  @FdpVolumeHeaderId	INT
	, @MarketId				INT
AS
	SET NOCOUNT ON;
	
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