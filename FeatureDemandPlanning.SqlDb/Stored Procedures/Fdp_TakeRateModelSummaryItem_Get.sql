CREATE PROCEDURE [dbo].[Fdp_TakeRateModelSummaryItem_Get]
	  @DocumentId			INT = NULL
	, @FdpVolumeHeaderId	INT = NULL
	, @MarketId				INT = NULL
	, @ModelId				INT = NULL
	, @FdpModelId			INT = NULL
AS
	SET NOCOUNT ON;
	
	DECLARE @FdpTakeRateSummaryId INT;

	IF @FdpVolumeHeaderId IS NULL
		SET @FdpVolumeHeaderId = dbo.fn_Fdp_LatestTakeRateFileByDocument_Get(@DocumentId);
	
	SELECT TOP 1 @FdpTakeRateSummaryId = S.FdpTakeRateSummaryId
	FROM
	Fdp_TakeRateSummary AS S
	WHERE
	S.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(@MarketId IS NULL OR S.MarketId = @MarketId)
	AND
	(@ModelId IS NULL OR S.ModelId = @ModelId)
	AND
	(@FdpModelId IS NULL OR S.FdpModelId = @FdpModelId)
	
	SELECT
		  S.CreatedOn
		, S.CreatedBy
		, S.FdpVolumeHeaderId
		, S.MarketId
		, S.ModelId
		, S.FdpModelId
		, ISNULL(S1.TotalVolume, S.Volume) AS Volume
		, ISNULL(S1.PercentageTakeRate, S.PercentageTakeRate) AS PercentageTakeRate
		, S.UpdatedOn
		, S.UpdatedBy
		, CAST(CASE WHEN S1.FdpChangesetDataItemId IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS HasUncommittedChanges
	FROM
	Fdp_TakeRateSummary				AS S
	LEFT JOIN Fdp_Changeset			AS C	ON	S.FdpVolumeHeaderId		= C.FdpVolumeHeaderId
											AND C.IsDeleted				= 0
											AND C.IsSaved				= 0
	LEFT JOIN Fdp_ChangesetDataItem AS S1	ON	S.FdpTakeRateSummaryId	= S1.FdpTakeRateSummaryId
											AND S1.IsDeleted			= 0
											AND C.FdpChangesetId		= S1.FdpChangesetId

	WHERE
	S.FdpTakeRateSummaryId = @FdpTakeRateSummaryId;
	
	SELECT
		  N.FdpTakeRateDataItemNoteId
		, N.EnteredOn
		, N.EnteredBy
		, N.Note
	FROM
	Fdp_TakeRateDataItemNote AS N
	WHERE
	FdpTakeRateSummaryId = @FdpTakeRateSummaryId
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
		Fdp_TakeRateSummaryAudit AS A
		WHERE
		A.FdpTakeRateSummaryId = @FdpTakeRateSummaryId
		
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
		D.FdpTakeRateSummaryId = @FdpTakeRateSummaryId
		AND 
		D.IsDeleted = 0
		AND
		C.IsSaved = 0
		
		UNION
		
		SELECT
			  S.CreatedOn AS AuditOn
			, S.CreatedBy AS AuditBy
			, S.Volume
			, S.PercentageTakeRate
			, CAST(0 AS BIT) AS IsUncommittedChange
		FROM
		Fdp_TakeRateSummary AS S
		WHERE
		S.FdpTakeRateSummaryId = @FdpTakeRateSummaryId

		UNION
		
		SELECT
			  S.UpdatedOn AS AuditOn
			, S.UpdatedBy AS AuditBy
			, S.Volume
			, S.PercentageTakeRate
			, CAST(0 AS BIT) AS IsUncommittedChange
		FROM
		Fdp_TakeRateSummary AS S
		WHERE
		S.FdpTakeRateSummaryId = @FdpTakeRateSummaryId
	)
	AS HISTORY
	ORDER BY
	ISNULL(HISTORY.AuditOn, GETDATE()) DESC;