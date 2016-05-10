CREATE PROCEDURE [dbo].[Fdp_TakeRateSummary_GetRaw]
	  @FdpVolumeHeaderId	INT
	, @MarketId				INT
	, @CDSId				NVARCHAR(16)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @FdpChangesetId INT;
	SET @FdpChangesetId = dbo.fn_Fdp_Changeset_GetLatestByUser(@FdpVolumeHeaderId, @MarketId, @CDSId);

	WITH Models AS 
	(
		SELECT
			  @FdpVolumeHeaderId	AS FdpVolumeHeaderId
			, M.Id					AS ModelId
			, M.FdpModelId			AS FdpModelId
			, M.Name
		FROM
		dbo.fn_Fdp_AvailableModelByMarketWithPaging_GetMany(@FdpVolumeHeaderId, @MarketId, NULL, NULL) AS M
	)
	SELECT
		  H.FdpVolumeHeaderId
		, S.FdpTakeRateSummaryId
		, S.MarketId
		, MK.Market_Name AS Market
		, MK.Market_Group_Id AS MarketGroupId
		, MK.Market_Group_Name AS MarketGroup
		, S.ModelId
		, S.FdpModelId
		, M.Name AS Model
		, M.BMC AS DerivativeCode
		, ISNULL(C.TotalVolume, S.Volume) AS Volume
		, ISNULL(C.PercentageTakeRate, S.PercentageTakeRate) AS PercentageTakeRate
    FROM
    Fdp_VolumeHeader_VW						AS H
    JOIN Fdp_TakeRateSummary				AS S	ON	H.FdpVolumeHeaderId = S.FdpVolumeHeaderId
    JOIN Models								AS A	ON	S.ModelId			= A.ModelId	
    JOIN OXO_Programme_MarketGroupMarket_VW AS MK	ON	S.MarketId			= MK.Market_Id
													AND H.ProgrammeId		= MK.Programme_Id
	-- Model
	LEFT JOIN OXO_Models_VW					AS M	ON	S.ModelId			= M.Id
													AND H.ProgrammeId		= M.Programme_Id								
					
	-- Any changeset information
	LEFT JOIN Fdp_ChangesetDataItem_VW		AS C	ON	S.FdpTakeRateSummaryId	= C.FdpTakeRateSummaryId
													AND C.FdpChangesetId		= @FdpChangesetId
	
    WHERE
    H.FdpVolumeHeaderId = @FdpVolumeHeaderId
    AND
    S.MarketId = @MarketId;
    
END