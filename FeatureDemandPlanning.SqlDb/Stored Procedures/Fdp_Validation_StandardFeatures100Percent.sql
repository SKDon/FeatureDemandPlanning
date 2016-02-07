CREATE PROCEDURE [dbo].[Fdp_Validation_StandardFeatures100Percent]
	  @FdpVolumeHeaderId	INT
	, @MarketId				INT			 = NULL
	, @CDSId				NVARCHAR(16) = NULL
AS

	SET NOCOUNT ON;

	INSERT INTO Fdp_Validation
	(
		  FdpVolumeHeaderId
		, MarketId
		, ModelId
		, FeatureId
		, FdpValidationRuleId
		, [Message]
		, FdpVolumeDataItemId
		, FdpTakeRateSummaryId
		, FdpChangesetDataItemId
	)
	SELECT 
		  H.FdpVolumeHeaderId
		, S.MarketId
		, S.ModelId
		, F.ID
		, 5 -- Standard feature 100%
		, 'Take rate of ''' + CAST(CAST(ISNULL(C.PercentageTakeRate, ISNULL(D.PercentageTakeRate, 0)) AS DECIMAL(5,2)) * 100 AS NVARCHAR(10)) + '%'' for standard feature ''' + ISNULL(F.BrandDescription, F.[SystemDescription]) + ''' should be 100%'
		, D.FdpVolumeDataItemId
		, NULL -- This is feature level validation as this is an isolated feature. Don't add the model summary identifier as this will make it a model level validation
		, C.FdpChangesetDataItemId
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
	LEFT JOIN Fdp_Validation						AS V	ON	H.FdpVolumeHeaderId		= V.FdpVolumeHeaderId
															AND S.MarketId				= V.MarketId
															AND S.ModelId				= V.ModelId
															AND F.ID					= V.FeatureId
															AND V.IsActive				= 1
	WHERE
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(@MarketId IS NULL OR S.MarketId = @MarketId)
	AND
	S.ModelId = FA.ModelId
	AND 
	FA.IsStandardFeatureInGroup = 1 -- Must be a standard feature
	AND 
	FA.ApplicableFeaturesInExclusiveFeatureGroup = 1 -- To be 100% take, the standard feature must be the only (applicable) feature in group
	AND
	ISNULL(C.PercentageTakeRate, ISNULL(D.PercentageTakeRate, 0)) <> 1 -- 100 %
	AND
	V.FeatureId IS NULL

	PRINT 'Standard feature validation failures added: ' + CAST(@@ROWCOUNT AS NVARCHAR(10))