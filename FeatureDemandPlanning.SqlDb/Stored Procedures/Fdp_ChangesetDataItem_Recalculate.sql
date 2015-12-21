CREATE PROCEDURE [dbo].[Fdp_ChangesetDataItem_Recalculate]
	  @FdpChangesetDataItemId AS INT
AS
	SET NOCOUNT ON;
	
	DECLARE @IsVolumeUpdate BIT;
	DECLARE @IsMarketUpdate BIT; -- Update performed at whole market level
	DECLARE @IsModelUpdate BIT; -- Update performed at the model level as opposed to feature
	DECLARE @IsFeatureUpdate BIT;
	
	SELECT @IsVolumeUpdate = D.IsVolumeUpdate
		, @IsMarketUpdate =
			CASE
				WHEN D.ModelId IS NULL AND D.FdpModelId IS NULL AND D.FeatureId IS NULL AND D.FdpFeatureId IS NULL THEN 1
				ELSE 0
			END
		, @IsModelUpdate = 
			CASE
				WHEN D.FeatureId IS NULL AND D.FdpFeatureId IS NULL THEN 1
				ELSE 0
			END
		, @IsFeatureUpdate = 
			CASE
				WHEN D.FeatureId IS NOT NULL OR D.FdpFeatureId IS NOT NULL THEN 1
				ELSE 0
			END
	FROM Fdp_ChangesetDataItem AS D
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
	
	-- Calculate the feature mix (both percentage and volume)
	IF @IsMarketUpdate = 1
	BEGIN
		PRINT 'Calculating volume for all models'
		EXEC Fdp_ChangesetDataItem_CalculateVolumeForAllModels @FdpChangesetDataItemId = @FdpChangesetDataItemId;
		
		PRINT 'Calculating volume for all features'
		EXEC Fdp_ChangesetDataItem_CalculateVolumeForAllFeatures @FdpChangesetDataItemId = @FdpChangesetDataItemId;
		
		PRINT 'Calculating feature mix for all features'
		EXEC Fdp_ChangesetDataItem_CalculateFeatureMixForAllFeatures @FdpChangesetDataItemId = @FdpChangesetDataItemId;
	END
	ELSE IF @IsModelUpdate = 1
	BEGIN
		PRINT 'Calculating volume for all features'
		EXEC Fdp_ChangesetDataItem_CalculateVolumeForAllFeatures @FdpChangesetDataItemId = @FdpChangesetDataItemId;
		
		PRINT 'Calculating feature mix for all features'
		EXEC Fdp_ChangesetDataItem_CalculateFeatureMixForAllFeatures @FdpChangesetDataItemId = @FdpChangesetDataItemId;
	END
	ELSE IF @IsFeatureUpdate = 1
	BEGIN
		PRINT 'Calculating feature mix for feature'
		EXEC Fdp_ChangesetDataItem_CalculateFeatureMix @FdpChangesetDataItemId = @FdpChangesetDataItemId;
	END
	
	EXEC Fdp_ChangesetDataItem_Get @FdpChangesetDataItemId = @FdpChangesetDataItemId;