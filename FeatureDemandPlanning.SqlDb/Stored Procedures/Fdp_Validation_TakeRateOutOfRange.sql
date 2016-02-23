CREATE PROCEDURE [dbo].[Fdp_Validation_TakeRateOutOfRange]
	  @FdpVolumeHeaderId	INT
	, @MarketId				INT			 = NULL
	, @CDSId				NVARCHAR(16) = NULL
AS

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	INSERT INTO Fdp_Validation
	(
		  FdpVolumeHeaderId
		, MarketId
		, ModelId
		, FdpModelId
		, FeatureId
		, FdpFeatureId
		, FdpValidationRuleId
		, [Message]
		, FdpVolumeDataItemId
		, FdpTakeRateSummaryId
		, FdpTakeRateFeatureMixId
		, FdpChangesetDataItemId
	)
	SELECT 
		  H.FdpVolumeHeaderId
		, D.MarketId
		, D.ModelId
		, D.FdpModelId
		, D.FeatureId
		, D.FdpFeatureId
		, 1 -- Take rates should be in the range 0-100%
		, CASE WHEN ISNULL(C.PercentageTakeRate, ISNULL(D.PercentageTakeRate, 0)) < 0 
			THEN 'Take rate below 0% for feature ''' + ISNULL(F.BrandDescription, F.[Description]) + ''' is not allowed' 
			ELSE 'Take rate above 100% for feature ''' + ISNULL(F.BrandDescription, F.[Description]) + ''' is not allowed' END
		, D.FdpVolumeDataItemId
		, NULL
		, NULL
		, C.FdpChangesetDataItemId
	FROM 
	Fdp_VolumeHeader_VW								AS H
	JOIN Fdp_VolumeDataItem_VW						AS D	ON	H.FdpVolumeHeaderId		= D.FdpVolumeHeaderId									
	JOIN Fdp_FeatureMapping_VW						AS F	ON	H.ProgrammeId			= F.ProgrammeId
															AND H.Gateway				= F.Gateway
	LEFT JOIN Fdp_ChangesetDataItem_VW				AS C	ON	H.FdpVolumeHeaderId		= C.FdpVolumeHeaderId
															AND D.FdpVolumeDataItemId	= C.FdpVolumeDataItemId
															AND C.CDSId					= @CDSId
	LEFT JOIN Fdp_Validation_VW						AS V	ON	H.FdpVolumeHeaderId		= V.FdpVolumeHeaderId
															AND D.FdpVolumeDataItemId	= V.FdpVolumeDataItemId
	WHERE
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(@MarketId IS NULL OR D.MarketId = @MarketId)
	AND
	(
		ISNULL(C.PercentageTakeRate, ISNULL(D.PercentageTakeRate, 0)) < 0
		OR
		ISNULL(C.PercentageTakeRate, ISNULL(D.PercentageTakeRate, 0)) > 1
	)
	AND
	V.FeatureId IS NULL

	UNION

	-- Model summary
	SELECT 
		  S.FdpVolumeHeaderId
		, S.MarketId
		, S.ModelId
		, S.FdpModelId
		, NULL
		, NULL
		, 1 -- Take rates should be in the range 0-100%
		, CASE 
			WHEN ISNULL(C.PercentageTakeRate, ISNULL(S.PercentageTakeRate, 0)) < 0 THEN 'Take rate below 0% for model is not allowed' 
			ELSE 'Take rate above 100% for model is not allowed' 
		  END
		, NULL
		, S.FdpTakeRateSummaryId
		, NULL
		, C.FdpChangesetDataItemId
	FROM 
	Fdp_TakeRateSummary					AS S
	LEFT JOIN Fdp_ChangesetDataItem_VW	AS C	ON	S.FdpVolumeHeaderId		= C.FdpVolumeHeaderId
												AND S.FdpTakeRateSummaryId	= C.FdpTakeRateSummaryId
												AND C.CDSId					= @CDSId
	LEFT JOIN Fdp_Validation			AS V	ON	S.FdpVolumeHeaderId		= V.FdpVolumeHeaderId
												AND S.FdpTakeRateSummaryId	= V.FdpTakeRateSummaryId
												AND 
												(
													C.FdpChangesetDataItemId IS NULL
													OR
													C.FdpChangesetDataItemId = V.FdpChangesetDataItemId
												)
												AND V.IsActive				= 1					
	WHERE
	S.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(@MarketId IS NULL OR S.MarketId = @MarketId)
	AND
	(
		ISNULL(C.PercentageTakeRate, S.PercentageTakeRate) < 0
		OR
		ISNULL(C.PercentageTakeRate, S.PercentageTakeRate) > 1
	)
	AND
	V.FdpValidationId IS NULL

	UNION

	-- Feature mix

	SELECT 
		  F.FdpVolumeHeaderId
		, F.MarketId
		, NULL
		, NULL
		, F.FeatureId
		, F.FdpFeatureId
		, 1 -- Take rates should be in the range 0-100%
		, CASE 
			WHEN ISNULL(C.PercentageTakeRate, ISNULL(F.PercentageTakeRate, 0)) < 0 THEN 'Take rate below 0% for feature mix is not allowed' 
			ELSE 'Take rate above 100% for feature mix is not allowed' 
		  END
		, NULL
		, NULL
		, F.FdpTakeRateFeatureMixId
		, C.FdpChangesetDataItemId
	FROM 
	Fdp_TakeRateFeatureMix				AS F	
	LEFT JOIN Fdp_ChangesetDataItem_VW	AS C	ON	F.FdpVolumeHeaderId			= C.FdpVolumeHeaderId
												AND F.FdpTakeRateFeatureMixId	= C.FdpTakeRateFeatureMixId
												AND C.CDSId						= @CDSId
	LEFT JOIN Fdp_Validation			AS V	ON	F.FdpVolumeHeaderId			= V.FdpVolumeHeaderId
												AND F.MarketId					= V.MarketId
												AND F.FdpTakeRateFeatureMixId	= V.FdpTakeRateFeatureMixId
												AND 
												(
													C.FdpChangesetDataItemId IS NULL
													OR
													C.FdpChangesetDataItemId = V.FdpChangesetDataItemId
												)
												AND V.IsActive				= 1					
	WHERE
	F.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(@MarketId IS NULL OR F.MarketId = @MarketId)
	AND
	(
		ISNULL(C.PercentageTakeRate, ISNULL(F.PercentageTakeRate, 0)) < 0
		OR
		ISNULL(C.PercentageTakeRate, ISNULL(F.PercentageTakeRate, 0)) > 1
	)
	AND
	V.FdpValidationId IS NULL

	PRINT 'Out of range failures added: ' + CAST(@@ROWCOUNT AS NVARCHAR(10))