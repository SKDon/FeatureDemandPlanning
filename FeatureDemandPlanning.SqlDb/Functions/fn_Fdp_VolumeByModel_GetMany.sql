CREATE FUNCTION [dbo].[fn_Fdp_VolumeByModel_GetMany]
(
	  @FdpVolumeHeaderId	AS INT 
	, @MarketId				AS INT
	, @CdsId				AS NVARCHAR(16)
)
RETURNS @VolumeByModel TABLE
(
	  ModelId		INT NULL
	, FdpModelId	INT NULL
	, Volume		INT
)
AS
BEGIN

	IF @CdsId IS NULL
	BEGIN
		INSERT INTO @VolumeByModel
		(
			  ModelId
			, FdpModelId
			, Volume
		)
		SELECT 
				  S.ModelId
				, S.FdpModelId
				, S.TotalVolume AS Volume
			FROM
			Fdp_TakeRateSummaryByModelAndMarket_VW	AS S
			WHERE
			S.FdpVolumeHeaderId = @FdpVolumeHeaderId
			AND
			S.MarketId = @MarketId
	END
	ELSE
	BEGIN
		
		INSERT INTO @VolumeByModel
		(
			  ModelId
			, FdpModelId
			, Volume
		)
		SELECT 
				S.ModelId
			, S.FdpModelId
			, ISNULL(C.TotalVolume, S.TotalVolume) AS Volume
		FROM
		Fdp_TakeRateSummaryByModelAndMarket_VW	AS S
		LEFT JOIN Fdp_ChangesetModel_VW AS	C	ON	S.FdpVolumeHeaderId		= C.FdpVolumeHeaderId
												AND C.MarketId				= @MarketId
												AND C.CDSId					= @CdsId
												AND S.FdpTakeRateSummaryId	= C.FdpTakeRateSummaryId
		WHERE
		S.FdpVolumeHeaderId = @FdpVolumeHeaderId
		AND
		S.MarketId = @MarketId

		
	END

	RETURN;

END