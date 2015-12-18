


CREATE VIEW [dbo].[Fdp_TakeRateSummaryByMarket_VW] AS

	SELECT
		  VOL.DocumentId 
		, VOL.ProgrammeId
		, VOL.Gateway
		, VOL.MarketId
		, M.Market_Name AS MarketName
		, M.Market_Group_Id AS MarketGroupId
		, M.Market_Group_Name AS MarketGroup
		, VOL.TotalVolume
	FROM
	(
		SELECT 
			  H.DocumentId
			, D.Programme_Id AS ProgrammeId
			, D.Gateway
			, S.MarketId
			, SUM(Volume) AS TotalVolume
		FROM
		Fdp_VolumeHeader			AS H
		JOIN OXO_Doc				AS D	ON H.DocumentId			= D.Id
		JOIN Fdp_TakeRateSummary	AS S	ON H.FdpVolumeHeaderId	= S.FdpVolumeHeaderId
		GROUP BY
		  H.DocumentId
		, D.Programme_Id
		, D.Gateway
		, S.MarketId
	)
	AS VOL
	JOIN OXO_Programme_MarketGroupMarket_VW AS M ON		VOL.ProgrammeId = M.Programme_Id
												 AND	VOL.MarketId	= M.Market_Id