





CREATE VIEW [dbo].[Fdp_TakeRateSummaryByMarket_VW] AS

	WITH TotalsByMarket AS
	(
		SELECT
			  H.FdpVolumeHeaderId 
			, H.DocumentId
			, D.Programme_Id AS ProgrammeId
			, D.Gateway
			, S.MarketId
			, S.Volume AS TotalVolume
			, S.PercentageTakeRate
		FROM
		Fdp_VolumeHeader			AS H
		JOIN OXO_Doc				AS D	ON H.DocumentId			= D.Id
		JOIN Fdp_TakeRateSummary	AS S	ON H.FdpVolumeHeaderId	= S.FdpVolumeHeaderId
											AND S.ModelId			IS NULL
											AND S.FdpModelId		IS NULL
	)
	SELECT
		  T.FdpVolumeHeaderId
		, T.DocumentId 
		, T.ProgrammeId
		, T.Gateway
		, T.MarketId
		, M.Market_Name			AS MarketName
		, M.Market_Group_Id		AS MarketGroupId
		, M.Market_Group_Name	AS MarketGroup
		, T.TotalVolume
		, T.PercentageTakeRate
	FROM TotalsByMarket AS T
	JOIN OXO_Programme_MarketGroupMarket_VW AS M ON		T.ProgrammeId = M.Programme_Id
												 AND	T.MarketId	= M.Market_Id