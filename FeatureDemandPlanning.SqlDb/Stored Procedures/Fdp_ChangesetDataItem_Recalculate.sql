CREATE PROCEDURE [dbo].[Fdp_ChangesetDataItem_Recalculate]
	  @FdpChangesetDataItemId AS INT
AS
	SET NOCOUNT ON;
	
	DECLARE @IsVolumeUpdate BIT;
	DECLARE @IsMarketUpdate BIT; -- Update performed at whole market level
	DECLARE @IsModelUpdate BIT; -- Update performed at the model level as opposed to feature
	DECLARE @IsFeatureUpdate BIT;
	
	SELECT 
		  @IsVolumeUpdate	= D.IsVolumeUpdate
		, @IsMarketUpdate	= D.IsMarketUpdate
		, @IsFeatureUpdate	= D.IsFeatureUpdate
		, @IsModelUpdate	= D.IsModelUpdate
	FROM Fdp_ChangesetDataItem_VW AS D
	WHERE
	D.FdpChangesetDataItemId = @FdpChangesetDataItemId;
	
	-- Dependant on what has been updated, recalculate the other figure % or volume accordingly
	
	IF @IsVolumeUpdate = 1
	BEGIN
		PRINT 'Updating % take based on volume'
		EXEC Fdp_ChangesetDataItem_CalculatePercentageTakeRate @FdpChangesetDataItemId = @FdpChangesetDataItemId;
	END
	ELSE
	BEGIN
		PRINT 'Updating volume based on % take'
		EXEC Fdp_ChangesetDataItem_CalculateVolume @FdpChangesetDataItemId = @FdpChangesetDataItemId;
	END
	
	IF @IsMarketUpdate = 1
	BEGIN
		PRINT 'Calculating volume for all models in market'
		EXEC Fdp_ChangesetDataItem_CalculateVolumeForAllModelsInMarket @FdpChangesetDataItemId = @FdpChangesetDataItemId;
		
		PRINT 'Calculating volume for all features in market'
		EXEC Fdp_ChangesetDataItem_CalculateVolumeForAllFeaturesInMarket @FdpChangesetDataItemId = @FdpChangesetDataItemId;
		
		PRINT 'Calculating feature mix for all features in market'
		EXEC Fdp_ChangesetDataItem_CalculateFeatureMixForAllFeatures @FdpChangesetDataItemId = @FdpChangesetDataItemId;
	END
	ELSE IF @IsModelUpdate = 1
	BEGIN
		-- If the volume at model level has been updated, we need to adjust the volume of all features for that model
		-- based on their % take
		PRINT 'Calculating volume for all features (model)'
		EXEC Fdp_ChangesetDataItem_CalculateVolumeForAllFeaturesForModel @FdpChangesetDataItemId = @FdpChangesetDataItemId;
		
		PRINT 'Calculating feature mix for all features (model)'
		EXEC Fdp_ChangesetDataItem_CalculateFeatureMixForAllFeatures @FdpChangesetDataItemId = @FdpChangesetDataItemId;
	END
	ELSE IF @IsFeatureUpdate = 1
	BEGIN
		PRINT 'Calculating feature mix for feature'
		EXEC Fdp_ChangesetDataItem_CalculateFeatureMixForSingleFeature @FdpChangesetDataItemId = @FdpChangesetDataItemId;
	END
	
	EXEC Fdp_ChangesetDataItem_Get @FdpChangesetDataItemId = @FdpChangesetDataItemId;