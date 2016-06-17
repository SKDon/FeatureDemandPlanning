CREATE PROCEDURE [dbo].[Fdp_Publish_Get]
	    @FdpPublishId		INT = NULL
	  , @FdpVolumeHeaderId	INT = NULL
	  , @MarketId			INT = NULL
AS
	SET NOCOUNT ON;

	SELECT TOP 1
		  P.FdpPublishId
		, P.PublishOn
		, P.PublishBy
		, P.FdpVolumeHeaderId
		, P.MarketId
		, MK.Market_Name
		, V.VehicleMake
		, V.VehicleName
		, V.VehicleAKA
		, V.ModelYear
		, V.Gateway
		, V.DocumentVersion
		, V.VersionString
		, V.[Status]
		, P.IsPublished
		, P.Comment
	FROM
	Fdp_Publish								AS P
	JOIN Fdp_VolumeHeader_VW				AS H	ON	P.FdpVolumeHeaderId = H.FdpVolumeHeaderId
	JOIN Fdp_Version_VW						AS V	ON	H.FdpVolumeHeaderId	= V.FdpVolumeHeaderId
	JOIN OXO_Programme_MarketGroupMarket_VW AS MK	ON	H.ProgrammeId		= MK.Programme_Id
													AND P.MarketId			= MK.Market_Id
	WHERE
	(@FdpPublishId IS NULL OR P.FdpPublishId = @FdpPublishId)
	AND
	(@FdpVolumeHeaderId IS NULL OR P.FdpVolumeHeaderId = @FdpVolumeHeaderId)
	AND
	(@MarketId IS NULL OR P.MarketId = @MarketId)
	ORDER BY
	P.PublishOn DESC