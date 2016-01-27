CREATE PROCEDURE dbo.Fdp_Validation_GetMany
	  @FdpVolumeHeaderId	INT
	, @MarketId				INT				= NULL
	, @ModelIdentifier		NVARCHAR(10)	= NULL
	, @FeatureIdentifier	NVARCHAR(10)	= NULL
AS

	SET NOCOUNT ON;

	SELECT
		  V.FdpVolumeHeaderId
		, V.MarketId
		, V.ModelIdentifier
		, V.FeatureIdentifier
		, V.[Message]
	FROM
	Fdp_Validation_VW AS V
	WHERE
	V.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(@MarketId IS NULL OR V.MarketId = @MarketId)
	AND
	(@ModelIdentifier IS NULL OR V.ModelIdentifier = @ModelIdentifier)
	AND
	(@FeatureIdentifier IS NULL OR V.FeatureIdentifier = @FeatureIdentifier)
	ORDER BY
	MarketId, ModelIdentifier, FeatureIdentifier