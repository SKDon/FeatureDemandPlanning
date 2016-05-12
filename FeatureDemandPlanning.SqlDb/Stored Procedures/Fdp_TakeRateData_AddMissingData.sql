CREATE PROCEDURE Fdp_TakeRateData_AddMissingData
	@FdpVolumeHeaderId AS INT
AS
	SET NOCOUNT ON;

	INSERT INTO Fdp_VolumeDataItem 
	(
		  CreatedBy
		, FdpVolumeHeaderId
		, IsManuallyEntered
		, MarketId
		, MarketGroupId
		, ModelId
		, TrimId
		, FeatureId
		, FeaturePackId
		, Volume
		, PercentageTakeRate
	)
	SELECT
		  H.CreatedBy
		, H.FdpVolumeHeaderId
		, CAST(0 AS BIT) AS IsManuallyEntered
		, MK.Market_Id
		, MK.Market_Group_Id
		, M.Id AS ModelId
		, CASE
			WHEN H.IsArchived = 1 THEN M2.Trim_Id
			ELSE M1.Trim_Id
		  END
		  AS TrimId
		, F.ID AS FeatureId
		, PK.PackId
		, CASE
			WHEN Applicability LIKE '%NA%' THEN 0
			WHEN Applicability LIKE '%S%' THEN S.TotalVolume
			ELSE 0
		  END AS Volume
		, CASE
			WHEN Applicability LIKE '%NA%' THEN 0
			WHEN Applicability LIKE '%S%' THEN 1
			ELSE 0
		  END AS PercentageTakeRate
	FROM
	Fdp_VolumeHeader_VW							AS H
	JOIN OXO_Programme_MarketGroupMarket_VW		AS MK	ON H.ProgrammeId = MK.Programme_Id
	CROSS APPLY dbo.fn_Fdp_AvailableModelByMarketWithPaging_GetMany(H.FdpVolumeHeaderId, MK.Market_Id, NULL, NULL) 
												AS M
	LEFT JOIN OXO_Programme_Model				AS M1	ON	H.ProgrammeId		= M1.Programme_Id
														AND M.Id				= M1.Id
														AND H.IsArchived		= 0
	LEFT JOIN OXO_Archived_Programme_Model		AS M2	ON	H.DocumentId		= M2.Doc_Id
														AND M.Id				= M2.Id
														AND H.IsArchived		= 1
	JOIN Fdp_TakeRateSummaryByModelAndMarket_VW AS S	ON	H.FdpVolumeHeaderId	= S.FdpVolumeHeaderId
														AND	MK.Market_Id		= S.MarketId
														AND M.Id				= S.ModelId
	JOIN OXO_Programme_Feature_VW				AS F	ON	H.ProgrammeId		= F.ProgrammeId
	LEFT JOIN OXO_Pack_Feature_VW				AS PK	ON	H.ProgrammeId		= PK.ProgrammeId
														AND F.ID				= PK.Id
	LEFT JOIN Fdp_VolumeDataItem_VW				AS D	ON	H.FdpVolumeHeaderId = D.FdpVolumeHeaderId
														AND MK.Market_Id		= D.MarketId
														AND M.Id				= D.ModelId
														AND F.Id				= D.FeatureId
	LEFT JOIN Fdp_FeatureApplicability			AS FA	ON	H.DocumentId		= FA.DocumentId
														AND MK.Market_Id		= FA.MarketId
														AND M.Id				= FA.ModelId
														AND F.Id				= FA.FeatureId
	WHERE
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	D.FdpVolumeDataItemId IS NULL

	UNION

	SELECT
		  H.CreatedBy
		, H.FdpVolumeHeaderId
		, CAST(0 AS BIT) AS IsManuallyEntered
		, MK.Market_Id
		, MK.Market_Group_Id
		, M.Id AS ModelId
		, CASE
			WHEN H.IsArchived = 1 THEN M2.Trim_Id
			ELSE M1.Trim_Id
		  END
		  AS TrimId
		, NULL AS FeatureId
		, PK.Id
		, CASE
			WHEN Applicability LIKE '%NA%' THEN 0
			WHEN Applicability LIKE '%S%' THEN S.TotalVolume
			ELSE 0
		  END AS Volume
		, CASE
			WHEN Applicability LIKE '%NA%' THEN 0
			WHEN Applicability LIKE '%S%' THEN 1
			ELSE 0
		  END AS PercentageTakeRate
	FROM
	Fdp_VolumeHeader_VW							AS H
	JOIN OXO_Programme_MarketGroupMarket_VW		AS MK	ON H.ProgrammeId = MK.Programme_Id
	CROSS APPLY dbo.fn_Fdp_AvailableModelByMarketWithPaging_GetMany(H.FdpVolumeHeaderId, MK.Market_Id, NULL, NULL) 
												AS M
	LEFT JOIN OXO_Programme_Model				AS M1	ON	H.ProgrammeId		= M1.Programme_Id
														AND M.Id				= M1.Id
														AND H.IsArchived		= 0
	LEFT JOIN OXO_Archived_Programme_Model		AS M2	ON	H.DocumentId		= M2.Doc_Id
														AND M.Id				= M2.Id
														AND H.IsArchived		= 1
	JOIN Fdp_TakeRateSummaryByModelAndMarket_VW AS S	ON	H.FdpVolumeHeaderId	= S.FdpVolumeHeaderId
														AND	MK.Market_Id		= S.MarketId
														AND M.Id				= S.ModelId
	JOIN OXO_Programme_Pack						AS PK	ON	H.ProgrammeId		= PK.Programme_Id
	LEFT JOIN Fdp_VolumeDataItem_VW				AS D	ON	H.FdpVolumeHeaderId = D.FdpVolumeHeaderId
														AND MK.Market_Id		= D.MarketId
														AND M.Id				= D.ModelId
														AND D.FeatureId			IS NULL
														AND PK.Id				= D.FeaturePackId
	LEFT JOIN Fdp_FeatureApplicability			AS FA	ON	H.DocumentId		= FA.DocumentId
														AND MK.Market_Id		= FA.MarketId
														AND M.Id				= FA.ModelId
														AND FA.FeatureId		IS NULL
														AND PK.Id				= FA.FeaturePackId
	WHERE
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	D.FdpVolumeDataItemId IS NULL