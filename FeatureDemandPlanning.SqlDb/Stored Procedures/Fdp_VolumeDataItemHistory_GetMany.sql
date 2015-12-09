CREATE PROCEDURE dbo.Fdp_VolumeDataItemHistory_GetMany
	  @DocumentId			INT
	, @ModelIdentifier		NVARCHAR(10)
	, @FeatureIdentifier	NVARCHAR(10)
	, @MarketId				INT = NULL
	, @MarketGroupId		INT = NULL
AS
	SET NOCOUNT ON;
	
	DECLARE @ModelType				NVARCHAR(1);
	DECLARE @FeatureType			NVARCHAR(1);
	DECLARE @ModelId				INT;
	DECLARE @FeatureId				INT;
	DECLARE @FdpVolumeDataItemId	INT;
	
	SELECT @ModelType	= LEFT(@ModelIdentifier, 1);
	SELECT @FeatureType = LEFT(@FeatureIdentifier, 1);
	SELECT @ModelId		= CAST(REPLACE(@ModelIdentifier, @ModelType, '')		AS INT);
	SELECT @FeatureId	= CAST(REPLACE(@FeatureIdentifier, @FeatureType, '')	AS INT);
	
	SELECT TOP 1 @FdpVolumeDataItemId = FdpVolumeDataItemId
	FROM Fdp_VolumeHeader	AS H
	JOIN Fdp_VolumeDataItem AS D ON H.FdpVolumeHeaderId = D.FdpVolumeHeaderId
	WHERE
	H.DocumentId = @DocumentId
	AND
	(
		(@ModelType = 'O' AND D.ModelId = @ModelId)
		OR
		(@ModelType = 'F' AND D.FdpModelId = @ModelId)
	)
	AND
	(
		(@FeatureType = 'O' AND D.FeatureId = @FeatureId)
		AND
		(@FeatureType = 'F' AND D.FdpFeatureId = @FeatureId)
	)
	AND
	(@MarketGroupId IS NULL OR D.MarketGroupId = @MarketGroupId)
	AND
	(@MarketId IS NULL OR D.MarketId = @MarketId)
	
	SELECT
		  AuditOn
		, AuditBy
		, Volume
		, PercentageTakeRate
	FROM
	(
		SELECT 
			  ISNULL(D.UpdatedOn, D.CreatedOn) AS AuditOn
			, ISNULL(D.UpdatedBy, D.CreatedBy) AS AuditBy
			, D.Volume
			, D.PercentageTakeRate
			 
		FROM Fdp_VolumeDataItem AS D 
		WHERE
		D.FdpVolumeDataItemId = @FdpVolumeDataItemId
		
		UNION
		
		SELECT 
			  D.AuditOn
			, D.AuditBy
			, D.Volume
			, D.PercentageTakeRate
			 
		FROM Fdp_VolumeDataItemAudit AS D 
		WHERE
		D.FdpVolumeDataItemId = @FdpVolumeDataItemId
	)
	AS HISTORY
	ORDER BY
	HISTORY.AuditOn DESC