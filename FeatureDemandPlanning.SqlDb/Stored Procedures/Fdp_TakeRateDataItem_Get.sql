CREATE PROCEDURE [dbo].[Fdp_TakeRateDataItem_Get]
	  @DocumentId		INT
	, @MarketId			INT = NULL
	, @MarketGroupId	INT = NULL
	, @ModelId			INT = NULL
	, @FdpModelId		INT = NULL
	, @FeatureId		INT = NULL
	, @FdpFeatureId		INT = NULL
AS
	SET NOCOUNT ON;
	
	DECLARE @FdpVolumeDataItemId INT;
	
	SELECT TOP 1 @FdpVolumeDataItemId = D.FdpVolumeDataItemId
	FROM
	Fdp_VolumeHeader				AS H
	JOIN Fdp_VolumeDataItem			AS D	ON	H.FdpVolumeHeaderId = D.FdpVolumeHeaderId
	WHERE
	H.DocumentId = @DocumentId
	AND
	(@MarketId IS NULL OR D.MarketId = @MarketId)
	AND
	(@MarketGroupId IS NULL OR D.MarketGroupId = @MarketGroupId)
	AND
	(@ModelId IS NULL OR D.ModelId = @ModelId)
	AND
	(@FdpModelId IS NULL OR D.FdpModelId = @FdpModelId)
	AND
	(@FeatureId IS NULL OR D.FeatureId = @FeatureId)
	AND
	(@FdpFeatureId IS NULL OR D.FdpFeatureId = @FdpFeatureId);
	
	SELECT
		  D.CreatedOn
		, D.CreatedBy
		, D.FdpVolumeHeaderId
		, D.IsManuallyEntered
		, D.MarketId
		, D.MarketGroupId
		, D.ModelId
		, D.FdpModelId
		, D.TrimId
		, D.FdpTrimId
		, D.FeatureId
		, D.FdpFeatureId
		, D.FeaturePackId
		, ISNULL(D1.TotalVolume, D.Volume) AS Volume
		, ISNULL(D1.PercentageTakeRate, D.PercentageTakeRate) AS PercentageTakeRate
		, D.UpdatedOn
		, D.UpdatedBy
		, CAST(CASE WHEN D1.FdpChangesetDataItemId IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS HasUncommittedChanges
	FROM
	Fdp_VolumeDataItem				AS D
	LEFT JOIN Fdp_ChangesetDataItem AS D1	ON	D.FdpVolumeDataItemId = D1.FdpVolumeDataItemId
											AND D1.IsDeleted		= 0
	WHERE
	D.FdpVolumeDataItemId = @FdpVolumeDataItemId;
	
	SELECT
		  N.FdpTakeRateDataItemNoteId
		, N.EnteredOn
		, N.EnteredBy
		, N.Note
	FROM
	Fdp_TakeRateDataItemNote AS N
	WHERE
	FdpTakeRateDataItemId = @FdpVolumeDataItemId
	ORDER BY
	N.EnteredOn DESC
	
	SELECT
		  HISTORY.AuditOn
		, HISTORY.AuditBy
		, HISTORY.Volume
		, HISTORY.PercentageTakeRate
		, HISTORY.IsUncommittedChange
	FROM
	(
		SELECT
			  A.AuditOn
			, A.AuditBy
			, A.Volume
			, A.PercentageTakeRate
			, CAST(0 AS BIT) AS IsUncommittedChange
		FROM
		Fdp_TakeRateDataItemAudit AS A
		WHERE
		A.FdpVolumeDataItemId = @FdpVolumeDataItemId
		
		UNION
		
		SELECT
			  D.CreatedOn AS AuditOn
			, C.CreatedBy AS AuditBy
			, D.TotalVolume AS Volume
			, D.PercentageTakeRate
			, CAST(1 AS BIT) AS IsUncommittedChange
		FROM
		Fdp_ChangesetDataItem AS D
		JOIN Fdp_Changeset AS C ON D.FdpChangesetId = C.FdpChangesetId
		WHERE
		D.FdpVolumeDataItemId = @FdpVolumeDataItemId
		AND 
		D.IsDeleted = 0
		AND
		C.IsSaved = 0
		
		UNION
		
		SELECT
			  D.CreatedOn AS EnteredOn
			, D.CreatedBy AS EnteredBy
			, D.Volume
			, D.PercentageTakeRate
			, CAST(0 AS BIT) AS IsUncommittedChange
		FROM
		Fdp_VolumeDataItem AS D
		WHERE
		D.FdpVolumeDataItemId = @FdpVolumeDataItemId
	)
	AS HISTORY
	ORDER BY
	ISNULL(HISTORY.AuditOn, GETDATE()) DESC;