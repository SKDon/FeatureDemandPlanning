CREATE PROCEDURE [dbo].[Fdp_TakeRateData_GetRaw]
	  @FdpVolumeHeaderId	INT
	, @MarketId				INT = NULL
	, @CDSId				NVARCHAR(16)
	, @IncludeChanges		BIT = 1
AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	
	DECLARE @MarketGroupId AS INT;
	DECLARE @MarketGroupName AS NVARCHAR(200)
	DECLARE @MarketName AS NVARCHAR(200)

	IF @MarketId IS NOT NULL
	BEGIN
		SELECT TOP 1 @MarketName = Market_Name, @MarketGroupId = Market_Group_Id, @MarketGroupName = Market_Group_Name 
		FROM 
		Fdp_VolumeHeader_VW AS H
		JOIN OXO_Programme_MarketGroupMarket_VW AS MK ON H.ProgrammeId = MK.Programme_Id
		WHERE 
		H.FdpVolumeHeaderId = @FdpVolumeHeaderId
		AND
		MK.Market_Id = @MarketId
	END

	DECLARE @FdpChangesetId INT;
	IF @MarketId IS NOT NULL
		SET @FdpChangesetId = dbo.fn_Fdp_Changeset_GetLatestByUser(@FdpVolumeHeaderId, @MarketId, @CDSId);

    DECLARE @Models AS TABLE
	(
		ModelId INT,
		Name NVARCHAR(200)
	)
	INSERT INTO @Models
	(
		  ModelId
		, Name
	)
	SELECT
		  M.Id	AS ModelId
		, M.Name
	FROM
	dbo.fn_Fdp_AvailableModelByMarketWithPaging_GetMany(@FdpVolumeHeaderId, @MarketId, NULL, NULL) AS M
	
	SELECT
		  H.FdpVolumeHeaderId
		, D1.FdpVolumeDataItemId
		, @MarketId AS MarketId
		, @MarketName AS Market
		, @MarketGroupId AS MarketGroupId
		, @MarketGroupName AS MarketGroup
		, F.FeatureId
		, F.FdpFeatureId
		, F.FeaturePackId
		, F.FeatureCode
		, ISNULL(F.BrandDescription, F.SystemDescription) AS FeatureDescription
		, F.ExclusiveFeatureGroup
		, F.FeaturePackName AS PackName
		, D1.ModelId
		, D1.FdpModelId
		, M.Name AS Model
		, FA.OxoCode
		, FA.IsStandardFeatureInGroup AS IsStandardFeatureInGroup
		, FA.IsOptionalFeatureInGroup
		, FA.IsNonApplicableFeatureInGroup
		, COUNT(FA.FeatureId) OVER (PARTITION BY H.DocumentId, D1.MarketId, D1.ModelId, FA.EfgName) AS FeaturesInExclusiveFeatureGroup
		, COUNT(CASE WHEN FA.OxoCode NOT LIKE '%NA%' THEN FA.FeatureId ELSE NULL END) OVER (PARTITION BY FA.DocumentId, FA.MarketId, FA.ModelId, FA.EfgName) AS ApplicableFeaturesInExclusiveFeatureGroup
		, ISNULL(ISNULL(C1.TotalVolume, D1.Volume), 0) AS Volume
		, ISNULL(ISNULL(C1.PercentageTakeRate, D1.PercentageTakeRate), 
			CASE 
				WHEN FA.OxoCode LIKE '%S%' AND FA.FeatureId IS NOT NULL THEN 1
				ELSE 0 
			END) AS PercentageTakeRate
		, C1.FdpChangesetDataItemId
		, NULL AS FdpChangesetDataItemId
		, CAST(0 AS BIT) AS IsOrphanedData
    FROM
    Fdp_VolumeHeader_VW						AS H
	JOIN Fdp_Feature_VW						AS F	ON	H.DocumentId		= F.DocumentId
	CROSS APPLY @Models						AS M
	JOIN Fdp_VolumeDataItem_VW				AS D1	ON	H.FdpVolumeHeaderId = D1.FdpVolumeHeaderId
													AND M.ModelId			= D1.ModelId
													AND F.FeatureId			= D1.FeatureId

	LEFT JOIN Fdp_FeatureApplicability_VW			AS FA	ON	H.DocumentId		= FA.DocumentId
															AND	D1.MarketId			= FA.MarketId
															AND D1.ModelId			= FA.ModelId
															AND D1.FeatureId		= FA.FeatureId
													
	-- Any changeset information
	LEFT JOIN Fdp_ChangesetDataItem_VW		AS C1	ON	C1.FdpChangesetId		= @FdpChangesetId
													AND D1.MarketId				= C1.MarketId
													AND D1.ModelId				= C1.ModelId
													AND F.FeatureId				= C1.FeatureId
													AND C1.IsFeatureUpdate		= 1
													AND @IncludeChanges			= 1

    WHERE
    H.FdpVolumeHeaderId = @FdpVolumeHeaderId
    AND
    (@MarketId IS NULL OR D1.MarketId = @MarketId)

	UNION

	SELECT
		  H.FdpVolumeHeaderId
		, D1.FdpVolumeDataItemId
		, @MarketId AS MarketId
		, @MarketName AS Market
		, @MarketGroupId AS MarketGroupId
		, @MarketGroupName AS MarketGroup
		, F.FeatureId
		, F.FdpFeatureId
		, F.FeaturePackId
		, F.FeatureCode
		, ISNULL(F.BrandDescription, F.SystemDescription) AS FeatureDescription
		, F.ExclusiveFeatureGroup
		, F.FeaturePackName AS PackName
		, D1.ModelId
		, D1.FdpModelId
		, M.Name AS Model
		, FA.OxoCode
		, FA.IsStandardFeatureInGroup AS IsStandardFeatureInGroup
		, FA.IsOptionalFeatureInGroup
		, FA.IsNonApplicableFeatureInGroup
		, COUNT(FA.FeatureId) OVER (PARTITION BY H.DocumentId, D1.MarketId, D1.ModelId, FA.EfgName) AS FeaturesInExclusiveFeatureGroup
		, COUNT(CASE WHEN FA.OxoCode NOT LIKE '%NA%' THEN FA.FeatureId ELSE NULL END) OVER (PARTITION BY FA.DocumentId, FA.MarketId, FA.ModelId, FA.EfgName) AS ApplicableFeaturesInExclusiveFeatureGroup
		, ISNULL(ISNULL(C1.TotalVolume, D1.Volume), 0) AS Volume
		, ISNULL(ISNULL(C1.PercentageTakeRate, D1.PercentageTakeRate), 
			CASE 
				WHEN FA.OxoCode LIKE '%S%' THEN 1
				ELSE 0 
			END) AS PercentageTakeRate
		, C1.FdpChangesetDataItemId
		, NULL AS FdpChangesetDataItemId
		, CAST(0 AS BIT) AS IsOrphanedData
    FROM
    Fdp_VolumeHeader_VW						AS H
	JOIN Fdp_Feature_VW						AS F	ON	H.DocumentId		= F.DocumentId
	CROSS APPLY @Models						AS M
	JOIN Fdp_VolumeDataItem_VW				AS D1	ON	H.FdpVolumeHeaderId = D1.FdpVolumeHeaderId
													AND M.ModelId			= D1.ModelId
													AND F.FeaturePackId		= D1.FeaturePackId
													AND F.FeatureId			IS NULL
													AND D1.FeatureId		IS NULL

	LEFT JOIN Fdp_FeatureApplicability_VW			AS FA	ON	H.DocumentId		= FA.DocumentId
															AND	D1.MarketId			= FA.MarketId
															AND D1.ModelId			= FA.ModelId
															AND D1.FeaturePackId	= FA.FeaturePackId
															AND D1.FeatureId		IS NULL
															AND FA.FeatureId		IS NULL
													
	-- Any changeset information
	LEFT JOIN Fdp_ChangesetDataItem_VW		AS C1	ON	C1.FdpChangesetId		= @FdpChangesetId
													AND D1.MarketId				= C1.MarketId
													AND D1.ModelId				= C1.ModelId
													AND F.FeaturePackId			= C1.FeaturePackId
													AND F.FeatureId				IS NULL
													AND C1.FeatureId			IS NULL
													AND C1.IsFeatureUpdate		= 1
													AND @IncludeChanges			= 1

    WHERE
    H.FdpVolumeHeaderId = @FdpVolumeHeaderId
    AND
    (@MarketId IS NULL OR D1.MarketId = @MarketId)
    
END