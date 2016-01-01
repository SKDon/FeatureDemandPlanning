CREATE PROCEDURE [dbo].[Fdp_ChangesetDataItem_CalculatePercentageTakeRate]
	@FdpChangesetDataItemId AS INT
AS
	SET NOCOUNT ON;
	
	DECLARE @IsFeatureUpdate AS BIT;
	DECLARE @IsModelUpdate AS BIT;
	DECLARE @IsMarketUpdate AS BIT;
	DECLARE @Volume AS INT;
	
	SELECT TOP 1 
		  @IsFeatureUpdate	= D.IsFeatureUpdate
		, @IsModelUpdate	= D.IsModelUpdate
		, @IsMarketUpdate	= D.IsMarketUpdate
	FROM
	Fdp_ChangesetDataItem_VW AS D
	WHERE
	D.FdpChangesetDataItemId = @FdpChangesetDataItemId;
	
	IF @IsFeatureUpdate = 1
	BEGIN
		PRINT 'Updating % take at feature level'
		
		-- Calculate the volume for the model

		SELECT @Volume = dbo.fn_Fdp_VolumeByModel_Get(FdpVolumeHeaderId, ModelId, FdpModelId, MarketId, CDSId)
		FROM
		Fdp_ChangesetDataItem_VW 
		WHERE
		FdpChangesetDataItemId = @FdpChangesetDataItemId;
								
	END
	ELSE IF @IsModelUpdate = 1
	BEGIN
		PRINT 'Calculating % take at model level'

		-- Calculate the volume for the market
		
		SELECT @Volume = dbo.fn_Fdp_VolumeByMarket_Get(FdpVolumeHeaderId, MarketId, CDSId)
		FROM
		Fdp_ChangesetDataItem_VW 
		WHERE
		FdpChangesetDataItemId = @FdpChangesetDataItemId;

	END
	ELSE IF @IsMarketUpdate = 1
	BEGIN
		PRINT 'Calculating % take at market level'

		SELECT @Volume = SUM(M.Volume)
		FROM
		Fdp_ChangesetDataItem_VW AS D
		CROSS APPLY dbo.fn_Fdp_VolumeByMarket_GetMany(D.FdpVolumeHeaderId, D.CDSId) AS M
		WHERE
		D.FdpChangesetDataItemId = @FdpChangesetDataItemId;
	END

	UPDATE D SET PercentageTakeRate = 
		CASE 
			WHEN ISNULL(@Volume, 0) > 0 THEN D.TotalVolume / CAST(@Volume AS DECIMAL)
			ELSE 0
		END
	FROM Fdp_ChangesetDataItem AS D
	WHERE 
	D.FdpChangesetDataItemId = @FdpChangesetDataItemId;