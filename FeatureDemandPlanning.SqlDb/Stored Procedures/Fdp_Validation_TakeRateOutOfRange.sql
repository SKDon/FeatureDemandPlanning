CREATE PROCEDURE dbo.Fdp_Validation_TakeRateOutOfRange
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
		, Message
		, FdpVolumeDataItemId
		, FdpTakeRateSummaryId
		, FdpTakeRateFeatureMixId
		, FdpChangesetDataItemId
	)
	SELECT 
		  D.FdpVolumeHeaderId
		, D.MarketId
		, 1 -- Take rates should be in the range 0-100%
		, CASE WHEN D.PercentageTakeRate < 0 THEN 'Take rate below 0% is not allowed' ELSE 'Take rate above 100% is not allowed' END
		, D.FdpVolumeDataItemId
		, NULL
		, NULL
		, C.FdpChangesetDataItemId
	FROM 
	Fdp_VolumeDataItem_VW				AS D
	LEFT JOIN Fdp_ChangesetDataItem_VW	AS C	ON	D.FdpVolumeDataItemId	= C.FdpVolumeDataItemId
	LEFT JOIN Fdp_Validation			AS V	ON	D.MarketId				= V.MarketId
												AND D.FdpVolumeDataItemId	= D.FdpVolumeDataItemId
												AND 
												(
													C.FdpChangesetDataItemId IS NULL
													OR
													C.FdpChangesetDataItemId = V.FdpChangesetDataItemId
												)
												AND V.IsActive				= 1					
	WHERE
	D.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(@MarketId IS NULL OR D.MarketId = @MarketId)
	AND
	(
		ISNULL(C.PercentageTakeRate, D.PercentageTakeRate) < 0
		OR
		ISNULL(C.PercentageTakeRate, D.PercentageTakeRate) > 1
	)
	AND
	V.FdpValidationId IS NULL

	UNION

	SELECT 
		  S.FdpVolumeHeaderId
		, S.MarketId
		, 1 -- Take rates should be in the range 0-100%
		, CASE WHEN S.PercentageTakeRate < 0 THEN 'Take rate below 0% for model is not allowed' ELSE 'Take rate above 100% for model is not allowed' END
		, NULL
		, S.FdpTakeRateSummaryId
		, NULL
		, C.FdpChangesetDataItemId
	FROM 
	Fdp_TakeRateSummary					AS S
	LEFT JOIN Fdp_ChangesetDataItem_VW	AS C	ON	S.FdpTakeRateSummaryId	= C.FdpTakeRateSummaryId
	LEFT JOIN Fdp_Validation			AS V	ON	S.MarketId				= V.MarketId
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

	SELECT 
		  F.FdpVolumeHeaderId
		, F.MarketId
		, 1 -- Take rates should be in the range 0-100%
		, CASE WHEN F.PercentageTakeRate < 0 THEN 'Take rate below 0% for model is not allowed' ELSE 'Take rate above 100% for model is not allowed' END
		, NULL
		, NULL
		, F.FdpTakeRateFeatureMixId
		, C.FdpChangesetDataItemId
	FROM 
	Fdp_TakeRateFeatureMix				AS F	
	LEFT JOIN Fdp_ChangesetDataItem_VW	AS C	ON	F.FdpTakeRateFeatureMixId	= C.FdpTakeRateFeatureMixId
	LEFT JOIN Fdp_Validation			AS V	ON	F.MarketId					= V.MarketId
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
		ISNULL(C.PercentageTakeRate, F.PercentageTakeRate) < 0
		OR
		ISNULL(C.PercentageTakeRate, F.PercentageTakeRate) > 1
	)
	AND
	V.FdpValidationId IS NULL

	PRINT 'Out of range failures added: ' + CAST(@@ROWCOUNT AS NVARCHAR(10))