CREATE PROCEDURE Fdp_ChangesetDataItem_CalculateExclusiveFeatureGroupMix
	@FdpChangesetDataItemId AS INT
AS
	SET NOCOUNT ON;
	
	DECLARE @EFGName AS NVARCHAR(MAX);
	DECLARE @ModelVolume AS INT;
	DECLARE @EFG AS TABLE
	(
		  FdpChangesetId INT
		, FdpVolumeHeaderId INT
		, MarketId INT
		, ModelId INT
		, EFGName NVARCHAR(MAX)
		, NumberOfFeaturesInGroup INT
		, StandardFeatureId INT
		, ModelVolume INT
		, StandardFeatureVolume INT
		, OptionalFeatureVolumes INT
		, OptionalFeatureTakeRates DECIMAL(5,4)
		, StandardFeatureTakeRate DECIMAL(5,4)
	)
	DECLARE @ChildFdpChangesetDataItemId AS INT;
	
	-- Get the EFG that the changeset data item belongs to
	
	SELECT @EFGName = F.EFGName
	FROM
	Fdp_ChangesetDataItem_VW AS C
	JOIN Fdp_VolumeHeader_VW AS H ON C.FdpVolumeHeaderId = H.FdpVolumeHeaderId
	JOIN OXO_Programme_Feature_VW AS F ON H.ProgrammeId = F.ProgrammeId
										AND C.FeatureId = F.ID
	WHERE
	C.FdpChangesetDataItemId = @FdpChangesetDataItemId;
	
	-- Get the volume for the market / model and any associated changes
	
	SELECT @ModelVolume = ISNULL(ISNULL(M1.TotalVolume, M.TotalVolume), 0)
	FROM
	Fdp_ChangesetDataItem_VW	AS C
	LEFT JOIN Fdp_TakeRateSummaryByModelAndMarket_VW AS M ON C.FdpVolumeHeaderId = M.FdpVolumeHeaderId
														AND C.MarketId = M.MarketId
														AND C.ModelId = M.ModelId
	
	LEFT JOIN Fdp_ChangesetModel_VW	AS M1	ON	C.FdpChangesetId	= M1.FdpChangesetId
										AND C.MarketId			= M1.MarketId
										AND C.ModelId			= M1.ModelId
	WHERE
	C.FdpChangesetDataItemId = @FdpChangesetDataItemId;
	
	INSERT INTO @EFG
	(
		  FdpChangesetId
		, FdpVolumeHeaderId
		, MarketId
		, ModelId
		, EFGName
		, NumberOfFeaturesInGroup 
		, StandardFeatureId
		, ModelVolume
		, StandardFeatureVolume
		, OptionalFeatureVolumes
		, OptionalFeatureTakeRates
		, StandardFeatureTakeRate 
	)
	SELECT
		  C.FdpChangesetId 
		, C.FdpVolumeHeaderId
		, FA.MarketId
		, FA.ModelId
		, F.EFGName
		, COUNT(F.ID) AS NumberOfFeaturesInGroup
		, MAX(CASE WHEN FA.Applicability LIKE '%S%' THEN F.ID ELSE NULL END) AS StandardFeatureId
		, @ModelVolume AS ModelVolume
		, @ModelVolume - SUM(
			CASE 
				WHEN FA.Applicability LIKE '%O%' AND FA.FeatureId = C.FeatureId THEN C.TotalVolume 
				WHEN FA.Applicability LIKE '%O%' AND FA.FeatureId <> C.FeatureId THEN ISNULL(D.Volume, 0)
				ELSE 0
			END)
			AS StandardFeatureVolume
		, SUM(
			CASE 
				WHEN FA.Applicability LIKE '%O%' AND FA.FeatureId = C.FeatureId THEN C.TotalVolume 
				WHEN FA.Applicability LIKE '%O%' AND FA.FeatureId <> C.FeatureId THEN ISNULL(D.Volume, 0)
				ELSE 0
			END)
			AS OptionalFeatureVolumes
		, SUM(
			CASE 
				WHEN FA.Applicability LIKE '%O%' AND FA.FeatureId = C.FeatureId THEN C.PercentageTakeRate
				WHEN FA.Applicability LIKE '%O%' AND FA.FeatureId <> C.FeatureId THEN ISNULL(D.PercentageTakeRate, 0)
				ELSE 0 
			END) 
			AS OptionalFeatureTakeRates
		, 1 - SUM(
			CASE 
				WHEN FA.Applicability LIKE '%O%' AND FA.FeatureId = C.FeatureId THEN C.PercentageTakeRate
				WHEN FA.Applicability LIKE '%O%' AND FA.FeatureId <> C.FeatureId THEN ISNULL(D.PercentageTakeRate, 0)
				ELSE 0 
			END) 
			AS StandardFeatureTakeRate
		
	FROM
	Fdp_ChangesetDataItem_VW					AS C
	JOIN Fdp_VolumeHeader_VW					AS H	ON	C.FdpVolumeHeaderId = C.FdpVolumeHeaderId
	JOIN Fdp_FeatureApplicability				AS FA	ON	H.DocumentId		= FA.DocumentId
														AND C.MarketId			= FA.MarketId
														AND C.ModelId			= FA.ModelId
	JOIN OXO_Programme_Feature_VW				AS F	ON	H.ProgrammeId		= F.ProgrammeId
														AND FA.FeatureId		= F.ID
	LEFT JOIN Fdp_VolumeDataItem_VW				AS D	ON	H.FdpVolumeHeaderId = D.FdpVolumeHeaderId
														AND FA.MarketId			= D.MarketId
														AND FA.ModelId			= D.ModelId
														AND FA.FeatureId		= D.FeatureId
	WHERE
	C.FdpChangesetDataItemId = @FdpChangesetDataItemId
	AND
	FA.MarketId IS NOT NULL
	AND
	FA.Applicability NOT LIKE '%NA%' -- Non applicable items are not included in the group item count
	AND
	FA.Applicability NOT LIKE '%P%' -- Ignore pack items from the group item count as it may be standard at that trim level, but still in a pack
	AND
	F.EFGName = @EFGName
	GROUP BY 
	C.FdpChangesetId, C.FdpVolumeHeaderId, FA.MarketId, FA.ModelId, F.EFGName
	
	-- Mark any previous changeset entries for the standard feature as deleted
	
	UPDATE C SET IsDeleted = 1
	FROM
	@EFG AS E
	JOIN Fdp_ChangesetDataItem AS C ON E.FdpChangesetId = C.FdpChangesetId
									AND E.MarketId		= C.MarketId
									AND E.ModelId		= C.ModelId
									AND E.StandardFeatureId	= C.FeatureId
									
	-- Add a new changeset entry for the standard feature
	
	INSERT INTO Fdp_ChangesetDataItem
	(
		  FdpChangesetId
		, MarketId
		, ModelId
		, FeatureId
		, TotalVolume
		, PercentageTakeRate
		, OriginalVolume
		, OriginalPercentageTakeRate
		, FdpVolumeDataItemId
	)
	SELECT
		  E.FdpChangesetId
		, E.MarketId
		, E.ModelId
		, E.StandardFeatureId AS FeatureId
		, E.StandardFeatureVolume AS TotalVolume
		, E.StandardFeatureTakeRate AS PercentageTakeRate
		, D.Volume AS OriginalVolume
		, D.PercentageTakeRate AS OriginalPercentageTakeRate
		, D.FdpVolumeDataItemId
	FROM
	@EFG AS E
	JOIN Fdp_VolumeDataItem AS D	ON	E.FdpVolumeHeaderId	= D.FdpVolumeHeaderId
									AND E.MarketId			= D.MarketId
									AND E.ModelId			= D.ModelId
									AND E.StandardFeatureId = D.FeatureId
	
	-- Calculate the feature mix for the standard feature
	
	SET @ChildFdpChangesetDataItemId = SCOPE_IDENTITY();
	EXEC Fdp_ChangesetDataItem_CalculateFeatureMixForSingleFeature @FdpChangesetDataItemId = @ChildFdpChangesetDataItemId;