CREATE FUNCTION [dbo].[fn_Fdp_VolumeByMarket_GetMany]
(
	  @FdpVolumeHeaderId	AS INT
	, @CdsId				AS NVARCHAR(16)
)
RETURNS @VolumeByMarket TABLE
(
	  MarketId	INT
	, Volume	INT
)
AS
BEGIN

	IF @CdsId IS NULL
	BEGIN
		INSERT INTO @VolumeByMarket
		(
			  MarketId
			, Volume
		)
		SELECT
			  MarketId
			, TotalVolume
		FROM Fdp_TakeRateSummaryByMarket_VW AS M
		WHERE 
		M.FdpVolumeHeaderId = @FdpVolumeHeaderId;
	END
	ELSE
	BEGIN

		-- If there is a whole market changeset item, for the volume, use that figure
		-- Otherwise aggregate the volumes for all models for that market

		INSERT INTO @VolumeByMarket
		(
			  MarketId
			, Volume
		)
		SELECT 
			  S.MarketId
			, ISNULL(SUM(S1.TotalVolume), SUM(S2.Volume)) AS TotalVolume
		FROM 
		Fdp_TakeRateSummaryByMarket_VW AS S
		LEFT JOIN Fdp_ChangesetMarket_VW AS S1 ON S.FdpVolumeHeaderId	= S.FdpVolumeHeaderId
												AND S1.CDSId			= @CdsId
												AND S1.MarketId			= S.MarketId
		CROSS APPLY dbo.fn_Fdp_VolumeByModel_GetMany(S.FdpVolumeHeaderId, S.MarketId, @CdsId) AS S2
		WHERE
		S.FdpVolumeHeaderId = @FdpVolumeHeaderId
		GROUP BY 
		S.MarketId
		
	END
		
	RETURN;

END