
CREATE PROCEDURE [dbo].[Fdp_Changeset_Undo]
	@FdpChangesetId INT
AS
	SET NOCOUNT ON;

	DECLARE @FdpChangesetDataItemId			INT;
	DECLARE @PriorFdpChangesetDataItemId	INT;
	DECLARE @FdpVolumeDataItemId			INT;
	DECLARE @FdpTakeRateSummaryId			INT;
	DECLARE @FdpTakeRateFeatureMixId		INT;
	DECLARE @FdpPowertrainDataItemId		INT;
	DECLARE @FdpVolumeHeaderId				INT;
	DECLARE @MarketId						INT;
	DECLARE @CDSId							NVARCHAR(16);

	DECLARE @UndoneChanges AS TABLE
	(
		  FdpChangesetDataItemId		INT
		, CreatedOn						DATETIME
		, FdpChangesetId				INT
		, MarketId						INT
		, ModelIdentifier				NVARCHAR(10)
		, FeatureIdentifier				NVARCHAR(10)
		, DerivativeIdentifier			NVARCHAR(10)
		, TotalVolume					INT
		, PercentageTakeRate			DECIMAL(5,4)
		, IsVolumeUpdate				BIT
		, IsPercentageUpdate			BIT
		, OriginalVolume				INT NULL
		, OriginalPercentageTakeRate	DECIMAL(5,4) NULL
		, FdpVolumeDataItemId			INT NULL
		, FdpTakeRateSummaryId			INT	NULL
		, FdpTakeRateFeatureMixId		INT	NULL
		, FdpPowertrainDataItemId		INT NULL
		, ParentFdpChangesetDataItemId	INT NULL
		, IsMarketReview				BIT
		, FdpVolumeHeaderId				INT NULL
	)

	DECLARE @IsMarketReview AS BIT = 0;
	IF EXISTS(
		SELECT TOP 1 1
		FROM
		Fdp_Changeset					AS C
		JOIN Fdp_MarketReview_VW	AS M	ON	C.FdpVolumeHeaderId = M.FdpVolumeHeaderId
												AND M.FdpMarketReviewStatusId NOT IN (4, 5)
												AND C.MarketId = M.MarketId
												AND C.CreatedOn >= M.CreatedOn
		WHERE
		C.FdpChangesetId = @FdpChangesetId
	)
	BEGIN
		SET @IsMarketReview = 1
	END

	-- Get the most recent change for that changeset

	SELECT TOP 1 
		  @FdpChangesetDataItemId	= D.FdpChangesetDataItemId
	FROM
	Fdp_Changeset AS C
	JOIN Fdp_ChangesetDataItem AS D ON C.FdpChangesetId = D.FdpChangesetId
	WHERE
	C.FdpChangesetId = @FdpChangesetId
	AND
	D.ParentFdpChangesetDataItemId IS NULL
	ORDER BY
	D.FdpChangesetDataItemId DESC;

	-- Get the identifier of any changeset data prior to the most recent change
	-- It will be marked as deleted
	
	SELECT TOP 1 @PriorFdpChangesetDataItemId = D.FdpChangesetDataItemId
	FROM 
	Fdp_Changeset AS C
	JOIN Fdp_ChangesetDataItem AS D ON C.FdpChangesetId = D.FdpChangesetId
	WHERE
	D.ParentFdpChangesetDataItemId IS NULL
	AND
	D.FdpChangesetDataItemId < @FdpChangesetDataItemId
	AND
	C.FdpChangesetId = @FdpChangesetId
	ORDER BY
	D.FdpChangesetDataItemId DESC;

	-- Add the rows that are going to be removed to the undone changes dataset, as we need to process further after deletion

	INSERT INTO @UndoneChanges
	(
		  FdpChangesetDataItemId		
		, CreatedOn						
		, FdpChangesetId				
		, MarketId						
		, ModelIdentifier									
		, FeatureIdentifier
		, DerivativeIdentifier									
		, TotalVolume					
		, PercentageTakeRate							
		, IsVolumeUpdate				
		, IsPercentageUpdate			
		, OriginalVolume				
		, OriginalPercentageTakeRate	
		, FdpVolumeDataItemId			
		, FdpTakeRateSummaryId
		, FdpTakeRateFeatureMixId
		, FdpPowertrainDataItemId			
		, ParentFdpChangesetDataItemId
		, IsMarketReview
		, FdpVolumeHeaderId
	)
	SELECT 
		  FdpChangesetDataItemId		
		, CreatedOn						
		, FdpChangesetId				
		, MarketId						
		, CASE 
			WHEN ModelId IS NOT NULL THEN 'O' + CAST(ModelId AS NVARCHAR(10))
			WHEN FdpModelId IS NOT NULL THEN 'F' + CAST(FdpModelId AS NVARCHAR(10))
			ELSE NULL
		  END AS ModelIdentifier								
		, CASE
			WHEN FeaturePackId IS NOT NULL AND FeatureId IS NULL THEN 'P' + CAST(FeaturePackId AS NVARCHAR(10)) 
			WHEN FeatureId IS NOT NULL THEN 'O' + CAST(FeatureId AS NVARCHAR(10))
			WHEN FdpFeatureId IS NOT NULL THEN 'F' + CAST(FdpFeatureId AS NVARCHAR(10))
			ELSE NULL
		  END AS FeatureIdentifier	
		, CASE
			WHEN DerivativeCode IS NOT NULL
			THEN
			'D' + DerivativeCode
			ELSE NULL
		  END AS DerivativeIdentifier				
		, TotalVolume					
		, PercentageTakeRate						
		, IsVolumeUpdate				
		, IsPercentageUpdate			
		, OriginalVolume				
		, OriginalPercentageTakeRate	
		, FdpVolumeDataItemId			
		, FdpTakeRateSummaryId
		, FdpTakeRateFeatureMixId
		, FdpPowertrainDataItemId			
		, ParentFdpChangesetDataItemId
		, @IsMarketReview
		, FdpVolumeHeaderId

	FROM Fdp_ChangesetDataItem
	WHERE
	ParentFdpChangesetDataItemId = @FdpChangesetDataItemId
	OR
	FdpChangesetDataItemId = @FdpChangesetDataItemId;
	
	-- Mark all validation entries for that changeset item as deleted
	
	DELETE FROM Fdp_Validation WHERE FdpChangesetDataItemId IN
	(
		SELECT FdpChangeSetDataItemId FROM @UndoneChanges
	)
	-- Mark all rows with the changeset data item as a parent as deleted (irrevocably)

	DELETE
	FROM Fdp_ChangesetDataItem
	WHERE
	FdpChangesetDataItemId IN 
	(
		SELECT FdpChangeSetDataItemId FROM @UndoneChanges
	)

	-- If necessary, mark the change prior to this one as undeleted

	UPDATE D SET IsDeleted = 0
	FROM
	Fdp_ChangesetDataItem AS D
	WHERE
	(
		ParentFdpChangesetDataItemId = @PriorFdpChangesetDataItemId
		OR
		FdpChangesetDataItemId = @PriorFdpChangesetDataItemId
	)
	AND
	@PriorFdpChangesetDataItemId IS NOT NULL
	
	-- This dataset contains any  that have been undone so far as they have reverted to their original committed values
	-- We need to use this to revert values in the UI without having to resort to reloading the page

	SELECT 
		  U.FdpChangesetDataItemId		
		, U.CreatedOn						
		, U.FdpChangesetId				
		, U.MarketId						
		, U.ModelIdentifier									
		, U.FeatureIdentifier
		, U.DerivativeIdentifier											
		, U.TotalVolume					
		, U.PercentageTakeRate								
		, U.IsVolumeUpdate				
		, U.IsPercentageUpdate			
		, ISNULL(V.Volume, U.OriginalVolume) AS OriginalVolume				
		, ISNULL(V.PercentageTakeRate, U.OriginalPercentageTakeRate) AS OriginalPercentageTakeRate	
		, U.FdpVolumeDataItemId			
		, U.FdpTakeRateSummaryId
		, U.FdpTakeRateFeatureMixId	
		, U.FdpPowertrainDataItemId				
		, U.ParentFdpChangesetDataItemId 
		, U.IsMarketReview
		, CAST(CASE WHEN V.Volume = U.OriginalVolume AND V.PercentageTakeRate = U.OriginalPercentageTakeRate THEN 1 ELSE 0 END AS BIT) AS IsReverted
		, 1 AS Part
	FROM
	@UndoneChanges						AS U
	JOIN Fdp_VolumeDataItem_VW			AS V	ON	U.FdpVolumeDataItemId	= V.FdpVolumeDataItemId

	UNION

	SELECT 
		  U.FdpChangesetDataItemId		
		, U.CreatedOn						
		, U.FdpChangesetId				
		, U.MarketId						
		, U.ModelIdentifier									
		, U.FeatureIdentifier
		, U.DerivativeIdentifier											
		, U.TotalVolume					
		, U.PercentageTakeRate								
		, U.IsVolumeUpdate				
		, U.IsPercentageUpdate			
		, ISNULL(H.TotalVolume, U.OriginalVolume) AS OriginalVolume				
		, 1 AS OriginalPercentageTakeRate	
		, U.FdpVolumeDataItemId			
		, U.FdpTakeRateSummaryId
		, U.FdpTakeRateFeatureMixId	
		, U.FdpPowertrainDataItemId				
		, U.ParentFdpChangesetDataItemId 
		, U.IsMarketReview
		, CAST(CASE WHEN H.TotalVolume = U.OriginalVolume THEN 1 ELSE 0 END AS BIT) AS IsReverted
		, 2 AS Part
	FROM
	@UndoneChanges						AS U
	JOIN Fdp_VolumeHeader_VW			AS H	ON	U.FdpVolumeHeaderId	= H.FdpVolumeHeaderId
	
	UNION

	SELECT 
		  U.FdpChangesetDataItemId		
		, U.CreatedOn						
		, U.FdpChangesetId				
		, U.MarketId						
		, U.ModelIdentifier										
		, U.FeatureIdentifier
		, U.DerivativeIdentifier					
		, U.TotalVolume					
		, U.PercentageTakeRate								
		, U.IsVolumeUpdate				
		, U.IsPercentageUpdate			
		, S.Volume AS OriginalVolume				
		, S.PercentageTakeRate AS OriginalPercentageTakeRate	
		, U.FdpVolumeDataItemId			
		, U.FdpTakeRateSummaryId	
		, U.FdpTakeRateFeatureMixId
		, U.FdpPowertrainDataItemId				
		, U.ParentFdpChangesetDataItemId 
		, U.IsMarketReview
		, CAST(CASE WHEN S.Volume = U.OriginalVolume AND S.PercentageTakeRate = U.OriginalPercentageTakeRate THEN 1 ELSE 0 END AS BIT) AS IsReverted
		, 3 AS Part
	FROM
	@UndoneChanges						AS U
	JOIN Fdp_TakeRateSummary			AS S	ON	U.FdpTakeRateSummaryId	= S.FdpTakeRateSummaryId

	UNION

	SELECT 
		  U.FdpChangesetDataItemId		
		, U.CreatedOn						
		, U.FdpChangesetId				
		, U.MarketId						
		, U.ModelIdentifier										
		, U.FeatureIdentifier
		, U.DerivativeIdentifier					
		, U.TotalVolume					
		, U.PercentageTakeRate								
		, U.IsVolumeUpdate				
		, U.IsPercentageUpdate			
		, M.Volume AS OriginalVolume				
		, M.PercentageTakeRate AS OriginalPercentageTakeRate	
		, U.FdpVolumeDataItemId			
		, U.FdpTakeRateSummaryId
		, U.FdpTakeRateFeatureMixId			
		, U.FdpPowertrainDataItemId
		, U.ParentFdpChangesetDataItemId 
		, U.IsMarketReview
		, CAST(CASE WHEN M.Volume = U.OriginalVolume AND M.PercentageTakeRate = U.OriginalPercentageTakeRate THEN 1 ELSE 0 END AS BIT) AS IsReverted
		, 4 AS Part
	FROM
	@UndoneChanges						AS U
	JOIN Fdp_TakeRateFeatureMix			AS M	ON	U.FdpTakeRateFeatureMixId	= M.FdpTakeRateFeatureMixId
	
	UNION
	
	SELECT 
		  U.FdpChangesetDataItemId		
		, U.CreatedOn						
		, U.FdpChangesetId				
		, U.MarketId						
		, U.ModelIdentifier										
		, U.FeatureIdentifier
		, U.DerivativeIdentifier					
		, U.TotalVolume					
		, U.PercentageTakeRate								
		, U.IsVolumeUpdate				
		, U.IsPercentageUpdate			
		, P.Volume AS OriginalVolume				
		, P.PercentageTakeRate AS OriginalPercentageTakeRate	
		, U.FdpVolumeDataItemId			
		, U.FdpTakeRateSummaryId
		, U.FdpTakeRateFeatureMixId	
		, U.FdpPowertrainDataItemId		
		, U.ParentFdpChangesetDataItemId 
		, U.IsMarketReview
		, CAST(CASE WHEN P.Volume = U.OriginalVolume AND P.PercentageTakeRate = U.OriginalPercentageTakeRate THEN 1 ELSE 0 END AS BIT) AS IsReverted
		, 5 AS Part
	FROM
	@UndoneChanges						AS U
	JOIN Fdp_PowertrainDataItem			AS P	ON	U.FdpPowertrainDataItemId	= P.FdpPowertrainDataItemId