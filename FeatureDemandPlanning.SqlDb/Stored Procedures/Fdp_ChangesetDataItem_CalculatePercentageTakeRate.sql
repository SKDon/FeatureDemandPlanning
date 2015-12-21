CREATE PROCEDURE [dbo].[Fdp_ChangesetDataItem_CalculatePercentageTakeRate]
	@FdpChangesetDataItemId AS INT
AS
	SET NOCOUNT ON;
	
	DECLARE @IsFeatureUpdate AS BIT;
	DECLARE @IsModelUpdate AS BIT;
	DECLARE @IsMarketUpdate AS BIT;
	
	SELECT TOP 1 
		@IsFeatureUpdate = 
		CASE
			WHEN D.FeatureId IS NOT NULL THEN 1
			WHEN D.FdpFeatureId IS NOT NULL THEN 1
			ELSE 0
		END
		, @IsModelUpdate =
		CASE
			WHEN D.ModelId IS NOT NULL THEN 1
			WHEN D.FdpModelId IS NOT NULL THEN 1
			ELSE 0
		END
		, @IsMarketUpdate = 
		CASE
			WHEN D.FeatureId IS NULL AND D.FdpFeatureId IS NULL AND
			D.ModelId IS NULL AND D.FdpModelId IS NULL THEN 1
			ELSE 0
		END
	FROM
	Fdp_ChangesetDataItem AS D
	WHERE
	D.FdpChangesetDataItemId = @FdpChangesetDataItemId;
	
	IF @IsFeatureUpdate = 1
	BEGIN
		PRINT 'Updating % take at feature level'
		
		-- Oxo Models
		
		UPDATE D SET PercentageTakeRate = 
			CASE 
				WHEN ISNULL(S.TotalVolume, 0) > 0 THEN D.TotalVolume / CAST(S.TotalVolume AS DECIMAL)
				ELSE 0
			END
		FROM Fdp_Changeset							AS C
		JOIN Fdp_VolumeHeader						AS H	ON	C.FdpVolumeHeaderId = H.FdpVolumeHeaderId	
		JOIN Fdp_ChangesetDataItem					AS D	ON	C.FdpChangesetId	= D.FdpChangesetId
		JOIN Fdp_TakeRateSummaryByModelAndMarket_VW	AS S	ON	H.DocumentId = S.DocumentId
															AND	D.MarketId	 = S.MarketId
															AND D.ModelId	 = S.ModelId												
		WHERE
		D.FdpChangesetDataItemId = @FdpChangesetDataItemId;
		
		-- Fdp Models
		
		UPDATE D SET PercentageTakeRate = 
			CASE 
				WHEN ISNULL(S.TotalVolume, 0) > 0 THEN D.TotalVolume / CAST(S.TotalVolume AS DECIMAL)
				ELSE 0
			END
		FROM Fdp_Changeset							AS C
		JOIN Fdp_VolumeHeader						AS H	ON	C.FdpVolumeHeaderId = H.FdpVolumeHeaderId	
		JOIN Fdp_ChangesetDataItem					AS D	ON	C.FdpChangesetId	= D.FdpChangesetId
		JOIN Fdp_TakeRateSummaryByModelAndMarket_VW	AS S	ON	H.DocumentId = S.DocumentId
															AND	D.MarketId	 = S.MarketId
															AND D.FdpModelId = S.FdpModelId												
		WHERE
		D.FdpChangesetDataItemId = @FdpChangesetDataItemId;
		
	END
	ELSE IF @IsModelUpdate = 1
	BEGIN
		PRINT 'Calculating % take at model level'
		
		-- Oxo and Fdp Models
		
		UPDATE D SET PercentageTakeRate = 
			CASE 
				WHEN ISNULL(S.TotalVolume, 0) > 0 THEN D.TotalVolume / CAST(S.TotalVolume AS DECIMAL)
				ELSE 0
			END
		FROM Fdp_Changeset						AS C
		JOIN Fdp_VolumeHeader					AS H	ON	C.FdpVolumeHeaderId = H.FdpVolumeHeaderId	
		JOIN Fdp_ChangesetDataItem				AS D	ON	C.FdpChangesetId	= D.FdpChangesetId
		JOIN Fdp_TakeRateSummaryByMarket_VW		AS S	ON	H.DocumentId		= S.DocumentId
															AND	D.MarketId		= S.MarketId												
		WHERE
		D.FdpChangesetDataItemId = @FdpChangesetDataItemId;
	
	END
	ELSE IF @IsMarketUpdate = 1
	BEGIN
		PRINT 'Calculating % take at market level'
		
		DECLARE @TotalVolumeForAllMarkets AS INT;
		SELECT @TotalVolumeForAllMarkets =
		SUM(
			CASE 
				WHEN S1.FdpChangesetDataItemId IS NOT NULL THEN S1.TotalVolume
				ELSE S.TotalVolume
			END
		)
		FROM 
		Fdp_Changeset AS C
		JOIN Fdp_VolumeHeader				AS H	ON	C.FdpVolumeHeaderId = H.FdpVolumeHeaderId
		JOIN Fdp_ChangesetDataItem			AS D	ON	C.FdpChangesetId	= D.FdpChangesetId
		JOIN Fdp_TakeRateSummaryByMarket_VW AS S	ON	H.DocumentId		= S.DocumentId
		LEFT JOIN Fdp_ChangesetDataItem		AS S1	ON	C.FdpChangesetId	= S1.FdpChangesetId
													AND S1.IsDeleted		= 0
													AND S.MarketId			= S1.MarketId
													AND S1.ModelId			IS NULL
													AND S1.FdpModelId		IS NULL
													AND S1.FeatureId		IS NULL
													AND S1.FdpFeatureId		IS NULL
		WHERE
		D.FdpChangesetDataItemId = @FdpChangesetDataItemId;
		
		UPDATE D SET PercentageTakeRate =
			D.TotalVolume / CAST(@TotalVolumeForAllMarkets AS DECIMAL)
		FROM Fdp_Changeset			AS C
		JOIN Fdp_VolumeHeader		AS H	ON	C.FdpVolumeHeaderId = H.FdpVolumeHeaderId	
		JOIN Fdp_ChangesetDataItem	AS D	ON	C.FdpChangesetId	= D.FdpChangesetId
		WHERE
		D.FdpChangesetDataItemId = @FdpChangesetDataItemId;
		
	END