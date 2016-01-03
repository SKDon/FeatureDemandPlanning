CREATE PROCEDURE [dbo].[Fdp_ChangesetDataItem_CalculateVolume]
	@FdpChangesetDataItemId AS INT
AS
	SET NOCOUNT ON;
	
	DECLARE @IsFeatureUpdate	AS BIT;
	DECLARE @IsModelUpdate		AS BIT;
	DECLARE @IsMarketUpdate		AS BIT;

	SELECT 
		  @IsFeatureUpdate	= D.IsFeatureUpdate 
		, @IsModelUpdate	= D.IsModelUpdate
		, @IsMarketUpdate	= D.IsMarketUpdate
	FROM
	Fdp_ChangesetDataItem_VW AS D
	WHERE
	D.FdpChangesetDataItemId = @FdpChangesetDataItemId;
	
	IF @IsFeatureUpdate = 1
	BEGIN
		UPDATE D SET TotalVolume = CAST(CEILING(dbo.fn_Fdp_VolumeByModel_Get(D1.FdpVolumeHeaderId, D.ModelId, D.FdpModelId, D.MarketId, D1.CDSId) * D.PercentageTakeRate) AS INT)
		FROM
		Fdp_ChangesetDataItem AS D
		JOIN Fdp_ChangesetDataItem_VW AS D1 ON D.FdpChangesetDataItemId = D1.FdpChangesetDataItemId
		WHERE
		D.FdpChangesetDataItemId = @FdpChangesetDataItemId										
	END
	ELSE IF @IsModelUpdate = 1
	BEGIN
		
		UPDATE D SET TotalVolume = CAST(CEILING(dbo.fn_Fdp_VolumeByMarket_Get(D1.FdpVolumeHeaderId, D.MarketId, D1.CDSId) * D.PercentageTakeRate) AS INT)
		FROM
		Fdp_ChangesetDataItem AS D
		JOIN Fdp_ChangesetDataItem_VW AS D1 ON D.FdpChangesetDataItemId = D1.FdpChangesetDataItemId
		WHERE
		D.FdpChangesetDataItemId = @FdpChangesetDataItemId																				

		---- Now that the volume has been updated for the model, we need to recalculate the volumes
		---- for all features under that model

		--EXEC Fdp_ChangesetDataItem_CalculateFeatureVolumes @FdpChangesetDataItemId = @FdpChangesetDataItemId;
		
	END