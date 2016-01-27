﻿CREATE PROCEDURE [dbo].[Fdp_Validation_VolumeForFeatureGreaterThanModel]
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
		, FdpVolumeDataItemId
	)
	-- Regular OXO models and features
	SELECT
		  D.FdpVolumeHeaderId
		, D.MarketId
		, 2 -- VolumeForFeatureGreaterThanModel
		, 'Volume for feature cannot exceed the volume for the model'
		, D.FdpVolumeDataItemId
	FROM
	Fdp_VolumeDataItem_VW				AS D
	JOIN Fdp_TakeRateSummary			AS S	ON	D.ModelId				= S.ModelId
												AND D.MarketId				= S.MarketId
												AND D.FdpVolumeHeaderId		= S.FdpVolumeHeaderId
	-- Examine any uncommitted changes at feature level
	LEFT JOIN Fdp_ChangesetDataItem_VW	AS C	ON	D.FdpVolumeHeaderId		= C.FdpVolumeHeaderId
												AND D.FeatureId				= C.FeatureId
												AND D.MarketId				= C.MarketId
												AND C.IsFeatureUpdate		= 1
												AND C.IsDeleted				= 0
												AND C.IsSaved				= 0
												AND C.CDSId					= @CDSId
	-- Examine any uncommitted changes at model level
	LEFT JOIN Fdp_ChangesetDataItem_VW	AS C1	ON	S.FdpTakeRateSummaryId	= C1.FdpTakeRateSummaryId
												AND S.ModelId				= C1.ModelId
												AND D.MarketId				= C1.MarketId
												AND C1.IsModelUpdate		= 1
												AND C1.IsDeleted			= 0
												AND C1.IsSaved				= 0
												AND C1.CDSId				= @CDSId
	LEFT JOIN Fdp_Validation			AS V	ON	D.FdpVolumeDataItemId	= V.FdpVolumeDataItemId
												AND V.IsActive				= 1
	WHERE
	D.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(@MarketId IS NULL OR D.MarketId = @MarketId)
	AND
	ISNULL(C.TotalVolume, D.Volume) > ISNULL(C1.TotalVolume, S.Volume)
	
	UNION
	
	-- Fdp models with OXO features
	SELECT
		  D.FdpVolumeHeaderId
		, D.MarketId
		, 2 -- VolumeForFeatureGreaterThanModel
		, 'Volume for feature cannot exceed the volume for the model'
		, D.FdpVolumeDataItemId
	FROM
	Fdp_VolumeDataItem_VW				AS D
	JOIN Fdp_TakeRateSummary			AS S	ON	D.FdpModelId			= S.FdpModelId
												AND D.MarketId				= S.MarketId
												AND D.FdpVolumeHeaderId		= S.FdpVolumeHeaderId
	-- Examine any uncommitted changes at feature level
	LEFT JOIN Fdp_ChangesetDataItem_VW	AS C	ON	D.FdpVolumeHeaderId		= C.FdpVolumeHeaderId
												AND D.FeatureId				= C.FeatureId
												AND D.MarketId				= C.MarketId
												AND C.IsFeatureUpdate		= 1
												AND C.IsDeleted				= 0
												AND C.IsSaved				= 0
												AND C.CDSId					= @CDSId
	-- Examine any uncommitted changes at model level
	LEFT JOIN Fdp_ChangesetDataItem_VW	AS C1	ON	S.FdpTakeRateSummaryId	= C1.FdpTakeRateSummaryId
												AND S.FdpModelId			= C1.FdpModelId
												AND D.MarketId				= C1.MarketId
												AND C1.IsModelUpdate		= 1
												AND C1.IsDeleted			= 0
												AND C1.IsSaved				= 0
												AND C1.CDSId				= @CDSId
	LEFT JOIN Fdp_Validation			AS V	ON	D.FdpVolumeDataItemId	= V.FdpVolumeDataItemId
												AND V.IsActive				= 1
	WHERE
	D.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(@MarketId IS NULL OR D.MarketId = @MarketId)
	AND
	ISNULL(C.TotalVolume, D.Volume) > ISNULL(C1.TotalVolume, S.Volume)
	
	UNION
	
	-- OXO models with FDP features
	SELECT
		  D.FdpVolumeHeaderId
		, D.MarketId
		, 2 -- VolumeForFeatureGreaterThanModel
		, 'Volume for feature cannot exceed the volume for the model'
		, D.FdpVolumeDataItemId
	FROM
	Fdp_VolumeDataItem_VW				AS D
	JOIN Fdp_TakeRateSummary			AS S	ON	D.ModelId				= S.ModelId
												AND D.MarketId				= S.MarketId
												AND D.FdpVolumeHeaderId		= S.FdpVolumeHeaderId
	-- Examine any uncommitted changes at feature level
	LEFT JOIN Fdp_ChangesetDataItem_VW	AS C	ON	D.FdpVolumeHeaderId		= C.FdpVolumeHeaderId
												AND D.FdpFeatureId			= C.FdpFeatureId
												AND D.MarketId				= C.MarketId
												AND C.IsFeatureUpdate		= 1
												AND C.IsDeleted				= 0
												AND C.IsSaved				= 0
												AND C.CDSId					= @CDSId
	-- Examine any uncommitted changes at model level
	LEFT JOIN Fdp_ChangesetDataItem_VW	AS C1	ON	S.FdpTakeRateSummaryId	= C1.FdpTakeRateSummaryId
												AND S.ModelId				= C1.ModelId
												AND D.MarketId				= C1.MarketId
												AND C1.IsModelUpdate		= 1
												AND C1.IsDeleted			= 0
												AND C1.IsSaved				= 0
												AND C1.CDSId				= @CDSId
	LEFT JOIN Fdp_Validation			AS V	ON	D.FdpVolumeDataItemId	= V.FdpVolumeDataItemId
												AND V.IsActive				= 1
	WHERE
	D.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(@MarketId IS NULL OR D.MarketId = @MarketId)
	
	UNION
	
	-- FDP models with FDP features
	SELECT
		  D.FdpVolumeHeaderId
		, D.MarketId
		, 2 -- VolumeForFeatureGreaterThanModel
		, 'Volume for feature cannot exceed the volume for the model'
		, D.FdpVolumeDataItemId
	FROM
	Fdp_VolumeDataItem_VW				AS D
	JOIN Fdp_TakeRateSummary			AS S	ON	D.FdpModelId			= S.FdpModelId
												AND D.MarketId				= S.MarketId
												AND D.FdpVolumeHeaderId		= S.FdpVolumeHeaderId
	-- Examine any uncommitted changes at feature level
	LEFT JOIN Fdp_ChangesetDataItem_VW	AS C	ON	D.FdpVolumeHeaderId		= C.FdpVolumeHeaderId
												AND D.FdpFeatureId			= C.FdpFeatureId
												AND D.MarketId				= C.MarketId
												AND C.IsFeatureUpdate		= 1
												AND C.IsDeleted				= 0
												AND C.IsSaved				= 0
												AND C.CDSId					= @CDSId
	-- Examine any uncommitted changes at model level
	LEFT JOIN Fdp_ChangesetDataItem_VW	AS C1	ON	S.FdpTakeRateSummaryId	= C1.FdpTakeRateSummaryId
												AND S.FdpModelId			= C1.FdpModelId
												AND D.MarketId				= C1.MarketId
												AND C1.IsModelUpdate		= 1
												AND C1.IsDeleted			= 0
												AND C1.IsSaved				= 0
												AND C1.CDSId				= @CDSId
	LEFT JOIN Fdp_Validation			AS V	ON	D.FdpVolumeDataItemId	= V.FdpVolumeDataItemId
												AND V.IsActive				= 1
	WHERE
	D.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(@MarketId IS NULL OR D.MarketId = @MarketId)
	AND
	ISNULL(C.TotalVolume, D.Volume) > ISNULL(C1.TotalVolume, S.Volume)
	
	PRINT 'Volume for feature exceeding volume for model validation failures added: ' + CAST(@@ROWCOUNT AS NVARCHAR(10))