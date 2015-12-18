CREATE PROCEDURE [dbo].[Fdp_ChangesetDataItem_CalculateVolume]
	@FdpChangesetDataItemId AS INT
AS
	SET NOCOUNT ON;
	
	DECLARE @IsFeatureUpdate AS BIT;
	SELECT TOP 1 @IsFeatureUpdate = 
		CASE
			WHEN D.FeatureId IS NOT NULL THEN 1
			WHEN D.FdpFeatureId IS NOT NULL THEN 1
			ELSE 0
		END
	FROM
	Fdp_ChangesetDataItem AS D
	WHERE
	D.FdpChangesetDataItemId = @FdpChangesetDataItemId;
	
	IF @IsFeatureUpdate = 1
	BEGIN
		-- Oxo Models
		
		UPDATE D SET TotalVolume = CAST(CEILING(S.TotalVolume * D.PercentageTakeRate) AS INT)
		FROM Fdp_Changeset									AS C
		JOIN Fdp_VolumeHeader								AS H	ON	C.FdpVolumeHeaderId = H.FdpVolumeHeaderId	
		JOIN Fdp_ChangesetDataItem							AS D	ON	C.FdpChangesetId	= D.FdpChangesetId
		JOIN Fdp_TakeRateSummaryByModelAndMarket_VW	AS S	ON	H.DocumentId = S.DocumentId
																	AND	D.MarketId	 = S.MarketId
																	AND D.ModelId	 = S.ModelId												
		WHERE
		D.FdpChangesetDataItemId = @FdpChangesetDataItemId;
		
		-- Fdp Models
		
		UPDATE D SET TotalVolume = CAST(CEILING(S.TotalVolume * D.PercentageTakeRate) AS INT)
		FROM Fdp_Changeset									AS C
		JOIN Fdp_VolumeHeader								AS H	ON	C.FdpVolumeHeaderId = H.FdpVolumeHeaderId	
		JOIN Fdp_ChangesetDataItem							AS D	ON	C.FdpChangesetId	= D.FdpChangesetId
		JOIN Fdp_TakeRateSummaryByModelAndMarket_VW	AS S	ON	H.DocumentId = S.DocumentId
																	AND	D.MarketId	 = S.MarketId
																	AND D.FdpModelId = S.FdpModelId												
		WHERE
		D.FdpChangesetDataItemId = @FdpChangesetDataItemId;
	END
	ELSE
	BEGIN
	
		-- Oxo and Fdp Models
		
		UPDATE D SET TotalVolume = CAST(CEILING(S.TotalVolume * D.PercentageTakeRate) AS INT)
		FROM Fdp_Changeset					AS C
		JOIN Fdp_VolumeHeader				AS H	ON	C.FdpVolumeHeaderId = H.FdpVolumeHeaderId	
		JOIN Fdp_ChangesetDataItem			AS D	ON	C.FdpChangesetId	= D.FdpChangesetId
		JOIN Fdp_TakeRateSummaryByMarket_VW	AS S	ON	H.DocumentId = S.DocumentId
													AND	D.MarketId	 = S.MarketId																				
		WHERE
		D.FdpChangesetDataItemId = @FdpChangesetDataItemId;

		-- Now that the volume has been updated for the model, we need to recalculate the volumes
		-- for all features under that model

		EXEC Fdp_ChangesetDataItem_CalculateFeatureVolumes @FdpChangesetDataItemId = @FdpChangesetDataItemId;
		
	END