CREATE PROCEDURE [dbo].[Fdp_TakeRateHeader_GetHistory]
	  @FdpVolumeHeaderId	AS INT
	, @MarketGroupId		AS INT = NULL
	, @MarketId				AS INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

    SELECT
		  HISTORY.UpdatedOn
		, HISTORY.UpdatedBy
		, HISTORY.Market
		, HISTORY.MarketGroup
		, HISTORY.Comment
		, HISTORY.FdpChangesetId
		, HISTORY.IsSaved
		, HISTORY.IsMarketReview
    FROM
    (
    SELECT 
		  C.CreatedOn AS UpdatedOn
		, C.CreatedBy AS UpdatedBy 
		, M.Market_Name			AS Market
		, M.Market_Group_Name	AS MarketGroup
		, C.Comment
		, C.FdpChangesetId
		, C.IsSaved
		, CAST(0 AS BIT) AS IsMarketReview
	FROM
	Fdp_VolumeHeader_VW						AS H
	JOIN Fdp_Changeset						AS C ON		H.FdpVolumeHeaderId	= C.FdpVolumeHeaderId
	JOIN OXO_Programme_MarketGroupMarket_VW AS M ON		C.MarketId			= M.Market_Id
												 AND	M.Programme_Id		= H.ProgrammeId
	WHERE
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(@MarketId IS NULL OR C.MarketId = @MarketId)
	AND
	(@MarketGroupId IS NULL OR M.Market_Group_Id = @MarketGroupId)
	--AND
	--C.IsSaved = 1
	AND
	C.IsDeleted = 0
	
	UNION
	
	SELECT 
		  R.CreatedOn
		, R.CreatedBy
		, M.Market_Name			AS Market
		, M.Market_Group_Name	AS MarketGroup
		, R.Comment
		, NULL
		, CAST(1 AS BIT)		AS IsSaved
		, CAST(0 AS BIT) AS IsMarketReview
	FROM
	Fdp_VolumeHeader_VW						AS H
	JOIN Fdp_MarketReview					AS R ON		H.FdpVolumeHeaderId = R.FdpVolumeHeaderId
	JOIN OXO_Programme_MarketGroupMarket_VW AS M ON		R.MarketId			= M.Market_Id
												 AND	M.Programme_Id		= H.ProgrammeId
	WHERE
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(@MarketId IS NULL OR R.MarketId = @MarketId)
	AND
	(@MarketGroupId IS NULL OR M.Market_Group_Id = @MarketGroupId)
	
	UNION
	
	SELECT 
		  A.AuditOn
		, A.AuditBy
		, M.Market_Name			AS Market
		, M.Market_Group_Name	AS MarketGroup
		, A.Comment
		, NULL
		, CAST(1 AS BIT)		AS IsSaved
		, CAST(0 AS BIT) AS IsMarketReview
	FROM
	Fdp_VolumeHeader_VW						AS H
	JOIN Fdp_MarketReview					AS R ON		H.FdpVolumeHeaderId = R.FdpVolumeHeaderId
	JOIN Fdp_MarketReviewAudit				AS A ON		R.FdpMarketReviewId = A.FdpMarketReviewId
	JOIN OXO_Programme_MarketGroupMarket_VW AS M ON		R.MarketId			= M.Market_Id
												 AND	M.Programme_Id		= H.ProgrammeId
	WHERE
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(@MarketId IS NULL OR R.MarketId = @MarketId)
	AND
	(@MarketGroupId IS NULL OR M.Market_Group_Id = @MarketGroupId)
	
	UNION

	SELECT
		  P.PublishOn			AS AuditOn
		, P.PublishBy			AS AuditBy
		, MK.Market_Name		AS Market
		, MK.Market_Group_Name	AS MarketGroup
		, P.Comment
		, NULL
		, CAST(1 AS BIT)		AS IsSaved
		, CAST(0 AS BIT)		AS IsMarketReview
	FROM
	Fdp_VolumeHeader_VW						AS H
	JOIN Fdp_Publish						AS P	ON H.FdpVolumeHeaderId	= P.FdpVolumeHeaderId
	JOIN OXO_Programme_MarketGroupMarket_VW AS MK	ON H.ProgrammeId		= MK.Programme_Id
													AND P.MarketId			= MK.Market_Id
	WHERE
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(@MarketId IS NULL OR P.MarketId = @MarketId)

	)
	AS HISTORY
	ORDER BY
	HISTORY.UpdatedOn DESC
END