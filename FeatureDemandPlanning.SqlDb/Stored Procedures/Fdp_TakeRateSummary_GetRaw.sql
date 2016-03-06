CREATE PROCEDURE [dbo].[Fdp_TakeRateSummary_GetRaw]
	  @FdpVolumeHeaderId	INT
	, @MarketId				INT
	, @CDSId				NVARCHAR(16)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @FdpChangesetId INT;
	SET @FdpChangesetId = dbo.fn_Fdp_Changeset_GetLatestByUser(@FdpVolumeHeaderId, @MarketId, @CDSId);

	SELECT
		  H.FdpVolumeHeaderId
		, S.FdpTakeRateSummaryId
		, S.MarketId
		, M.Market_Name AS Market
		, M.Market_Group_Id AS MarketGroupId
		, M.Market_Group_Name AS MarketGroup
		, S.ModelId
		, S.FdpModelId
		, CASE
			WHEN MD1.Id IS NOT NULL THEN MD1.Name
			WHEN MD2.FdpModelId IS NOT NULL THEN MD2.Name
		  END
		  AS Model
		, CASE
			WHEN MD1.Id IS NOT NULL THEN MD1.BMC
			WHEN MD2.FdpModelId IS NOT NULL THEN MD2.BMC
		  END
		  AS DerivativeCode
		, ISNULL(C.TotalVolume, S.Volume) AS Volume
		, ISNULL(C.PercentageTakeRate, S.PercentageTakeRate) AS PercentageTakeRate
    FROM
    Fdp_VolumeHeader_VW						AS H
    JOIN Fdp_TakeRateSummary				AS S	ON	H.FdpVolumeHeaderId = S.FdpVolumeHeaderId
    JOIN OXO_Programme_MarketGroupMarket_VW AS M	ON	S.MarketId			= M.Market_Id
													AND H.ProgrammeId		= M.Programme_Id
	-- Model
	LEFT JOIN OXO_Models_VW					AS MD1	ON	S.ModelId			= MD1.Id
													AND H.ProgrammeId		= MD1.Programme_Id
													
	LEFT JOIN Fdp_Model_VW					AS MD2	ON	S.FdpModelId		= MD2.FdpModelId
													AND H.ProgrammeId		= MD2.ProgrammeId
													AND H.Gateway			= MD2.Gateway									
					
	-- Any changeset information
	LEFT JOIN Fdp_ChangesetDataItem_VW		AS C	ON	S.FdpTakeRateSummaryId	= C.FdpTakeRateSummaryId
													AND C.FdpChangesetId		= @FdpChangesetId
	
    WHERE
    H.FdpVolumeHeaderId = @FdpVolumeHeaderId
    AND
    S.MarketId = @MarketId;
    
END