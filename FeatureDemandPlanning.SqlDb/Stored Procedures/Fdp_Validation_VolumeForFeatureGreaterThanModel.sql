CREATE PROCEDURE [dbo].[Fdp_Validation_VolumeForFeatureGreaterThanModel]
	  @FdpVolumeHeaderId	INT
	, @MarketId				INT			 = NULL
	, @CDSId				NVARCHAR(16) = NULL
AS

	SET NOCOUNT ON;
	
	INSERT INTO Fdp_Validation
	(
		  FdpVolumeHeaderId
		, MarketId
		, FdpValidationRuleId
		, [Message]
		, ModelId
		, FdpModelId
		, FeatureId
		, FdpFeatureId
		, FdpVolumeDataItemId
		, FdpChangesetDataItemId
	)
	-- Regular OXO models and features
	SELECT
		  H.FdpVolumeHeaderId
		, S.MarketId
		, 2 -- VolumeForFeatureGreaterThanModel
		, 'Volume for feature ''' + ISNULL(F.BrandDescription, F.[Description]) + ''' cannot exceed the volume for the model'
		, S.ModelId
		, S.FdpModelId
		, F.FeatureId
		, F.FdpFeatureId
		, D.FdpVolumeDataItemId
		, C.FdpChangesetDataItemId
	FROM
	Fdp_VolumeHeader_VW					AS H
	JOIN Fdp_FeatureMapping_VW			AS F	ON	H.ProgrammeId			= F.ProgrammeId
												AND H.Gateway				= F.Gateway
	JOIN Fdp_TakeRateSummary			AS S	ON	H.FdpVolumeHeaderId		= S.FdpVolumeHeaderId
	LEFT JOIN Fdp_VolumeDataItem_VW		AS D	ON	H.FdpVolumeHeaderId		= D.FdpVolumeHeaderId
												AND S.MarketId				= D.MarketId
												AND	S.ModelId				= D.ModelId
	-- Examine any uncommitted changes at feature level for the model
	LEFT JOIN Fdp_ChangesetDataItem_VW	AS C	ON	H.FdpVolumeHeaderId		= C.FdpVolumeHeaderId
												AND S.MarketId				= C.MarketId
												AND S.ModelId				= C.ModelId
												AND F.FeatureId				= C.FeatureId
												AND C.IsFeatureUpdate		= 1
												AND C.CDSId					= @CDSId
	-- Examine any uncommitted changes at model level
	LEFT JOIN Fdp_ChangesetDataItem_VW	AS C1	ON	S.FdpTakeRateSummaryId	= C1.FdpTakeRateSummaryId
												AND S.ModelId				= C1.ModelId
												AND S.MarketId				= C1.MarketId
												AND C1.IsModelUpdate		= 1
												AND C1.CDSId				= @CDSId
	LEFT JOIN Fdp_Validation			AS V	ON	H.FdpVolumeHeaderId		= V.FdpVolumeHeaderId
												AND S.MarketId				= V.MarketId
												AND S.ModelId				= V.ModelId
												AND F.FeatureId				= V.FeatureId
												AND V.IsActive				= 1
	WHERE
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(@MarketId IS NULL OR S.MarketId = @MarketId)
	AND
	S.ModelId IS NOT NULL
	AND
	F.FeatureId IS NOT NULL
	AND
	ISNULL(C.TotalVolume, ISNULL(D.Volume, 0)) > ISNULL(C1.TotalVolume, S.Volume)
	AND
	V.FdpValidationId IS NULL
	
	UNION
	
	-- OXO Models with FDP features
	SELECT
		  H.FdpVolumeHeaderId
		, S.MarketId
		, 2 -- VolumeForFeatureGreaterThanModel
		, 'Volume for feature ''' + ISNULL(F.BrandDescription, F.[Description]) + ''' cannot exceed the volume for the model'
		, S.ModelId
		, S.FdpModelId
		, F.FeatureId
		, F.FdpFeatureId
		, D.FdpVolumeDataItemId
		, C.FdpChangesetDataItemId
	FROM
	Fdp_VolumeHeader_VW					AS H
	JOIN Fdp_FeatureMapping_VW			AS F	ON	H.ProgrammeId			= F.ProgrammeId
												AND H.Gateway				= F.Gateway
	JOIN Fdp_TakeRateSummary			AS S	ON	H.FdpVolumeHeaderId		= S.FdpVolumeHeaderId
	LEFT JOIN Fdp_VolumeDataItem_VW		AS D	ON	H.FdpVolumeHeaderId		= D.FdpVolumeHeaderId
												AND S.MarketId				= D.MarketId
												AND	S.ModelId				= D.ModelId
	-- Examine any uncommitted changes at feature level for the model
	LEFT JOIN Fdp_ChangesetDataItem_VW	AS C	ON	H.FdpVolumeHeaderId		= C.FdpVolumeHeaderId
												AND S.MarketId				= C.MarketId
												AND S.ModelId				= C.ModelId
												AND F.FdpFeatureId			= C.FdpFeatureId
												AND C.IsFeatureUpdate		= 1
												AND C.CDSId					= @CDSId
	-- Examine any uncommitted changes at model level
	LEFT JOIN Fdp_ChangesetDataItem_VW	AS C1	ON	S.FdpTakeRateSummaryId	= C1.FdpTakeRateSummaryId
												AND S.ModelId				= C1.ModelId
												AND S.MarketId				= C1.MarketId
												AND C1.IsModelUpdate		= 1
												AND C1.CDSId				= @CDSId
	LEFT JOIN Fdp_Validation			AS V	ON	H.FdpVolumeHeaderId		= V.FdpVolumeHeaderId
												AND S.MarketId				= V.MarketId
												AND S.ModelId				= V.ModelId
												AND F.FdpFeatureId			= V.FdpFeatureId
												AND V.IsActive				= 1
	WHERE
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(@MarketId IS NULL OR S.MarketId = @MarketId)
	AND
	S.ModelId IS NOT NULL
	AND
	F.FdpFeatureId IS NOT NULL
	AND
	ISNULL(C.TotalVolume, ISNULL(D.Volume, 0)) > ISNULL(C1.TotalVolume, S.Volume)
	AND
	V.FdpValidationId IS NULL
	
	UNION
	
	-- Fdp Models with OXO features
	SELECT
		  H.FdpVolumeHeaderId
		, S.MarketId
		, 2 -- VolumeForFeatureGreaterThanModel
		, 'Volume for feature ''' + ISNULL(F.BrandDescription, F.[Description]) + ''' cannot exceed the volume for the model'
		, S.ModelId
		, S.FdpModelId
		, F.FeatureId
		, F.FdpFeatureId
		, D.FdpVolumeDataItemId
		, C.FdpChangesetDataItemId
	FROM
	Fdp_VolumeHeader_VW					AS H
	JOIN Fdp_FeatureMapping_VW			AS F	ON	H.ProgrammeId			= F.ProgrammeId
												AND H.Gateway				= F.Gateway
	JOIN Fdp_TakeRateSummary			AS S	ON	H.FdpVolumeHeaderId		= S.FdpVolumeHeaderId
	LEFT JOIN Fdp_VolumeDataItem_VW		AS D	ON	H.FdpVolumeHeaderId		= D.FdpVolumeHeaderId
												AND S.MarketId				= D.MarketId
												AND	S.FdpModelId			= D.FdpModelId
	-- Examine any uncommitted changes at feature level for the model
	LEFT JOIN Fdp_ChangesetDataItem_VW	AS C	ON	H.FdpVolumeHeaderId		= C.FdpVolumeHeaderId
												AND S.MarketId				= C.MarketId
												AND S.FdpModelId			= C.FdpModelId
												AND F.FeatureId				= C.FeatureId
												AND C.IsFeatureUpdate		= 1
												AND C.CDSId					= @CDSId
	-- Examine any uncommitted changes at model level
	LEFT JOIN Fdp_ChangesetDataItem_VW	AS C1	ON	S.FdpTakeRateSummaryId	= C1.FdpTakeRateSummaryId
												AND S.FdpModelId			= C1.FdpModelId
												AND S.MarketId				= C1.MarketId
												AND C1.IsModelUpdate		= 1
												AND C1.CDSId				= @CDSId
	LEFT JOIN Fdp_Validation			AS V	ON	H.FdpVolumeHeaderId		= V.FdpVolumeHeaderId
												AND S.MarketId				= V.MarketId
												AND S.FdpModelId			= V.FdpModelId
												AND F.FeatureId				= V.FeatureId
												AND V.IsActive				= 1
	WHERE
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(@MarketId IS NULL OR S.MarketId = @MarketId)
	AND
	S.FdpModelId IS NOT NULL
	AND
	F.FeatureId IS NOT NULL
	AND
	ISNULL(C.TotalVolume, ISNULL(D.Volume, 0)) > ISNULL(C1.TotalVolume, S.Volume)
	AND
	V.FdpValidationId IS NULL
	
	UNION
	
	-- FDP models with FDP features
	SELECT
		  H.FdpVolumeHeaderId
		, S.MarketId
		, 2 -- VolumeForFeatureGreaterThanModel
		, 'Volume for feature ''' + ISNULL(F.BrandDescription, F.[Description]) + ''' cannot exceed the volume for the model'
		, S.ModelId
		, S.FdpModelId
		, F.FeatureId
		, F.FdpFeatureId
		, D.FdpVolumeDataItemId
		, C.FdpChangesetDataItemId
	FROM
	Fdp_VolumeHeader_VW					AS H
	JOIN Fdp_FeatureMapping_VW			AS F	ON	H.ProgrammeId			= F.ProgrammeId
												AND H.Gateway				= F.Gateway
	JOIN Fdp_TakeRateSummary			AS S	ON	H.FdpVolumeHeaderId		= S.FdpVolumeHeaderId
	LEFT JOIN Fdp_VolumeDataItem_VW		AS D	ON	H.FdpVolumeHeaderId		= D.FdpVolumeHeaderId
												AND S.MarketId				= D.MarketId
												AND	S.FdpModelId			= D.FdpModelId
	-- Examine any uncommitted changes at feature level for the model
	LEFT JOIN Fdp_ChangesetDataItem_VW	AS C	ON	H.FdpVolumeHeaderId		= C.FdpVolumeHeaderId
												AND S.MarketId				= C.MarketId
												AND S.FdpModelId			= C.FdpModelId
												AND F.FdpFeatureId			= C.FdpFeatureId
												AND C.IsFeatureUpdate		= 1
												AND C.CDSId					= @CDSId
	-- Examine any uncommitted changes at model level
	LEFT JOIN Fdp_ChangesetDataItem_VW	AS C1	ON	S.FdpTakeRateSummaryId	= C1.FdpTakeRateSummaryId
												AND S.FdpModelId			= C1.FdpModelId
												AND S.MarketId				= C1.MarketId
												AND C1.IsModelUpdate		= 1
												AND C1.CDSId				= @CDSId
	LEFT JOIN Fdp_Validation			AS V	ON	H.FdpVolumeHeaderId		= V.FdpVolumeHeaderId
												AND S.MarketId				= V.MarketId
												AND S.FdpModelId			= V.FdpModelId
												AND F.FdpFeatureId			= V.FdpFeatureId
												AND V.IsActive				= 1
	WHERE
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(@MarketId IS NULL OR S.MarketId = @MarketId)
	AND
	S.FdpModelId IS NOT NULL
	AND
	F.FdpFeatureId IS NOT NULL
	AND
	ISNULL(C.TotalVolume, ISNULL(D.Volume, 0)) > ISNULL(C1.TotalVolume, S.Volume)
	AND
	V.FdpValidationId IS NULL
	
	PRINT 'Volume for feature exceeding volume for model validation failures added: ' + CAST(@@ROWCOUNT AS NVARCHAR(10))