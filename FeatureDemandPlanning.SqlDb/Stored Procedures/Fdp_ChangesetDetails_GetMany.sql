CREATE PROCEDURE Fdp_ChangesetDetails_GetMany
	  @FdpChangesetId		AS INT = NULL
	, @FdpVolumeHeaderId	AS INT = NULL
AS

	SET NOCOUNT ON;

	SELECT
		  DETAILS.CreatedOn AS UpdatedOn
		, DETAILS.CreatedBy AS UpdatedBy
		, CASE
			WHEN DETAILS.IsMarketUpdate = 1 THEN 'Updated Volume for Market: ' + DETAILS.Market
			WHEN DETAILS.IsModelUpdate = 1 THEN 'Updated Model: ' + DETAILS.Model
			WHEN DETAILS.IsDerivativeUpdate = 1 THEN 'Updated Derivative Mix: ' + DETAILS.Derivative
			WHEN DETAILS.IsFeatureUpdate = 1 THEN 'Updated Feature: ' + DETAILS.Feature + ' for model ' + DETAILS.Model
		  END
		  AS Change
		, DETAILS.IsPercentageUpdate
		, DETAILS.OldPercentageTakeRate
		, DETAILS.NewPercentageTakeRate
		, DETAILS.OldVolume
		, DETAILS.NewVolume 
	FROM
	(
		-- Market level changes

		SELECT H.FdpVolumeHeaderId
			, C.FdpChangesetId
			, C.IsSaved
			, D.FdpChangesetDataItemId
			, D.CreatedOn
			, D.CreatedBy
			, MK.Market_Name				AS Market
			, NULL							AS Model
			, NULL							AS Derivative
			, NULL							AS Feature
			, D.IsVolumeUpdate
			, D.IsPercentageUpdate
			, CAST(1 AS BIT)				AS IsMarketUpdate
			, CAST(0 AS BIT)				AS IsModelUpdate
			, CAST(0 AS BIT)				AS IsDerivativeUpdate
			, CAST(0 AS BIT)				AS IsFeatureUpdate
			, D.OriginalVolume				AS OldVolume
			, D.TotalVolume					AS NewVolume
			, D.OriginalPercentageTakeRate	AS OldPercentageTakeRate
			, D.PercentageTakeRate			AS NewPercentageTakeRate
		FROM
		Fdp_VolumeHeader_VW						AS H
		JOIN Fdp_Changeset						AS C	ON	H.FdpVolumeHeaderId = C.FdpVolumeHeaderId
		JOIN Fdp_ChangesetDataItem				AS D	ON	C.FdpChangesetId	= D.FdpChangesetId
														AND D.ParentFdpChangesetDataItemId IS NULL
														AND D.MarketId			IS NOT NULL
														AND D.ModelId			IS NULL
														AND D.FdpPowertrainDataItemId IS NULL
		JOIN OXO_Programme_MarketGroupMarket_VW AS MK	ON H.ProgrammeId		= MK.Programme_Id
														AND D.MarketId			= MK.Market_Id

		UNION

		-- Model level changes

		SELECT H.FdpVolumeHeaderId
			, C.FdpChangesetId
			, C.IsSaved
			, D.FdpChangesetDataItemId
			, D.CreatedOn
			, D.CreatedBy
			, MK.Market_Name				AS Market
			, M.Name						AS Model
			, NULL							AS Derivative
			, NULL							AS Feature
			, D.IsVolumeUpdate
			, D.IsPercentageUpdate
			, CAST(0 AS BIT)				AS IsMarketUpdate
			, CAST(1 AS BIT)				AS IsModelUpdate
			, CAST(0 AS BIT)				AS IsDerivativeUpdate
			, CAST(0 AS BIT)				AS IsFeatureUpdate
			, D.OriginalVolume				AS OldVolume
			, D.TotalVolume					AS NewVolume
			, D.OriginalPercentageTakeRate	AS OldPercentageTakeRate
			, D.PercentageTakeRate			AS NewPercentageTakeRate
		FROM
		Fdp_VolumeHeader_VW						AS H
		JOIN Fdp_Changeset						AS C	ON	H.FdpVolumeHeaderId = C.FdpVolumeHeaderId
		JOIN Fdp_ChangesetDataItem				AS D	ON	C.FdpChangesetId	= D.FdpChangesetId
														AND D.ParentFdpChangesetDataItemId IS NULL
														AND D.FeatureId IS NULL
														AND D.FeaturePackId IS NULL
		JOIN OXO_Models_VW						AS M	ON	H.ProgrammeId		= M.Programme_Id
														AND D.ModelId			= M.Id
		JOIN OXO_Programme_MarketGroupMarket_VW AS MK	ON H.ProgrammeId		= MK.Programme_Id
														AND D.MarketId			= MK.Market_Id

		UNION

		-- Feature level changes

		SELECT H.FdpVolumeHeaderId
			, C.FdpChangesetId
			, C.IsSaved
			, D.FdpChangesetDataItemId
			, D.CreatedOn
			, D.CreatedBy
			, MK.Market_Name				AS Market
			, M.Name						AS Model
			, NULL							AS Derivative
			, ISNULL(F.BrandDescription, F.SystemDescription) + ' (' + F.FeatureCode + ')' AS Feature
			, D.IsVolumeUpdate
			, D.IsPercentageUpdate
			, CAST(0 AS BIT)				AS IsMarketUpdate
			, CAST(0 AS BIT)				AS IsModelUpdate
			, CAST(0 AS BIT)				AS IsDerivativeUpdate
			, CAST(1 AS BIT)				AS IsFeatureUpdate
			, D.OriginalVolume				AS OldVolume
			, D.TotalVolume					AS NewVolume
			, D.OriginalPercentageTakeRate	AS OldPercentageTakeRate
			, D.PercentageTakeRate			AS NewPercentageTakeRate
		FROM
		Fdp_VolumeHeader_VW						AS H
		JOIN Fdp_Changeset						AS C	ON	H.FdpVolumeHeaderId		= C.FdpVolumeHeaderId
		JOIN Fdp_ChangesetDataItem				AS D	ON	C.FdpChangesetId		= D.FdpChangesetId
														AND D.ParentFdpChangesetDataItemId IS NULL
		JOIN OXO_Models_VW						AS M	ON	H.ProgrammeId			= M.Programme_Id
														AND D.ModelId				= M.Id
		JOIN OXO_Programme_MarketGroupMarket_VW AS MK	ON	H.ProgrammeId			= MK.Programme_Id
														AND D.MarketId				= MK.Market_Id
		JOIN Fdp_Feature_VW						AS F	ON	H.DocumentId			= F.DocumentId
														AND D.FeatureId				= F.FeatureId

		UNION

		SELECT H.FdpVolumeHeaderId
			, C.FdpChangesetId
			, C.IsSaved
			, D.FdpChangesetDataItemId
			, D.CreatedOn
			, D.CreatedBy
			, MK.Market_Name				AS Market
			, M.Name						AS Model
			, NULL							AS Derivative
			, F.FeaturePackName + ' (' + F.FeaturePackCode + ')' AS Feature
			, D.IsVolumeUpdate
			, D.IsPercentageUpdate
			, CAST(0 AS BIT)				AS IsMarketUpdate
			, CAST(0 AS BIT)				AS IsModelUpdate
			, CAST(0 AS BIT)				AS IsDerivativeUpdate
			, CAST(1 AS BIT)				AS IsFeatureUpdate
			, D.OriginalVolume				AS OldVolume
			, D.TotalVolume					AS NewVolume
			, D.OriginalPercentageTakeRate	AS OldPercentageTakeRate
			, D.PercentageTakeRate			AS NewPercentageTakeRate
		FROM
		Fdp_VolumeHeader_VW						AS H
		JOIN Fdp_Changeset						AS C	ON	H.FdpVolumeHeaderId		= C.FdpVolumeHeaderId
		JOIN Fdp_ChangesetDataItem				AS D	ON	C.FdpChangesetId		= D.FdpChangesetId
														AND D.ParentFdpChangesetDataItemId IS NULL
		JOIN OXO_Models_VW						AS M	ON	H.ProgrammeId			= M.Programme_Id
														AND D.ModelId				= M.Id
		JOIN OXO_Programme_MarketGroupMarket_VW AS MK	ON H.ProgrammeId			= MK.Programme_Id
														AND D.MarketId				= MK.Market_Id
		JOIN Fdp_Feature_VW						AS F	ON	H.DocumentId			= F.DocumentId
														AND D.FeatureId				IS NULL
														AND D.FeaturePackId			= F.FeaturePackId

		UNION

		-- Derivative Mix Changes

		SELECT H.FdpVolumeHeaderId
			, C.FdpChangesetId
			, C.IsSaved
			, D.FdpChangesetDataItemId
			, D.CreatedOn
			, D.CreatedBy
			, MK.Market_Name				AS Market
			, NULL							AS Model
			, REPLACE(DV.Name, '#', '')		AS Derivative
			, NULL							AS Feature
			, D.IsVolumeUpdate
			, D.IsPercentageUpdate
			, CAST(0 AS BIT)				AS IsMarketUpdate
			, CAST(0 AS BIT)				AS IsModelUpdate
			, CAST(1 AS BIT)				AS IsDerivativeUpdate
			, CAST(0 AS BIT)				AS IsFeatureUpdate
			, D.OriginalVolume				AS OldVolume
			, D.TotalVolume					AS NewVolume
			, D.OriginalPercentageTakeRate	AS OldPercentageTakeRate
			, D.PercentageTakeRate			AS NewPercentageTakeRate
		FROM
		Fdp_VolumeHeader_VW						AS H
		JOIN Fdp_Changeset						AS C	ON	H.FdpVolumeHeaderId		= C.FdpVolumeHeaderId
		JOIN Fdp_ChangesetDataItem				AS D	ON	C.FdpChangesetId		= D.FdpChangesetId
														AND D.ParentFdpChangesetDataItemId IS NULL
														AND D.FdpPowertrainDataItemId		IS NOT NULL
		JOIN Fdp_DerivativeMapping_VW					AS DV	ON	H.DocumentId			= DV.DocumentId
														AND D.DerivativeCode		= DV.MappedDerivativeCode
		JOIN OXO_Programme_MarketGroupMarket_VW AS MK	ON H.ProgrammeId			= MK.Programme_Id
														AND D.MarketId				= MK.Market_Id
	)
	AS DETAILS
	WHERE
	(@FdpVolumeHeaderId IS NULL OR DETAILS.FdpVolumeHeaderId = @FdpVolumeHeaderId)
	AND
	(@FdpChangesetId IS NULL OR DETAILS.FdpChangesetId = @FdpChangesetId)
	ORDER BY 
	CreatedOn DESC