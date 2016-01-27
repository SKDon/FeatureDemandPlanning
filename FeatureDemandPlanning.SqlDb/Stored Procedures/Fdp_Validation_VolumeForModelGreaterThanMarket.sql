CREATE PROCEDURE [dbo].[Fdp_Validation_VolumeForModelGreaterThanMarket]
	  @FdpVolumeHeaderId	INT
	, @MarketId				INT			 = NULL
	, @CDSId				NVARCHAR(16) = NULL
AS

	SET NOCOUNT ON;

	-- Get our market volumes taking into account any uncommitted changes to that market
	;WITH MarketVolumes AS
	(
		SELECT
			  M.MarketId
			, ISNULL(C.TotalVolume, M.TotalVolume) AS Volume
		FROM
		Fdp_TakeRateSummaryByMarket_VW		AS M
		LEFT JOIN Fdp_ChangesetMarket_VW	AS C	ON M.FdpVolumeHeaderId	= C.FdpVolumeHeaderId
													AND M.MarketId			= C.MarketId
													AND C.CDSId				= @CDSId
		WHERE
		M.FdpVolumeHeaderId = @FdpVolumeHeaderId
		AND
		(@MarketId IS NULL OR M.MarketId = @MarketId)
	)
	INSERT INTO Fdp_Validation
	(
		  FdpVolumeHeaderId
		, MarketId
		, FdpValidationRuleId
		, [Message]
		, FdpTakeRateSummaryId
	)
	-- Regular OXO models
	SELECT
		  S.FdpVolumeHeaderId
		, S.MarketId
		, 3 -- VolumeForModelGreaterThanMarket
		, 'Volume for model cannot exceed the volume for the market'
		, S.FdpTakeRateSummaryId
	FROM
	Fdp_TakeRateSummary				AS S
	JOIN MarketVolumes				AS M	ON S.MarketId = M.MarketId
	-- Examine any uncommitted changes at model level
	LEFT JOIN Fdp_ChangesetModel_VW	AS C	ON	S.FdpVolumeHeaderId		= C.FdpVolumeHeaderId
											AND S.ModelId				= C.ModelId
											AND S.MarketId				= C.MarketId
											AND C.CDSId					= @CDSId
	LEFT JOIN Fdp_Validation		AS V	ON	S.FdpTakeRateSummaryId	= V.FdpTakeRateSummaryId
											AND V.IsActive				= 1
	WHERE
	S.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	S.ModelId IS NOT NULL
	AND
	(@MarketId IS NULL OR s.MarketId = @MarketId)
	AND
	ISNULL(C.TotalVolume, S.Volume) > M.Volume
	
	UNION
	
	-- FDP models
	SELECT
		  S.FdpVolumeHeaderId
		, S.MarketId
		, 3 -- VolumeForModelGreaterThanMarket
		, 'Volume for model cannot exceed the volume for the market'
		, S.FdpTakeRateSummaryId
	FROM
	Fdp_TakeRateSummary				AS S
	JOIN MarketVolumes				AS M	ON S.MarketId = M.MarketId
	-- Examine any uncommitted changes at model level
	LEFT JOIN Fdp_ChangesetModel_VW	AS C	ON	S.FdpVolumeHeaderId		= C.FdpVolumeHeaderId
											AND S.FdpModelId			= C.FdpModelId
											AND S.MarketId				= C.MarketId
											AND C.CDSId					= @CDSId
	LEFT JOIN Fdp_Validation		AS V	ON	S.FdpTakeRateSummaryId	= V.FdpTakeRateSummaryId
											AND V.IsActive				= 1
	WHERE
	S.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	S.FdpModelId IS NOT NULL
	AND
	(@MarketId IS NULL OR s.MarketId = @MarketId)
	AND
	ISNULL(C.TotalVolume, S.Volume) > M.Volume
	
	PRINT 'Volume for feature exceeding volume for model validation failures added: ' + CAST(@@ROWCOUNT AS NVARCHAR(10))