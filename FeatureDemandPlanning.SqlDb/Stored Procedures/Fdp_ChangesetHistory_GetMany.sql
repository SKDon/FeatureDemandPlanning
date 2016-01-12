CREATE PROCEDURE [dbo].[Fdp_ChangesetHistory_GetMany]
	  @FdpVolumeHeaderId	AS INT
	, @MarketId				AS INT			= NULL
	, @CDSId				AS NVARCHAR(16) = NULL
AS
	SET NOCOUNT ON;
	
	SELECT 
		  C.UpdatedOn
		, C.UpdatedBy
		, C.Comment
	FROM Fdp_Changeset AS C
	WHERE
	C.IsDeleted = 0
	AND
	C.IsSaved = 1
	AND
	C.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(@CDSId IS NULL OR C.CreatedBy = @CDSId)
	AND
	(@MarketId IS NULL OR C.MarketId = @MarketId)
	ORDER BY
	C.UpdatedOn DESC