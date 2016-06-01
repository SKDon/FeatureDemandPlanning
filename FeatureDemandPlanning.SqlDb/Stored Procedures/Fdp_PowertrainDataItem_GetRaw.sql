CREATE PROCEDURE [dbo].[Fdp_PowertrainDataItem_GetRaw]
	  @FdpVolumeHeaderId	INT
	, @MarketId				INT
	, @CDSId				NVARCHAR(16)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @FdpChangesetId INT;
	SET @FdpChangesetId = dbo.fn_Fdp_Changeset_GetLatestByUser(@FdpVolumeHeaderId, @MarketId, @CDSId);

	WITH Derivatives AS 
	(
		SELECT BMC, COUNT(M.Id) AS NumberOfModels
		FROM
		dbo.fn_Fdp_AvailableModelByMarketWithPaging_GetMany(@FdpVolumeHeaderId, @MarketId, NULL, NULL) AS M
		GROUP BY BMC
	)
	SELECT
		  H.FdpVolumeHeaderId
		, P.FdpPowertrainDataItemId
		, P.MarketId
		, M.Market_Name AS Market
		, M.Market_Group_Id AS MarketGroupId
		, M.Market_Group_Name AS MarketGroup
		, P.DerivativeCode
		, P.BodyId
		, P.EngineId
		, P.TransmissionId
		, P.Cylinder
		, P.Doors
		, P.Drivetrain
		, P.Electrification
		, P.FuelType
		, P.Shape
		, P.Size
		, P.Turbo
		, P.[Type]
		, P.Wheelbase
		, ISNULL(C.TotalVolume, P.Volume) AS Volume
		, ISNULL(C.PercentageTakeRate, P.PercentageTakeRate) AS PercentageTakeRate
		, CAST(CASE WHEN C.FdpChangesetId IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS IsDirty
		, D.NumberOfModels
		, P.[Power]
    FROM
    Fdp_VolumeHeader_VW						AS H
    JOIN Fdp_PowertrainDataItem_VW			AS P	ON	H.FdpVolumeHeaderId = P.FdpVolumeHeaderId
	JOIN Derivatives						AS D	ON	P.DerivativeCode	= D.BMC
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