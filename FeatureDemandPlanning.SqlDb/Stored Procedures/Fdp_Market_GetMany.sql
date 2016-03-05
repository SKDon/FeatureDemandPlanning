
CREATE PROCEDURE [dbo].[Fdp_Market_GetMany]
	@FdpVolumeHeaderId INT
AS
	SET NOCOUNT ON;

	SELECT DISTINCT
		  M.Id
		, M.Name
	FROM
	Fdp_VolumeDataItem_VW AS D
	JOIN OXO_Master_Market AS M ON D.MarketId = M.Id
	WHERE
	FdpVolumeHeaderId = @FdpVolumeHeaderId
	ORDER BY
	M.Name