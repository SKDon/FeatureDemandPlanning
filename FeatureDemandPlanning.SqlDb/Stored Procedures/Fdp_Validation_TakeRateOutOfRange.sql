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
	-- OXO Models and features
	SELECT 
		  H.FdpVolumeHeaderId
		, S.MarketId
		, S.ModelId
		, S.FdpModelId
		, F.FeatureId
		, F.FdpFeatureId
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
	JOIN Fdp_TakeRateSummary						AS S	ON	H.FdpVolumeHeaderId		= S.FdpVolumeHeaderId
															AND S.ModelId				IS NOT NULL										
	JOIN Fdp_FeatureMapping_VW						AS F	ON	H.ProgrammeId			= F.ProgrammeId
															AND H.Gateway				= F.Gateway
	LEFT JOIN Fdp_VolumeDataItem_VW					AS D	ON	H.FdpVolumeHeaderId		= D.FdpVolumeHeaderId
															AND S.MarketId				= D.MarketId
															AND S.ModelId				= D.ModelId
															AND F.FeatureId				= D.FeatureId
	LEFT JOIN Fdp_ChangesetDataItem_VW				AS C	ON	H.FdpVolumeHeaderId		= C.FdpVolumeHeaderId
															AND S.MarketId				= C.MarketId
															AND S.ModelId				= C.ModelId
															AND F.FeatureId				= C.FeatureId
															AND C.CDSId					= @CDSId
	LEFT JOIN Fdp_Validation						AS V	ON	H.FdpVolumeHeaderId		= V.FdpVolumeHeaderId
															AND S.MarketId				= V.MarketId
															AND S.ModelId				= V.ModelId
															AND F.FeatureId				= V.FeatureId	
															AND V.IsActive				= 1
	WHERE
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(@MarketId IS NULL OR S.MarketId = @MarketId)
	AND
	(
		ISNULL(C.PercentageTakeRate, ISNULL(D.PercentageTakeRate, 0)) < 0
		OR
		ISNULL(C.PercentageTakeRate, ISNULL(D.PercentageTakeRate, 0)) > 1
	)
	AND
	V.FeatureId IS NULL

	UNION

	-- OXO Models and FDP features
	SELECT 
		  H.FdpVolumeHeaderId
		, S.MarketId
		, S.ModelId
		, S.FdpModelId
		, F.FeatureId
		, F.FdpFeatureId
		, 1 -- Take rates should be in the range 0-100%
		, CASE 
			WHEN ISNULL(C.PercentageTakeRate, ISNULL(D.PercentageTakeRate, 0)) < 0 THEN 'Take rate below 0% for feature ''' + ISNULL(F.BrandDescription, F.[Description]) + ''' is not allowed' 
			ELSE 'Take rate above 100% for feature ''' + ISNULL(F.BrandDescription, F.[Description]) + ''' is not allowed' END
		, D.FdpVolumeDataItemId
		, NULL
		, NULL
		, C.FdpChangesetDataItemId
	FROM 
	Fdp_VolumeHeader_VW								AS H
	JOIN Fdp_TakeRateSummary						AS S	ON	H.FdpVolumeHeaderId		= S.FdpVolumeHeaderId
															AND S.ModelId				IS NOT NULL										
	JOIN Fdp_FeatureMapping_VW						AS F	ON	H.ProgrammeId			= F.ProgrammeId
															AND H.Gateway				= F.Gateway
	LEFT JOIN Fdp_VolumeDataItem_VW					AS D	ON	H.FdpVolumeHeaderId		= D.FdpVolumeHeaderId
															AND S.MarketId				= D.MarketId
															AND S.ModelId				= D.ModelId
															AND F.FdpFeatureId			= D.FdpFeatureId
	LEFT JOIN Fdp_ChangesetDataItem_VW				AS C	ON	H.FdpVolumeHeaderId		= C.FdpVolumeHeaderId
															AND S.MarketId				= C.MarketId
															AND S.ModelId				= C.ModelId
															AND F.FdpFeatureId			= C.FdpFeatureId
															AND C.CDSId					= @CDSId
	LEFT JOIN Fdp_Validation						AS V	ON	H.FdpVolumeHeaderId		= V.FdpVolumeHeaderId
															AND S.MarketId				= V.MarketId
															AND S.ModelId				= V.ModelId
															AND F.FdpFeatureId			= V.FdpFeatureId
															AND V.IsActive				= 1
															
															
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
	V.FdpFeatureId IS NULL

	UNION

	-- FDP Models and OXO features
	SELECT 
		  H.FdpVolumeHeaderId
		, S.MarketId
		, S.ModelId
		, S.FdpModelId
		, F.FeatureId
		, F.FdpFeatureId
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
	JOIN Fdp_TakeRateSummary						AS S	ON	H.FdpVolumeHeaderId		= S.FdpVolumeHeaderId
															AND S.FdpModelId			IS NOT NULL										
	JOIN Fdp_FeatureMapping_VW						AS F	ON	H.ProgrammeId			= F.ProgrammeId
															AND H.Gateway				= F.Gateway
	LEFT JOIN Fdp_VolumeDataItem_VW					AS D	ON	H.FdpVolumeHeaderId		= D.FdpVolumeHeaderId
															AND S.MarketId				= D.MarketId
															AND S.FdpModelId			= D.FdpModelId
															AND F.FeatureId				= D.FeatureId
	LEFT JOIN Fdp_ChangesetDataItem_VW				AS C	ON	H.FdpVolumeHeaderId		= C.FdpVolumeHeaderId
															AND S.MarketId				= C.MarketId
															AND S.FdpModelId			= C.FdpModelId
															AND F.FeatureId				= C.FeatureId
															AND C.CDSId					= @CDSId
	LEFT JOIN Fdp_Validation						AS V	ON	H.FdpVolumeHeaderId		= V.FdpVolumeHeaderId
															AND S.MarketId				= V.MarketId
															AND F.FeatureId				= V.FeatureId	
															AND S.FdpModelId			= V.FdpModelId
															AND V.IsActive				= 1
															
	WHERE
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(@MarketId IS NULL OR S.MarketId = @MarketId)
	AND
	(
		ISNULL(C.PercentageTakeRate, ISNULL(D.PercentageTakeRate, 0)) < 0
		OR
		ISNULL(C.PercentageTakeRate, ISNULL(D.PercentageTakeRate, 0)) > 1
	)
	AND
	V.FeatureId IS NULL

	UNION

	-- FDP Models and features
	SELECT 
		  H.FdpVolumeHeaderId
		, S.MarketId
		, S.ModelId
		, S.FdpModelId
		, F.FeatureId
		, F.FdpFeatureId
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
	JOIN Fdp_TakeRateSummary						AS S	ON	H.FdpVolumeHeaderId		= S.FdpVolumeHeaderId
															AND S.FdpModelId			IS NOT NULL										
	JOIN Fdp_FeatureMapping_VW						AS F	ON	H.ProgrammeId			= F.ProgrammeId
															AND H.Gateway				= F.Gateway
	LEFT JOIN Fdp_VolumeDataItem_VW					AS D	ON	H.FdpVolumeHeaderId		= D.FdpVolumeHeaderId
															AND S.MarketId				= D.MarketId
															AND S.FdpModelId			= D.FdpModelId
															AND F.FdpFeatureId			= D.FdpFeatureId
	LEFT JOIN Fdp_ChangesetDataItem_VW				AS C	ON	H.FdpVolumeHeaderId		= C.FdpVolumeHeaderId
															AND S.MarketId				= C.MarketId
															AND S.FdpModelId			= C.FdpModelId
															AND F.FdpFeatureId			= C.FdpFeatureId
															AND C.CDSId					= @CDSId
	LEFT JOIN Fdp_Validation						AS V	ON	H.FdpVolumeHeaderId		= V.FdpVolumeHeaderId
															AND S.MarketId				= V.MarketId
															AND F.FdpFeatureId			= V.FdpFeatureId	
															AND S.FdpModelId			= V.FdpModelId
															AND V.IsActive				= 1
															
	WHERE
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(@MarketId IS NULL OR S.MarketId = @MarketId)
	AND
	(
		ISNULL(C.PercentageTakeRate, ISNULL(D.PercentageTakeRate, 0)) < 0
		OR
		ISNULL(C.PercentageTakeRate, ISNULL(D.PercentageTakeRate, 0)) > 1
	)
	AND
	V.FdpFeatureId IS NULL

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