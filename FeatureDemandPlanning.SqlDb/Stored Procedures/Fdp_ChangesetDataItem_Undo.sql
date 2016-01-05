CREATE PROCEDURE [dbo].[Fdp_Changeset_Undo]
	@FdpChangesetId INT
AS
	SET NOCOUNT ON;

	DECLARE @FdpChangesetDataItemId INT;
	DECLARE @PriorFdpChangesetDataItemId INT;
	DECLARE @FdpVolumeDataItemId INT;
	DECLARE @FdpTakeRateSummaryId INT;

	DECLARE @UndoneChanges AS TABLE
	(
		  FdpChangesetDataItemId		INT
		, CreatedOn						DATETIME
		, FdpChangesetId				INT
		, MarketId						INT
		, ModelIdentifier				NVARCHAR(10)
		, FeatureIdentifier				NVARCHAR(10)
		, TotalVolume					INT
		, PercentageTakeRate			DECIMAL(5,4)
		, IsVolumeUpdate				BIT
		, IsPercentageUpdate			BIT
		, OriginalVolume				INT NULL
		, OriginalPercentageTakeRate	DECIMAL(5,4) NULL
		, FdpVolumeDataItemId			INT NULL
		, FdpTakeRateSummaryId			INT	NULL
		, ParentFdpChangesetDataItemId	INT NULL
	)

	-- Get the most recent change for that changeset

	SELECT TOP 1 
		  @FdpChangesetDataItemId	= FdpChangesetDataItemId
		, @FdpVolumeDataItemId		= FdpVolumeDataItemId
		, @FdpTakeRateSummaryId		= FdpTakeRateSummaryId
	FROM
	Fdp_ChangesetDataItem_VW
	WHERE
	FdpChangesetId = @FdpChangesetId
	AND
	ParentFdpChangesetDataItemId IS NULL
	ORDER BY
	FdpChangesetDataItemId DESC;

	-- Get the identifier of any changeset data prior to the most recent change
	-- It will be marked as deleted

	IF @FdpVolumeDataItemId IS NOT NULL
	BEGIN
		SELECT TOP 1 @PriorFdpChangesetDataItemId = FdpChangesetDataItemId
		FROM
		Fdp_ChangesetDataItem
		WHERE
		FdpChangesetId = @FdpChangesetId
		AND
		FdpVolumeDataItemId = @FdpVolumeDataItemId
		AND
		ParentFdpChangesetDataItemId IS NULL
		AND
		IsDeleted = 1
		AND
		FdpChangesetDataItemId < @FdpChangesetDataItemId
		ORDER BY
		FdpChangesetDataItemId DESC;
	END

	IF @FdpTakeRateSummaryId IS NOT NULL
	BEGIN
		SELECT TOP 1 @PriorFdpChangesetDataItemId = FdpChangesetDataItemId
		FROM
		Fdp_ChangesetDataItem
		WHERE
		FdpChangesetId = @FdpChangesetId
		AND
		FdpTakeRateSummaryId = @FdpTakeRateSummaryId
		AND
		ParentFdpChangesetDataItemId IS NULL
		AND
		IsDeleted = 1
		AND
		FdpChangesetDataItemId < @FdpChangesetDataItemId
		ORDER BY
		FdpChangesetDataItemId DESC;
	END

	-- Add the rows that are going to be removed to the undone changes dataset, as we need to process further after deletion

	INSERT INTO @UndoneChanges
	(
		  FdpChangesetDataItemId		
		, CreatedOn						
		, FdpChangesetId				
		, MarketId						
		, ModelIdentifier									
		, FeatureIdentifier									
		, TotalVolume					
		, PercentageTakeRate							
		, IsVolumeUpdate				
		, IsPercentageUpdate			
		, OriginalVolume				
		, OriginalPercentageTakeRate	
		, FdpVolumeDataItemId			
		, FdpTakeRateSummaryId			
		, ParentFdpChangesetDataItemId
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
			WHEN FeatureId IS NOT NULL THEN 'O' + CAST(FeatureId AS NVARCHAR(10))
			WHEN FdpFeatureId IS NOT NULL THEN 'F' + CAST(FdpFeatureId AS NVARCHAR(10))
			ELSE NULL
		  END AS FeatureIdentifier					
		, TotalVolume					
		, PercentageTakeRate						
		, IsVolumeUpdate				
		, IsPercentageUpdate			
		, OriginalVolume				
		, OriginalPercentageTakeRate	
		, FdpVolumeDataItemId			
		, FdpTakeRateSummaryId			
		, ParentFdpChangesetDataItemId

	FROM Fdp_ChangesetDataItem
	WHERE
	ParentFdpChangesetDataItemId = @FdpChangesetDataItemId
	OR
	FdpChangesetDataItemId = @FdpChangesetDataItemId;

	-- Mark all rows with the changeset data item as a parent as deleted (irrevocably)

	DELETE
	FROM
	Fdp_ChangesetDataItem
	WHERE
	ParentFdpChangesetDataItemId = @FdpChangesetDataItemId
	OR
	FdpChangesetDataItemId = @FdpChangesetDataItemId;

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
		, U.TotalVolume					
		, U.PercentageTakeRate								
		, U.IsVolumeUpdate				
		, U.IsPercentageUpdate			
		, V.Volume AS OriginalVolume				
		, V.PercentageTakeRate AS OriginalPercentageTakeRate	
		, U.FdpVolumeDataItemId			
		, U.FdpTakeRateSummaryId			
		, U.ParentFdpChangesetDataItemId 
	FROM
	@UndoneChanges						AS U
	JOIN Fdp_VolumeDataItem_VW			AS V	ON	U.FdpVolumeDataItemId	= V.FdpVolumeDataItemId
	LEFT JOIN Fdp_ChangesetDataItem_VW	AS D	ON	U.FdpChangesetId		= D.FdpChangesetId
												AND U.FdpVolumeDataItemId	= D.FdpVolumeDataItemId
	WHERE
	D.FdpChangesetDataItemId IS NULL

	UNION

	SELECT 
		  U.FdpChangesetDataItemId		
		, U.CreatedOn						
		, U.FdpChangesetId				
		, U.MarketId						
		, U.ModelIdentifier										
		, U.FeatureIdentifier					
		, U.TotalVolume					
		, U.PercentageTakeRate								
		, U.IsVolumeUpdate				
		, U.IsPercentageUpdate			
		, S.Volume AS OriginalVolume				
		, S.PercentageTakeRate AS OriginalPercentageTakeRate	
		, U.FdpVolumeDataItemId			
		, U.FdpTakeRateSummaryId			
		, U.ParentFdpChangesetDataItemId 
	FROM
	@UndoneChanges						AS U
	JOIN Fdp_TakeRateSummary			AS S	ON	U.FdpTakeRateSummaryId	= S.FdpTakeRateSummaryId
	LEFT JOIN Fdp_ChangesetDataItem_VW	AS D	ON	U.FdpChangesetId		= D.FdpChangesetId
												AND U.FdpTakeRateSummaryId	= D.FdpTakeRateSummaryId
	WHERE
	D.FdpChangesetDataItemId IS NULL



