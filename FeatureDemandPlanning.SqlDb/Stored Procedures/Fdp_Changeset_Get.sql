﻿CREATE PROCEDURE [dbo].[Fdp_Changeset_Get]
	@FdpChangesetId AS INT
AS
	SET NOCOUNT ON;
	
	-- First dataset yields the header details

	DECLARE @IsMarketReview AS BIT = 0;
	IF EXISTS(
		SELECT TOP 1 1
		FROM
		Fdp_Changeset					AS C
		JOIN Fdp_MarketReview_VW	AS M	ON	C.FdpVolumeHeaderId = M.FdpVolumeHeaderId
												AND M.FdpMarketReviewStatusId <> 4 -- 
												AND C.MarketId = M.MarketId
												AND C.CreatedOn >= M.CreatedOn
												AND M.FdpMarketReviewStatusId <> 5 -- Recalled
		WHERE
		C.FdpChangesetId = @FdpChangesetId
	)
	BEGIN
		SET @IsMarketReview = 1
	END
	
	SELECT TOP 1 
		    C.FdpChangesetId
		  , C.CreatedOn
		  , C.CreatedBy
		  , C.IsDeleted
		  , C.IsSaved
		  , C.Comment
		  , @IsMarketReview AS IsMarketReview
	FROM
	Fdp_Changeset					AS C
	WHERE
	C.FdpChangesetId = @FdpChangesetId
	
	-- Second dataset yields the changes that comprise the dataset
	
	SELECT
		  D.CreatedOn
		, D.CreatedBy
		, D.MarketId
		, CASE 
			WHEN D.ModelId IS NOT NULL THEN 'O' + CAST(D.ModelId AS NVARCHAR(10))
			ELSE 'F' + CAST(D.FdpModelId AS NVARCHAR(10))
		  END
		  AS ModelIdentifier
		, CASE 
			WHEN D.FeatureId IS NOT NULL THEN 'O' + CAST(D.FeatureId AS NVARCHAR(10))
			WHEN D.FeatureId IS NULL AND D.FeaturePackId IS NOT NULL THEN 'P' + CAST(D.FeaturePackId AS NVARCHAR(10))
			ELSE 'F' + CAST(D.FdpFeatureId AS NVARCHAR(10))
		  END
		  AS FeatureIdentifier
		, D.DerivativeCode
		, D.Note
		, D.TotalVolume AS Volume
		, D.PercentageTakeRate * 100 AS PercentageTakeRate
		, @IsMarketReview AS IsMarketReview
	FROM
	Fdp_ChangesetDataItem AS D
	WHERE
	D.FdpChangesetId = @FdpChangesetId
	AND
	IsDeleted = 0
	ORDER BY
	D.FdpChangesetDataItemId DESC;

	-- Final dataset yields the updated model mix (if any)
	-- Can't include in the dataset above as it's an aggregation

	SELECT 
		  SUM(ISNULL(D.PercentageTakeRate, S.PercentageTakeRate)) AS ModelMix
		, SUM(ISNULL(D.TotalVolume, S.Volume)) AS ModelVolume
		, CAST(CASE WHEN SUM(D.PercentageTakeRate) > 0 THEN 1 ELSE 0 END AS BIT) AS HasModelMixChanged
		, CAST(CASE WHEN SUM(D.TotalVolume) > 0 THEN 1 ELSE 0 END AS BIT) AS HasModelVolumeChanged
		, @IsMarketReview AS IsMarketReview
	FROM
	Fdp_Changeset AS C
	JOIN Fdp_TakeRateSummary		AS S	ON	C.FdpVolumeHeaderId = S.FdpVolumeHeaderId
											AND C.MarketId			= S.MarketId
											AND S.ModelId IS NOT NULL
	LEFT JOIN Fdp_ChangesetDataItem AS D	ON	C.FdpChangesetId		= D.FdpChangesetId
											AND S.FdpTakeRateSummaryId	= D.FdpTakeRateSummaryId
											AND D.IsDeleted = 0
	WHERE
	C.FdpChangesetId = @FdpChangesetId;