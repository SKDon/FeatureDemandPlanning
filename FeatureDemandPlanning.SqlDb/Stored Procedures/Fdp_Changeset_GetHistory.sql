CREATE PROCEDURE [dbo].[Fdp_Changeset_GetHistory]
	  @FdpVolumeHeaderId	AS INT
	, @MarketGroupId		AS INT = NULL
	, @MarketId				AS INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

    SELECT 
		  C.UpdatedOn
		, C.UpdatedBy
		, M.Market_Name			AS Market
		, M.Market_Group_Name	AS MarketGroup
		, C.Comment
	FROM
	Fdp_Changeset							AS C
	JOIN Fdp_VolumeHeader					AS H ON		C.FdpVolumeHeaderId = H.FdpVolumeHeaderId
	JOIN OXO_Doc							AS D ON		H.DocumentId		= D.Id
	JOIN OXO_Programme_MarketGroupMarket_VW AS M ON		C.MarketId			= M.Market_Id
												 AND	M.Programme_Id		= D.Programme_Id
	WHERE
	C.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(@MarketId IS NULL OR C.MarketId = @MarketId)
	AND
	(@MarketGroupId IS NULL OR M.Market_Group_Id = @MarketGroupId)
	AND
	C.IsSaved = 1
	AND
	C.IsDeleted = 0
	ORDER BY
	C.UpdatedOn DESC
END
GO

