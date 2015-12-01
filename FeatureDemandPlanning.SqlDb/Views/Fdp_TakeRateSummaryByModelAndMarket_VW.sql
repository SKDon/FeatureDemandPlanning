
CREATE VIEW [dbo].[Fdp_TakeRateSummaryByModelAndMarket_VW] AS

	SELECT 
		  VOL.ProgrammeId
		, VOL.Gateway
		, VOL.MarketId
		, MK.Market_Name AS MarketName
		, MK.Market_Group_Id AS MarketGroupId
		, MK.Market_Group_Name AS MarketGroup
		, VOL.ModelId
		, VOL.FdpModelId
		, CASE
			WHEN VOL.ModelId IS NOT NULL THEN M.BMC
			WHEN VOL.FdpModelId IS NOT NULL THEN M1.BMC
		  END
		  AS BMC
		, M.Trim_Id AS TrimId
		, M1.FdpTrimId
		, VOL.TotalVolume
	FROM
	(
		SELECT 
			  H.ProgrammeId
			, H.Gateway
			, S.MarketId
			, S.ModelId
			, S.FdpModelId
			, SUM(Volume) AS TotalVolume
		FROM
		Fdp_VolumeHeader			AS H
		JOIN Fdp_TakeRateSummary	AS S ON H.FdpVolumeHeaderId = S.FdpVolumeHeaderId
		GROUP BY
		  H.ProgrammeId
		, H.Gateway
		, S.MarketId
		, S.ModelId
		, S.FdpModelId
	)
	AS VOL
	JOIN OXO_Programme_MarketGroupMarket_VW AS MK	ON	VOL.ProgrammeId = MK.Programme_Id
													AND	VOL.MarketId	= MK.Market_Id
	LEFT JOIN OXO_Programme_Model			AS M	ON	VOL.ProgrammeId = M.Programme_Id
													AND	VOL.ModelId		= M.Id
	LEFT JOIN Fdp_Model_VW					AS M1	ON	VOL.ProgrammeId = M1.ProgrammeId
													AND VOL.Gateway		= M1.Gateway
													AND VOL.FdpModelId	= M1.FdpModelId