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
			  VOL.ModelId
			, VOL.FdpModelId
			, VOL.Volume
		FROM
		(
			SELECT 
				  S.ModelId
				, S.FdpModelId
				, S.Volume
			FROM
			Fdp_VolumeHeader			AS H
			JOIN Fdp_TakeRateSummary	AS S	ON	H.FdpVolumeHeaderId = S.FdpVolumeHeaderId
												AND S.MarketId			= @MarketId
			WHERE
			H.FdpVolumeHeaderId = @FdpVolumeHeaderId
		
			UNION

			SELECT 
				  S.ModelId
				, S.FdpModelId
				, S.Volume
			FROM
			Fdp_VolumeHeader			AS H
			JOIN Fdp_TakeRateSummary	AS S	ON	H.FdpVolumeHeaderId = S.FdpVolumeHeaderId
												AND S.MarketId			= @MarketId
			WHERE
			H.FdpVolumeHeaderId = @FdpVolumeHeaderId
		)
		AS VOL
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
			, ISNULL(C.TotalVolume, S.Volume) AS Volume
		FROM
		Fdp_VolumeHeader				AS	H
		JOIN Fdp_TakeRateSummary		AS	S	ON	H.FdpVolumeHeaderId		= S.FdpVolumeHeaderId
												AND S.MarketId				= @MarketId
		LEFT JOIN Fdp_ChangesetModel_VW AS	C	ON	H.FdpVolumeHeaderId		= C.FdpVolumeHeaderId
												AND C.MarketId				= @MarketId
												AND C.CDSId					= @CdsId
												AND S.FdpTakeRateSummaryId	= C.FdpTakeRateSummaryId
		WHERE
		H.FdpVolumeHeaderId = @FdpVolumeHeaderId
		
	END

	RETURN;

END