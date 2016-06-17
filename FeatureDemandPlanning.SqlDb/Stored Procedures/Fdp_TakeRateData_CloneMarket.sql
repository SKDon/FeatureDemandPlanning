CREATE PROCEDURE Fdp_TakeRateData_CloneMarket
	  @FdpVolumeHeaderId AS INT
	, @MarketId AS INT
	, @DestinationMarketId AS INT
	, @CDSID AS NVARCHAR(16)
AS
	SET NOCOUNT ON;

	DELETE FROM Fdp_VolumeDataItem WHERE FdpVolumeHeaderId = @FdpVolumeHeaderId AND MarketId = @DestinationMarketId
	DELETE FROM Fdp_TakeRateSummary WHERE FdpVolumeHeaderId = @FdpVolumeHeaderId AND MarketId = @DestinationMarketId
	DELETE FROM Fdp_TakeRateFeatureMix WHERE FdpVolumeHeaderId = @FdpVolumeHeaderId AND MarketId = @DestinationMarketId
	DELETE FROM Fdp_PowertrainDataItem WHERE FdpVolumeHeaderId = @FdpVolumeHeaderId AND MarketId = @DestinationMarketId

	DECLARE @DestinationMarketGroupId AS INT;
	SELECT TOP 1 @DestinationMarketGroupId = Market_Group_Id
	FROM
	Fdp_VolumeHeader_VW AS H
	JOIN OXO_Programme_MarketGroupMarket_VW AS MK ON H.ProgrammeId = MK.Programme_Id
	WHERE
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	MK.Market_Id = @DestinationMarketId;

	INSERT INTO Fdp_VolumeDataItem 
	(
		  CreatedBy
		, FdpVolumeHeaderId
		, MarketId
		, MarketGroupId
		, ModelId
		, TrimId
		, FeatureId
		, FeaturePackId
		, Volume
		, PercentageTakeRate
	)
	SELECT
		  @CDSID
		, FdpVolumeHeaderId
		, @DestinationMarketId
		, @DestinationMarketGroupId
		, ModelId
		, TrimId
		, FeatureId
		, FeaturePackId
		, Volume
		, PercentageTakeRate
	FROM
	Fdp_VolumeDataItem
	WHERE
	FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	MarketId = @MarketId;

	INSERT INTO Fdp_TakeRateSummary
	(
		  CreatedBy
		, FdpVolumeHeaderId
		, FdpSpecialFeatureMappingId
		, MarketId
		, ModelId
		, Volume
		, PercentageTakeRate
	)
	SELECT
		  @CDSID
		, FdpVolumeHeaderId
		, FdpSpecialFeatureMappingId
		, @DestinationMarketId
		, ModelId
		, Volume
		, PercentageTakeRate
	FROM
	Fdp_TakeRateSummary
	WHERE
	FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	MarketId = @MarketId;

	INSERT INTO Fdp_TakeRateFeatureMix
	(
		  CreatedBy
		, FdpVolumeHeaderId
		, MarketId
		, FeatureId
		, FeaturePackId
		, Volume
		, PercentageTakeRate
	)
	SELECT
		  @CDSID
		, FdpVolumeHeaderId
		, @DestinationMarketId
		, FeatureId
		, FeaturePackId
		, Volume
		, PercentageTakeRate
	FROM
	Fdp_TakeRateFeatureMix
	WHERE
	FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	MarketId = @MarketId;

	INSERT INTO Fdp_PowertrainDataItem
	(
		  CreatedBy
		, FdpVolumeHeaderId
		, MarketId
		, DerivativeCode
		, FdoOxoDerivativeId
		, FdpDerivativeId
		, Volume
		, PercentageTakeRate
	)
	SELECT
		  @CDSID
		, FdpVolumeHeaderId
		, @DestinationMarketId
		, DerivativeCode
		, FdoOxoDerivativeId
		, FdpDerivativeId
		, Volume
		, PercentageTakeRate
	FROM
	Fdp_PowertrainDataItem
	WHERE
	FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	MarketId = @MarketId;