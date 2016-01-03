CREATE FUNCTION [dbo].[fn_Fdp_VolumeByModel_Get]
(
	  @FdpVolumeHeaderId	AS INT 
	, @ModelId				AS INT
	, @FdpModelId			AS INT
	, @MarketId				AS INT
	, @CdsId				AS NVARCHAR(16)
)
RETURNS INT
AS
BEGIN
	DECLARE @VolumeByModel AS INT;
	SET @VolumeByModel = 0;

	IF @CdsId IS NULL
	BEGIN
		SELECT TOP 1 @VolumeByModel = VOL.Volume
		FROM
		(
			SELECT S.Volume
			FROM
			Fdp_VolumeHeader			AS H
			JOIN Fdp_TakeRateSummary	AS S	ON	H.FdpVolumeHeaderId = S.FdpVolumeHeaderId
												AND S.MarketId			= @MarketId
												AND S.ModelId			= @ModelId
			WHERE
			H.FdpVolumeHeaderId = @FdpVolumeHeaderId
		
			UNION

			SELECT S.Volume
			FROM
			Fdp_VolumeHeader			AS H
			JOIN Fdp_TakeRateSummary	AS S	ON	H.FdpVolumeHeaderId = S.FdpVolumeHeaderId
												AND S.MarketId			= @MarketId
												AND S.FdpModelId		= @FdpModelId
			WHERE
			H.FdpVolumeHeaderId = @FdpVolumeHeaderId
		)
		AS VOL
	END
	ELSE
	BEGIN
		
		SELECT TOP 1 @VolumeByModel = VOL.Volume
		FROM
		(
			SELECT ISNULL(C.TotalVolume, S.TotalVolume) AS Volume
			FROM
			Fdp_VolumeHeader				AS	H
			JOIN Fdp_TakeRateSummaryByModelAndMarket_VW		AS	S	ON	H.FdpVolumeHeaderId		= S.FdpVolumeHeaderId
													AND S.MarketId				= @MarketId
													AND S.ModelId				= @ModelId
			LEFT JOIN Fdp_ChangesetModel_VW	AS	C	ON	H.FdpVolumeHeaderId		= C.FdpVolumeHeaderId
													AND C.CDSId					= @CdsId
													AND S.FdpTakeRateSummaryId	= C.FdpTakeRateSummaryId
			WHERE
			H.FdpVolumeHeaderId = @FdpVolumeHeaderId
			
			UNION

			SELECT ISNULL(C.TotalVolume, S.TotalVolume) AS Volume
			FROM
			Fdp_VolumeHeader				AS	H
			JOIN Fdp_TakeRateSummaryByModelAndMarket_VW		AS	S	ON	H.FdpVolumeHeaderId		= S.FdpVolumeHeaderId
													AND S.MarketId				= @MarketId
													AND S.FdpModelId			= @FdpModelId
			LEFT JOIN Fdp_ChangesetModel_VW	AS	C	ON	H.FdpVolumeHeaderId		= C.FdpVolumeHeaderId
													AND C.CDSId					= @CdsId
													AND S.FdpTakeRateSummaryId	= C.FdpTakeRateSummaryId
			WHERE
			H.FdpVolumeHeaderId = @FdpVolumeHeaderId
		)
		AS VOL
	END

	RETURN @VolumeByModel;

END