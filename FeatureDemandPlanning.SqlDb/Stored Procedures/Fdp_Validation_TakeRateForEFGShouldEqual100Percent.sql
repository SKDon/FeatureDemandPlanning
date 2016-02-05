CREATE PROCEDURE [dbo].[Fdp_Validation_TakeRateForEFGShouldEqual100Percent]
	  @FdpVolumeHeaderId	INT
	, @MarketId				INT			 = NULL
	, @CDSId				NVARCHAR(16) = NULL
AS

	SET NOCOUNT ON;

	WITH EfgTakeRates AS
	(
		-- Exclusive feature groups containing a standard feature plus options
		SELECT 
			  H.FdpVolumeHeaderId
			, S.MarketId
			, S.ModelId
			, S.FdpTakeRateSummaryId
			, F.EFGName
			, MAX(FA.FeaturesInExclusiveFeatureGroup) AS NumberOfFeaturesInGroup
			, CAST(CASE WHEN SUM(CAST(FA.IsStandardFeatureInGroup AS INT)) > 0 THEN 1 ELSE 0 END AS BIT) AS GroupHasStandardFeature
			, SUM(ISNULL(C.PercentageTakeRate, ISNULL(D.PercentageTakeRate, 0))) AS PercentageTakeRate
		FROM 
		Fdp_VolumeHeader_VW								AS H
		JOIN Fdp_TakeRateSummaryByModelAndMarket_VW		AS S	ON	H.FdpVolumeHeaderId		= S.FdpVolumeHeaderId
		CROSS APPLY dbo.fn_Fdp_FeatureApplicability_GetMany(H.FdpVolumeHeaderId, S.MarketId) AS FA
		JOIN OXO_Programme_Feature_VW					AS F	ON	FA.FeatureId			= F.ID
																AND H.ProgrammeId			= F.ProgrammeId
		LEFT JOIN Fdp_VolumeDataItem_VW					AS D	ON	H.FdpVolumeHeaderId		= D.FdpVolumeHeaderId
																AND S.MarketId				= D.MarketId
																AND S.ModelId				= D.ModelId
																AND F.ID					= D.FeatureId
		LEFT JOIN Fdp_ChangesetDataItem_VW				AS C	ON	S.MarketId				= C.MarketId
																AND F.Id					= C.FeatureId
																AND S.ModelId				= C.ModelId
																AND C.CDSId					= @CDSId
		WHERE
		(@MarketId IS NULL OR S.MarketId = @MarketId)
		AND
		S.MarketId = FA.MarketId
		AND
		S.ModelId = FA.ModelId
		AND
		-- We are only interested in groups with more than one feature
		-- as the aggregate needs to be 100% if containing a standard feature
		FA.FeaturesInExclusiveFeatureGroup > 1
		AND
		FA.OxoCode NOT LIKE '%NA%'
		GROUP BY
		  H.FdpVolumeHeaderId
		, S.MarketId
		, S.ModelId
		, S.FdpTakeRateSummaryId
		, F.EFGName
	)
	INSERT INTO Fdp_Validation
	(
		  FdpVolumeHeaderId
		, MarketId
		, ModelId
		, FdpValidationRuleId
		, [Message]
		, FdpTakeRateSummaryId
	)
	SELECT
		  T.FdpVolumeHeaderId
		, T.MarketId
		, T.ModelId
		, 7 -- All features in a group must add up to 100% (or less if group is entirely optional)
		, 'Take rate of ''' + CAST(CAST(T.PercentageTakeRate AS DECIMAL(5,2)) * 100 AS NVARCHAR(10)) + '%'' for all features in exclusive feature group ''' + T.EFGName + ''' must equal 100% as group contains a standard feature'
		, T.FdpTakeRateSummaryId
	FROM
	EfgTakeRates				AS T
	LEFT JOIN Fdp_Validation	AS V	ON	T.FdpVolumeHeaderId		= V.FdpVolumeHeaderId
										AND T.MarketId				= V.MarketId
										AND T.FdpTakeRateSummaryId	= V.FdpTakeRateSummaryId
										AND V.IsActive				= 1
	WHERE
	T.GroupHasStandardFeature = 1
	AND
	T.PercentageTakeRate <> 1
	AND
	V.FdpTakeRateSummaryId IS NULL

	UNION

	SELECT
		  T.FdpVolumeHeaderId
		, T.MarketId
		, T.ModelId
		, 7 -- All features in a group must add up to 100% (or less if group is entirely optional)
		, 'Take rate of ''' + CAST(CAST(T.PercentageTakeRate AS DECIMAL(5,2)) * 100 AS NVARCHAR(10)) + '%'' for all features in exclusive feature group ''' + T.EFGName + ''' cannot be greater than 100%'
		, T.FdpTakeRateSummaryId
	FROM
	EfgTakeRates				AS T
	LEFT JOIN Fdp_Validation	AS V	ON	T.FdpVolumeHeaderId		= V.FdpVolumeHeaderId
										AND T.MarketId				= V.MarketId
										AND T.FdpTakeRateSummaryId	= V.FdpTakeRateSummaryId
										AND V.IsActive				= 1
	WHERE
	T.GroupHasStandardFeature = 0
	AND
	T.PercentageTakeRate > 1
	AND
	V.FdpTakeRateSummaryId IS NULL

	PRINT 'Exclusive feature group validation failures added: ' + CAST(@@ROWCOUNT AS NVARCHAR(10))