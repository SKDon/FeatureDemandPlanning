CREATE FUNCTION [dbo].[fn_Fdp_VolumeByMarket_Get]
(
	  @FdpVolumeHeaderId	AS INT
	, @MarketId				AS INT
	, @CdsId				AS NVARCHAR(16)
)
RETURNS INT
AS
BEGIN

	DECLARE @VolumeByMarket AS INT;

	IF @CdsId IS NULL
	BEGIN
		SELECT TOP 1 
			@VolumeByMarket = TotalVolume
		FROM Fdp_TakeRateSummaryByMarket_VW AS M
		WHERE 
		M.MarketId = @MarketId
	END
	ELSE
	BEGIN

		-- If there is a whole market changeset item, for the volume, use that figure

		SELECT TOP 1 @VolumeByMarket = C.TotalVolume
		FROM
		Fdp_VolumeHeader AS H
		JOIN Fdp_ChangesetMarket_VW AS C	ON H.FdpVolumeHeaderId	= C.FdpVolumeHeaderId
											AND C.CDSId			= @CdsId
											AND C.MarketId			= @MarketId		
		IF @VolumeByMarket IS NOT NULL
			RETURN @VolumeByMarket

		-- Otherwise aggregate the volumes for all models for that market

		SELECT @VolumeByMarket = SUM(VOL.Volume)
		FROM 
		dbo.fn_Fdp_VolumeByModel_GetMany(@FdpVolumeHeaderId, @MarketId, @CdsId) AS VOL

	END
		
	RETURN @VolumeByMarket;

END