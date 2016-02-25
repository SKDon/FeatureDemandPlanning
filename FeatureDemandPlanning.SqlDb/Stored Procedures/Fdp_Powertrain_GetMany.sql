CREATE PROCEDURE dbo.Fdp_Powertrain_GetMany
	  @FdpVolumeHeaderId	INT
	, @MarketId				INT = NULL
AS

	SET NOCOUNT ON;

	SELECT
		  FdpPowertrainDataItemId
		, CreatedOn
		, CreatedBy
		, FdpVolumeHeaderId
		, DocumentId
		, Gateway
		, MarketId
		, EngineId
		, Size
		, Turbo
		, Cylinder
		, Electrification
		, Fuel_Type
		, BodyId
		, Shape
		, Wheelbase
		, Doors
		, TransmissionId
		, Drivetrain
		, [Type]
		, Volume
		, PercentageTakeRate
		, UpdatedOn
		, UpdatedBy
	FROM
	Fdp_PowertrainDataItem_VW AS P
	WHERE
	P.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(@MarketId IS NULL OR P.MarketId = @MarketId);