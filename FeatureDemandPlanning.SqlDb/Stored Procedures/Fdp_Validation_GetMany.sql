CREATE PROCEDURE [dbo].[Fdp_Validation_GetMany]
	  @FdpVolumeHeaderId	INT
	, @MarketId				INT				= NULL
	, @ModelId				INT				= NULL
	, @FdpModelId			INT				= NULL
	, @FeatureId			INT				= NULL
	, @FdpFeatureId			INT				= NULL
	, @CDSId				NVARCHAR(16)	= NULL
AS

	SET NOCOUNT ON;

	SELECT 
		  V1.FdpVolumeHeaderId
		, V1.MarketId
		, V1.MarketGroupId
		, V1.ModelIdentifier
		, V1.FeatureIdentifier
		, V1.[Message]
	FROM
	(
		-- Any validation not associated with a specific changeset change
		
		SELECT
			  V.FdpVolumeHeaderId
			, V.MarketId
			, V.MarketGroupId
			, V.ModelIdentifier
			, V.FeatureIdentifier
			, V.[Message]
			, V.ExclusiveFeatureGroup
		FROM
		Fdp_Validation_VW AS V
		WHERE
		V.FdpVolumeHeaderId = @FdpVolumeHeaderId
		AND
		V.FdpChangesetDataItemId IS NULL
		AND
		(@MarketId IS NULL OR V.MarketId = @MarketId)
		AND
		(@ModelId IS NULL OR V.ModelId = @ModelId)
		AND
		(@FdpModelId IS NULL OR V.FdpModelId = @FdpModelId)
		AND
		(@FeatureId IS NULL OR V.FeatureId = @FeatureId)
		AND
		(@FdpFeatureId IS NULL OR V.FdpFeatureId = @FdpFeatureId)
		
		UNION
		
		-- Any validation associated with a specific changeset or user
	
		SELECT
			  V.FdpVolumeHeaderId
			, V.MarketId
			, V.MarketGroupId
			, V.ModelIdentifier
			, V.FeatureIdentifier
			, V.[Message]
			, V.ExclusiveFeatureGroup
		FROM
		Fdp_Validation_VW				AS V
		JOIN Fdp_ChangesetDataItem_VW	AS C ON V.FdpChangesetDataItemId = C.FdpChangesetDataItemId
		WHERE
		V.FdpVolumeHeaderId = @FdpVolumeHeaderId
		AND
		(@MarketId IS NULL OR V.MarketId = @MarketId)
		AND
		(@ModelId IS NULL OR V.ModelId = @ModelId)
		AND
		(@FdpModelId IS NULL OR V.FdpModelId = @FdpModelId)
		AND
		(@FeatureId IS NULL OR V.FeatureId = @FeatureId)
		AND
		(@FdpFeatureId IS NULL OR V.FdpFeatureId = @FdpFeatureId)
		AND
		C.CDSId = @CDSId
	)
	AS V1
	ORDER BY
	V1.MarketId, V1.ModelIdentifier, V1.FeatureIdentifier