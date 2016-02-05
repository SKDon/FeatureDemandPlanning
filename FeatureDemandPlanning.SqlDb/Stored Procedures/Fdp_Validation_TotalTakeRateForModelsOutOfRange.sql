CREATE PROCEDURE [dbo].[Fdp_Validation_TotalTakeRateForModelsOutOfRange]
	  @FdpVolumeHeaderId	INT
	, @MarketId				INT			 = NULL
	, @CDSId				NVARCHAR(16) = NULL
AS

	SET NOCOUNT ON;

	-- Get our market volumes taking into account any uncommitted changes to that market
	;WITH MarketTakeRates AS
	(
		SELECT
			  M.FdpVolumeHeaderId
			, M.ProgrammeId
			, M.MarketId
			, CAST(SUM(ISNULL(C.PercentageTakeRate, ISNULL(M.PercentageTakeRate, 0))) AS DECIMAL(5,2)) AS PercentageTakeRate
		FROM
		Fdp_TakeRateSummaryByModelAndMarket_VW		AS M
		LEFT JOIN Fdp_ChangesetModel_VW				AS C	ON	M.FdpVolumeHeaderId	= C.FdpVolumeHeaderId
															AND M.MarketId			= C.MarketId
															AND M.ModelId			= C.ModelId
															AND C.CDSId				= @CDSId
		WHERE
		M.FdpVolumeHeaderId = @FdpVolumeHeaderId
		AND
		M.ModelId IS NOT NULL
		AND
		(@MarketId IS NULL OR M.MarketId = @MarketId)
		GROUP BY
		M.FdpVolumeHeaderId, M.ProgrammeId, M.MarketId

		UNION

		SELECT
			  M.FdpVolumeHeaderId
			, M.ProgrammeId
			, M.MarketId
			, CAST(SUM(ISNULL(C.PercentageTakeRate, ISNULL(M.PercentageTakeRate, 0))) AS DECIMAL(5,2)) AS PercentageTakeRate
		FROM
		Fdp_TakeRateSummaryByModelAndMarket_VW		AS M
		LEFT JOIN Fdp_ChangesetModel_VW				AS C	ON	M.FdpVolumeHeaderId	= C.FdpVolumeHeaderId
															AND M.MarketId			= C.MarketId
															AND M.FdpModelId		= C.FdpModelId
															AND C.CDSId				= @CDSId
		WHERE
		M.FdpVolumeHeaderId = @FdpVolumeHeaderId
		AND
		M.FdpModelId IS NOT NULL
		AND
		(@MarketId IS NULL OR M.MarketId = @MarketId)
		GROUP BY
		M.FdpVolumeHeaderId, M.ProgrammeId, M.MarketId
	)
	INSERT INTO Fdp_Validation
	(
		  FdpVolumeHeaderId
		, MarketId
		, FdpValidationRuleId
		, [Message]
	)
	SELECT
		  @FdpVolumeHeaderId
		, M.MarketId
		, 4 -- TotalTakeRateForModelsOutOfRange
		, 'Total take rate for models of ''' + CAST(M.PercentageTakeRate * 100 AS NVARCHAR(10)) + '%'' for market ''' + MK.Market_Name + ''' must equal 100%'
	FROM
	MarketTakeRates							AS M
	JOIN OXO_Programme_MarketGroupMarket_VW AS MK	ON	M.MarketId			= MK.Market_Id
													AND M.ProgrammeId		= MK.Programme_Id
	LEFT JOIN Fdp_Validation				AS V	ON	M.FdpVolumeHeaderId = V.FdpVolumeHeaderId
													AND M.MarketId			= V.MarketId
													AND V.IsActive			= 1
	WHERE
	M.PercentageTakeRate <> 1
	AND
	V.FdpValidationId IS NULL
	
	PRINT 'Total take rate for models cannot must equal 100% validation failures added: ' + CAST(@@ROWCOUNT AS NVARCHAR(10))