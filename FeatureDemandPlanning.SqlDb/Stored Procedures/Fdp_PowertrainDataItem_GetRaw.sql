CREATE PROCEDURE [dbo].[Fdp_PowertrainDataItem_GetRaw]
	  @FdpVolumeHeaderId	INT
	, @MarketId				INT
	, @CDSId				NVARCHAR(16)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @FdpChangesetId INT;
	SET @FdpChangesetId = dbo.fn_Fdp_Changeset_GetLatestByUser(@FdpVolumeHeaderId, @MarketId, @CDSId);

	SELECT
		  H.FdpVolumeHeaderId
		, P.FdpPowertrainDataItemId
		, P.MarketId
		, M.Market_Name AS Market
		, M.Market_Group_Id AS MarketGroupId
		, M.Market_Group_Name AS MarketGroup
		, P.BodyId
		, P.EngineId
		, P.TransmissionId
		, P.Cylinder
		, P.Doors
		, P.Drivetrain
		, P.Electrification
		, P.Fuel_Type AS FuelType
		, P.Shape
		, P.Size
		, P.Turbo
		, P.[Type]
		, P.Wheelbase
		, ISNULL(C.TotalVolume, P.Volume) AS Volume
		, ISNULL(C.PercentageTakeRate, P.PercentageTakeRate) AS PercentageTakeRate
    FROM
    Fdp_VolumeHeader_VW						AS H
    JOIN Fdp_PowertrainDataItem_VW			AS P	ON	H.FdpVolumeHeaderId = P.FdpVolumeHeaderId
    JOIN OXO_Programme_MarketGroupMarket_VW AS M	ON	P.MarketId			= M.Market_Id
													AND H.ProgrammeId		= M.Programme_Id							
	-- Any changeset information
	LEFT JOIN Fdp_ChangesetPowertrainDataItem_VW	AS C	ON	P.FdpPowertrainDataItemId	= C.FdpPowertrainDataItemId
															AND	C.FdpChangesetId			= @FdpChangesetId
	
    WHERE
    H.FdpVolumeHeaderId = @FdpVolumeHeaderId
    AND
    P.MarketId = @MarketId;
    
END