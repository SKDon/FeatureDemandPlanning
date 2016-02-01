CREATE PROCEDURE [dbo].[Fdp_ChangesetDataItem_CalculateVolumeForAllFeaturesInMarket]
	@FdpChangesetDataItemId AS INT
AS
	SET NOCOUNT ON;

	DECLARE @DataForFeature AS TABLE
	(
		  Id							INT PRIMARY KEY IDENTITY(1,1)
		, FdpChangesetId				INT
		, MarketId						INT
		, ModelId						INT NULL
		, FeatureId						INT NULL
		, FdpModelId					INT NULL
		, FdpFeatureId					INT NULL
		, TotalVolume					INT
		, PercentageTakeRate			DECIMAL(5, 4)
		, FdpVolumeDataItemId			INT 
		, ParentFdpChangesetDataItemId	INT
	);
												
	-- Create new changeset entries based on older changeset entries
	-- We need to update the volume based on the % take for the changeset item
	
	PRINT 'Calculating new changeset data from existing changes...';
	
	INSERT INTO @DataForFeature
	(
		  FdpChangesetId
		, MarketId
		, ModelId
		, FdpModelId
		, FeatureId
		, FdpFeatureId
		, TotalVolume
		, PercentageTakeRate
		, FdpVolumeDataItemId
		, ParentFdpChangesetDataItemId
	)
	SELECT 
		  D.FdpChangesetId
		, D.MarketId
		, D.ModelId
		, D.FdpModelId
		, D1.FeatureId
		, D1.FdpFeatureId
		, dbo.fn_Fdp_VolumeByModel_Get(D.FdpVolumeHeaderId, D1.ModelId, D1.FdpModelId, D.MarketId, D.CDSId) * D1.PercentageTakeRate
		, D1.PercentageTakeRate
		, D1.FdpVolumeDataItemId
		, D.FdpChangesetDataItemId
		
	FROM Fdp_ChangesetDataItem_VW AS D
	JOIN Fdp_ChangesetDataItem_VW AS D1	ON D.FdpChangesetId = D1.FdpChangesetId
										AND D.MarketId		= D1.MarketId
										AND D.FdpChangesetDataItemId <> D1.FdpChangesetDataItemId
										AND D1.IsFeatureUpdate = 1
	WHERE
	D.FdpChangesetDataItemId = @FdpChangesetDataItemId;
	
	-- Add all volume data existing rows to our data table where there is not an active changeset item currently
	
	PRINT 'Calculating new changeset data...';
	
	INSERT INTO @DataForFeature
	(
		  FdpChangesetId
		, MarketId
		, ModelId
		, FdpModelId
		, FeatureId
		, FdpFeatureId
		, TotalVolume
		, PercentageTakeRate
		, FdpVolumeDataItemId
		, ParentFdpChangesetDataItemId
	)
	SELECT
		  D.FdpChangesetId
		, D1.MarketId
		, D1.ModelId
		, D1.FdpModelId
		, D1.FeatureId
		, D1.FdpFeatureId
		, dbo.fn_Fdp_VolumeByModel_Get(D.FdpVolumeHeaderId, D1.ModelId, D1.FdpModelId, D.MarketId, D.CDSId) * D1.PercentageTakeRate
		, D1.PercentageTakeRate
		, D1.FdpVolumeDataItemId
		, D.FdpChangesetDataItemId
	FROM
	Fdp_ChangesetDataItem_VW	AS D
	JOIN Fdp_VolumeDataItem_VW	AS D1	ON	D.FdpVolumeHeaderId			= D1.FdpVolumeHeaderId
										AND D.MarketId					= D1.MarketId
										AND D1.IsFeatureData			= 1
	LEFT JOIN Fdp_ChangesetDataItem AS CUR
										ON	D1.FdpVolumeDataItemId		= CUR.FdpVolumeDataItemId
										AND D.FdpChangesetId			= CUR.FdpChangesetId
										AND CUR.IsDeleted				= 0
	WHERE
	D.FdpChangesetDataItemId = @FdpChangesetDataItemId
	AND
	CUR.FdpChangesetDataItemId IS NULL;
	
	-- Delete any existing changeset rows
	
	PRINT 'Deleting existing changes for model...';
	
	UPDATE D2 SET IsDeleted = 1
	FROM
	Fdp_ChangesetDataItem_VW		AS D
	JOIN Fdp_ChangesetDataItem_VW	AS D1	ON	D.FdpChangesetId			= D1.FdpChangesetId
											AND D1.IsFeatureUpdate			= 1
	JOIN Fdp_ChangesetDataItem		AS D2	ON	D1.FdpChangesetDataItemId	= D2.FdpChangesetDataItemId
	WHERE
	D.FdpChangesetDataItemId = @FdpChangesetDataItemId;
	
	-- Add new new changeset rows
	
	PRINT 'Adding new changeset data...';
	
	INSERT INTO Fdp_ChangesetDataItem
	(
		  FdpChangesetId
		, MarketId
		, ModelId
		, FdpModelId
		, FeatureId
		, FdpFeatureId
		, TotalVolume
		, PercentageTakeRate
		, IsVolumeUpdate
		, IsPercentageUpdate
		, FdpVolumeDataItemId
		, ParentFdpChangesetDataItemId
	)
	SELECT 
		  FdpChangesetId
		, MarketId
		, ModelId
		, FdpModelId
		, FeatureId
		, FdpFeatureId
		, TotalVolume
		, PercentageTakeRate
		, 1
		, 0
		, FdpVolumeDataItemId
		, ParentFdpChangesetDataItemId
	FROM 
	@DataForFeature;